package org.agmip.tool.vmapper.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collection;
import java.util.HashMap;
import java.util.Scanner;
import java.util.zip.GZIPInputStream;
import javax.servlet.ServletException;
import javax.servlet.http.Part;
import org.agmip.ace.AceDataset;
import org.agmip.ace.io.AceGenerator;
import org.agmip.ace.io.AceParser;
import org.agmip.tool.vmapper.util.translator.ExcelHelper;
import org.agmip.util.JSONAdapter;
import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import spark.Request;

/**
 *
 * @author Meng Zhang
 */
public class TranslationUtil {
    
    private static final Logger LOG = LoggerFactory.getLogger(TranslationUtil.class);
    
    public static JSONObject translateData(Request request) throws IOException, ServletException {
        Collection<Part> parts = request.raw().getParts();
        ArrayList<File> inputs = new ArrayList();
        File workDir = Paths.get(Path.Folder.TASK_DIR, request.session().id(), System.currentTimeMillis() + "").toFile();
        String[] models = {};
        for (Part part : parts) {

            if (part.getSubmittedFileName() != null) {
                java.nio.file.Path out;
                if (ExcelHelper.isExcel(part.getSubmittedFileName())) {
                    if (part.getName().equalsIgnoreCase("linkage")) {
                        out = Paths.get(workDir.getPath(), part.getName(), part.getSubmittedFileName() + ".csv");
                        ExcelHelper.toCsvZip(part.getInputStream(), part.getSubmittedFileName(), out.toFile(), true);
                    } else {
                        out = Paths.get(workDir.getPath(), part.getName(), part.getSubmittedFileName() + ".zip");
                        ExcelHelper.toCsvZip(part.getInputStream(), part.getSubmittedFileName(), out.toFile(), false);
                    }
                } else {
                    out = Paths.get(workDir.getPath(), part.getName(), part.getSubmittedFileName());
                    out.toFile().mkdirs();
                    try (final InputStream in = part.getInputStream()) {
                        Files.copy(in, out, REPLACE_EXISTING);
                    }
                }
                inputs.add(out.toFile());
            } else if ("models".equals(part.getName())) {
                try (final InputStream in = part.getInputStream()) {
                    BufferedReader br = new BufferedReader(new InputStreamReader(in));
                    String line = br.readLine();
                    models = line.split(",");
                }
            }
        }
        
        File retOutDir = Paths.get(workDir.getPath(), "result").toFile();
        retOutDir.mkdirs();
        HashMap<String, Object> rawData= TranslationTask.parseToJSON(inputs);
        if (rawData.containsKey("errors")) {
            return new JSONObject(rawData);
        }
        
        String dataSetName = inputs.get(0).getName();
        dataSetName = dataSetName.substring(0, dataSetName.lastIndexOf("."));
        File acebFile = Paths.get(retOutDir.getPath(), dataSetName + ".aceb").toFile();
        dumpToAceb(acebFile, rawData);
        
        ArrayList<String> quaduiArgs = new ArrayList(Arrays.asList(new String[]{"java", "-jar", "quadui.jar", "-cli", "-zip", "-clean", "-slave"}));
        
        File fieldOverlayDir = Paths.get(workDir.getAbsolutePath(), "field_overlay_dome").toFile();
        File seasonalStrategyDir = Paths.get(workDir.getAbsolutePath(), "seasonal_strategy_dome").toFile();
        File linkageDir = Paths.get(workDir.getAbsolutePath(), "linkage").toFile();
        if (seasonalStrategyDir.exists() && seasonalStrategyDir.list().length > 0) {
            quaduiArgs.add("-s");
        } else if (fieldOverlayDir.exists() && fieldOverlayDir.list().length > 0) {
            quaduiArgs.add("-f");
        } else {
            quaduiArgs.add("-n");
        }
        
        for (String model : models) {
            quaduiArgs.add("-" + model.toLowerCase());
        }
        if (Arrays.binarySearch(models, 0, models.length, "JSON") < 0) {
            quaduiArgs.add("-json");
        }
        quaduiArgs.add(acebFile.getAbsolutePath());
        if (seasonalStrategyDir.exists() && seasonalStrategyDir.list().length > 0 || fieldOverlayDir.exists() && fieldOverlayDir.list().length > 0) {
            if (linkageDir.exists() && linkageDir.list().length > 0) {
                quaduiArgs.add(linkageDir.listFiles()[0].getAbsolutePath());
            } else {
                quaduiArgs.add("");
            }
        }
        if (fieldOverlayDir.exists() && fieldOverlayDir.list().length > 0) {
            quaduiArgs.add(fieldOverlayDir.listFiles()[0].getAbsolutePath());
        }
        if (seasonalStrategyDir.exists() && seasonalStrategyDir.list().length > 0) {
            quaduiArgs.add(seasonalStrategyDir.listFiles()[0].getAbsolutePath());
        }
        quaduiArgs.add(retOutDir.getAbsolutePath());
        
        ProcessBuilder pb = new ProcessBuilder(quaduiArgs.toArray(new String[]{}));
        pb.directory(new File("libs"));
        pb.redirectErrorStream(true);
        File log = Paths.get(retOutDir.getAbsolutePath(), "quadui.log").toFile();
        pb.redirectOutput(log);
        Process process = pb.start();
        try {
            int existCode = process.waitFor();
            LOG.info("Quit with " + existCode);
            
            JSONObject ret = new JSONObject();
            for (File f : retOutDir.listFiles()) {
                if (f.isDirectory()) {
                    java.nio.file.Path tranRetFile = Paths.get(f.getAbsolutePath(), f.getName() + "_Input.zip");
                    if (tranRetFile.toFile().exists()) {
                        byte[] buff = Files.readAllBytes(tranRetFile);
                        String data = Base64.getEncoder().encodeToString(buff);
                        ret.put(f.getName().toLowerCase(), data);
                    }
                } else if (f.getName().endsWith(".aceb")) {
                    byte[] buff = Files.readAllBytes(f.toPath());
                    String data = Base64.getEncoder().encodeToString(buff);
                    ret.put("aceb", data);
                } else if (f.getName().endsWith(".json")) {
                    byte[] buff = Files.readAllBytes(f.toPath());
                    String data = new String(buff, StandardCharsets.UTF_8);
                    ret.put("json", data);
                } else if (f.getName().endsWith(".dome")) {
                    byte[] buff = Files.readAllBytes(f.toPath());
                    String data = Base64.getEncoder().encodeToString(buff);
                    ret.put("dome", data);
                    try (Scanner scanner = new Scanner(new GZIPInputStream(new FileInputStream(f)), "UTF-8").useDelimiter("\\A")) {
                        String json = scanner.next();
                        ret.put("dome_json", json);
                    }
                } else if (f.getName().endsWith(".alnk")) {
                    byte[] buff = Files.readAllBytes(f.toPath());
                    String data = new String(buff, StandardCharsets.UTF_8);
                    ret.put("linkage", data);
                }
            }
            
            byte[] buff = Files.readAllBytes(log.toPath());
            String data = new String(buff, StandardCharsets.UTF_8);
            ret.put("log", data);
            ret.put("data_set_name", dataSetName);
            FileUtils.deleteDirectory(workDir);
            LOG.info("Translation for session {} is done", request.session().id());
            return ret;
        } catch (Exception ex) {
            LOG.warn("Translation for session {} is failed by: {}", request.session().id(), ex.getMessage());
            ex.printStackTrace(System.err);
            FileUtils.deleteDirectory(workDir);
            return new JSONObject().put("errors", ex.getMessage());
        }
    }
    
    private static void dumpToAceb(File outDir, HashMap data) throws IOException {
        String json = JSONAdapter.toJSON(data);
        AceDataset ace = AceParser.parse(json);
        ace.linkDataset();
        AceGenerator.generateACEB(outDir, ace);
    }
}
