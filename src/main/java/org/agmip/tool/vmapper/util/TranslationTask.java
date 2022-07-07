package org.agmip.tool.vmapper.util;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipInputStream;
import org.agmip.ace.AceDataset;
import org.agmip.ace.AceExperiment;
import org.agmip.ace.AceSoil;
import org.agmip.ace.AceWeather;
import org.agmip.ace.io.AceParser;
import org.agmip.common.Functions;

import org.agmip.core.types.TranslatorInput;
import org.agmip.tool.vmapper.util.translator.ModelFileDumperInput;
import org.agmip.translators.csv.CSVInput;
import org.agmip.translators.dssat.DssatControllerInput;
import org.agmip.translators.agmip.AgmipInput;
import org.agmip.translators.apsim.ApsimReader;
import org.agmip.util.JSONAdapter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Meng Zhang
 */
public class TranslationTask {
    
    private static final Logger LOG = LoggerFactory.getLogger(TranslationTask.class);
    
    public static HashMap<String, Object> parseToJSON(List<File> inputs) {
        HashMap<String, HashMap<String, TranslatorInput>> fileTranslatorsMap = new HashMap();
        HashMap<String, Object> output = new HashMap<>();
        for (File input : inputs) {
            HashMap<String, TranslatorInput> translators = new HashMap<>();
            String file = input.getPath();
            fileTranslatorsMap.put(file, translators);
            if (file.toLowerCase().endsWith(".zip")) {
                try (ZipInputStream z = new ZipInputStream(new BufferedInputStream(new FileInputStream(input)))) {
                    ZipEntry ze;
                    while ((ze = z.getNextEntry()) != null) {
                        String zeName = ze.getName().toLowerCase();
                        if (zeName.endsWith(".csv")) {
                            translators.put("CSV", new CSVInput());
        //                    break;
                        } else if (zeName.endsWith(".wth") || 
                                zeName.endsWith(".sol") ||
                                zeName.matches(".+\\.\\d{2}[xat]")) {
                            translators.put("DSSAT", new DssatControllerInput());
        //                    break;
                        } else if (zeName.endsWith(".agmip")) {
                            LOG.debug("Found .AgMIP file {}", ze.getName());
                            translators.put("AgMIP", new AgmipInput());
        //                    break;
                        } else if (zeName.endsWith(".met")) {
                            LOG.debug("Found .met file {}", ze.getName());
                            translators.put("APSIM", new ApsimReader());
        //                    break;
                        } else if (zeName.endsWith(".aceb")) {
                            LOG.debug("Found .ACEB file {}", ze.getName());
                            translators.put("ACEB", new AcebInput());
                        } else if (zeName.endsWith(".json")) {
                            LOG.debug("Found .JSON file {}", ze.getName());
                            translators.put("JSON", new JsonInput());
                        } else if (ze.isDirectory() && zeName.endsWith("_specific/")) {
                            LOG.debug("Found model specific folder {}", ze.getName());
                            translators.put("ModelSpec", new ModelFileDumperInput());
                        }
                    }
                    if (translators.isEmpty()) {
                        translators.put("DSSAT", new DssatControllerInput());
                    }
                } catch (IOException ex) {
                    
                }
            } else if (file.toLowerCase().endsWith(".agmip")) {
                translators.put("AgMIP", new AgmipInput());
            } else if (file.toLowerCase().endsWith(".met")) {
                translators.put("APSIM", new ApsimReader());
            } else if (file.toLowerCase().endsWith(".csv")) {
                translators.put("CSV", new CSVInput());
            } else if (file.toLowerCase().endsWith(".aceb")) {
                translators.put("ACEB", new AcebInput());
            } else if (file.toLowerCase().endsWith(".json")) {
                translators.put("JSON", new JsonInput());
            } else if (file.toLowerCase().endsWith(".sol") ||
                    file.toLowerCase().endsWith(".wth") ||
                    file.toLowerCase().matches(".+\\.\\d{2}[xat]")) {
                translators.put("DSSAT", new DssatControllerInput());
            } else {
                LOG.error("Unsupported file: {}", file);
                output.put("errors", "Unsupported file: " + file);
            }
        }
        
        try {
            for (String file : fileTranslatorsMap.keySet()) {
                HashMap<String, TranslatorInput> translators = fileTranslatorsMap.get(file);
                for (String key : translators.keySet()) {
                    LOG.info("{} translator is fired to read {}", key, file);
                    Map m = translators.get(key).readFile(file);
                    if (key.equals("ModelSpec")) {
                        output.put("ModelSpec", m);
                    } else {
                        combineResult(output, m);
                    }
                    LOG.debug("{}", output.get("weathers"));
                }
            }
            
            return output;
        } catch (Exception ex) {
//            LOG.error(Functions.getStackTrace(ex));
            LOG.error(ex.toString());
            output.put("errors", ex.toString());
            return output;
        }
    }

    private static void combineResult(HashMap out, Map in) {
        String[] keys = {"experiments", "soils", "weathers"};
        for (String key : keys) {
            ArrayList outArr;
            ArrayList inArr;
            if ((inArr = (ArrayList) in.get(key)) != null && !inArr.isEmpty()) {
                outArr = (ArrayList) out.get(key);
                if (outArr == null) {
                    out.put(key, inArr);
                } else {
                    outArr.addAll(inArr);
                }
            }
        }
    }
    
    private static class JsonInput implements TranslatorInput {

        @Override
        public Map readFile(String file) throws Exception {
            HashMap ret = new HashMap();
            if (file.toLowerCase().endsWith(".zip")) {
                try (ZipFile zf = new ZipFile(file)) {
                    Enumeration<? extends ZipEntry> e = zf.entries();
                    while (e.hasMoreElements()) {
                        ZipEntry ze = (ZipEntry) e.nextElement();
                        LOG.debug("Entering file: " + ze);
                        if (ze.getName().toLowerCase().endsWith(".json")) {
                            combineResult(ret, readJson(zf.getInputStream(ze)));
                        }
                    }
                }
            } else {
                ret = readJson(new FileInputStream(file));
            }
            return ret;
        }
        
        private static HashMap readJson(InputStream fileStream) throws Exception {

            StringBuilder jsonStr = new StringBuilder();
            try (BufferedReader br = new BufferedReader(new InputStreamReader(fileStream))) {
                String line;
                while ((line = br.readLine()) != null) {
                    jsonStr.append(line.trim());
                }
            }
            return JSONAdapter.fromJSON(jsonStr.toString());
        }

    }

    private static class AcebInput implements TranslatorInput {

        @Override
        public Map readFile(String file) throws Exception {
            HashMap ret = new HashMap();
            if (file.toLowerCase().endsWith(".zip")) {
                try (ZipFile zf = new ZipFile(file)) {
                    Enumeration<? extends ZipEntry> e = zf.entries();
                    while (e.hasMoreElements()) {
                        ZipEntry ze = (ZipEntry) e.nextElement();
                        LOG.debug("Entering file: " + ze);
                        if (ze.getName().toLowerCase().endsWith(".aceb")) {
                            combineResult(ret, readAceb(zf.getInputStream(ze)));
                        }
                    }
                }
            } else {
                ret = readAceb(new FileInputStream(file));
            }
            return ret;
        }
        
        private static HashMap readAceb(InputStream fileStream) throws Exception {
            HashMap data = new HashMap();
            try {
                AceDataset ace = AceParser.parseACEB(fileStream);
                ace.linkDataset();
                ArrayList<HashMap> arr;
                // Experiments
                arr = new ArrayList();
                for (AceExperiment exp : ace.getExperiments()) {
                    arr.add(JSONAdapter.fromJSON(new String(exp.rebuildComponent())));
                }
                if (!arr.isEmpty()) {
                    data.put("experiments", arr);
                }
                // Soils
                arr = new ArrayList();
                for (AceSoil soil : ace.getSoils()) {
                    arr.add(JSONAdapter.fromJSON(new String(soil.rebuildComponent())));
                }
                if (!arr.isEmpty()) {
                    data.put("soils", arr);
                }
                // Weathers
                arr = new ArrayList();
                for (AceWeather wth : ace.getWeathers()) {
                    arr.add(JSONAdapter.fromJSON(new String(wth.rebuildComponent())));
                }
                if (!arr.isEmpty()) {
                    data.put("weathers", arr);
                }
            } catch (IOException ex) {
                LOG.error(Functions.getStackTrace(ex));
            }
            return data;
        }
    }

}
