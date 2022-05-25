package org.agmip.tool.vmapper.util.translator;

import java.io.BufferedReader;
import java.io.CharArrayWriter;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import org.agmip.core.types.TranslatorInput;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Temporal solution for model specific data distribution purpose
 *
 * @author Meng Zhang
 */
public class ModelFileDumperInput implements TranslatorInput {

    private static final Logger LOG = LoggerFactory.getLogger(ModelFileDumperInput.class);

    @Override
    public Map readFile(String file) throws Exception {
        Map ret = new HashMap<>();

        // Check input file
        if (file == null || !file.endsWith(".zip")) {
            LOG.warn("Invalid input file : {}", file);
            return ret;
        }

        // Start handling the zip file
        try(ZipInputStream z = new ZipInputStream(new FileInputStream(file))) {
            ZipEntry ze;
            while ((ze = z.getNextEntry()) != null) {
                String zeName = ze.getName().toLowerCase();
                // If find model specific directory
                if (ze.isDirectory() && zeName.endsWith("_specific/")) {
                    String model = getModelName(zeName);
                    LOG.info("Detected model specific folder {} for {} model", zeName, model);
                    ret.put(model, new HashMap<>());
                }
                // If find file under model specific folder
                else if (zeName.contains("_specific/") && !ze.isDirectory()) {
                    String model = getModelName(zeName);
                    HashMap<String, char[]> culFiles = (HashMap<String, char[]>) ret.get(model);
                    if (culFiles == null) {
                        LOG.warn("Incorrect folder structure detected for {}", zeName);
                        culFiles = new HashMap();
                        ret.put(model, culFiles);
                    }
                    String culFileName = getFileName(ze.getName());
                    if (culFiles.containsKey(culFileName)) {
                        LOG.warn("Repeated model specific file name detected for {}, will be renamed", zeName);
                        int fix = 1;
                        do {
                            culFileName = autoRename(culFileName, "_" + fix);
                            fix++;
                        } while (culFiles.containsKey(culFileName));
                    }
                    char[] buf = getBuf(z, ze);
                    culFiles.put(culFileName, buf);
                }
            }
        }

        return ret;
    }

    private String getModelName(String zeName) {
        String[] paths = zeName.split("/");
        int id = paths.length - 1;
        while (id > 0 && !paths[id].contains("_specific")) {
            id--;
        }
        return paths[id].replaceAll("_.*", "");
    }
    
    private String getFileName(String zeName) {
        String[] paths = zeName.split("/");
        return paths[paths.length - 1];
    }
    
    private String autoRename(String fileName, String fix) {
        int id = fileName.lastIndexOf(".");
        return fileName.substring(0, id) + fix + fileName.substring(id);
    }
    
    private static char[] getBuf(InputStream in, ZipEntry entry) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(in, "utf-8"));
        char[] buf;
        long size = entry.getSize();

        if (size > 0 && size <= Integer.MAX_VALUE) {
            buf = new char[(int) size];
            br.read(buf);
        } else {
            char[] b = new char[1024];
            CharArrayWriter cw = new CharArrayWriter();
            int chunk;
            while ((chunk = br.read(b)) > 0) {
                cw.write(b, 0, chunk);
            }
            buf = cw.toCharArray();
        }

        return buf;
    }
}

