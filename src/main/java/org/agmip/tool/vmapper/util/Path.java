package org.agmip.tool.vmapper.util;

import ch.qos.logback.classic.Logger;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.nio.file.Paths;
import java.util.HashMap;
import lombok.*;
import org.agmip.tool.vmapper.Main;
import org.slf4j.LoggerFactory;

public class Path {

    public static final Logger LOG = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    // The @Getter methods are needed in order to access
    public static class Web {
        @Getter public static final String URL_ROOT = Config.get("URL_ROOT");
        @Getter public static final String INDEX = "/index";

        public static class Tools {
            @Getter private static final String PACKAGE = Config.get("URL_TOOLS_ROOT");
            @Getter public static final String UNIT_MASTER = PACKAGE + "/unit";
            @Getter public static final String DATA_FACTORY = PACKAGE + "/data_factory";
            @Getter public static final String VMAPPER = PACKAGE + "/vmapper";
        }
        
        public static class Data {
            @Getter private static final String PACKAGE = Config.get("URL_DATA_ROOT");
            @Getter public static final String UNIT_LOOKUP = PACKAGE + "/unit/lookup";
            @Getter public static final String UNIT_CONVERT = PACKAGE + "/unit/convert";
            @Getter public static final String LOAD_FILE = PACKAGE + "/util/load_file";
            @Getter public static final String TRANSLATE = PACKAGE + "/translate";
        }
    }
    
    public static class Template {
        public final static String INDEX = "index.ftl";
        public static final String NOT_FOUND = "notFound.ftl";
        
        public static class Tools {
            private static final String PACKAGE = Tools.class.getSimpleName().toLowerCase();
            public static final String UNIT_MASTER = PACKAGE + "/unit_master.ftl";
            public static final String VMAPPER = PACKAGE + "/vmapper.ftl";
            public static final String DATA_FACTORY = PACKAGE + "/data_factory.ftl";
        }
        
        public static class Translator {
            private static final String PACKAGE = Translator.class.getSimpleName().toLowerCase();
            public static final String DSSAT_EXP = PACKAGE + "/xfile_template.ftl";
        }
    }
    
    public static class Folder {
        public final static String DATA_DIR = Config.get("DATA_DIR"); //"Data";
        public final static String TASK_DIR = Config.get("TASK_DIR"); //"Task";
        public final static String ICASA_DIR = Config.get("ICASA_DIR"); //"ICASA";
        public final static String ICASA_CROP_CODE = Config.get("ICASA_CROP_CODE"); //"Crop_codes.csv";
        public final static String ICASA_MGN_CODE = Config.get("ICASA_MGN_CODE"); //"Management_codes.csv";
        public final static String ICASA_OTH_CODE = Config.get("ICASA_OTH_CODE"); //"Other_codes.csv";
        public final static String ICASA_MGN_VAR = Config.get("ICASA_MGN_VAR"); //"Management_info.csv";
        public final static String ICASA_OBV_VAR = Config.get("ICASA_OBV_VAR"); //"Measured_data.csv";
        public final static int DEF_PORT = Integer.parseInt(Config.get("DEF_PORT")); //8081;

        public static File getCropCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_CROP_CODE).toFile();
            return ret;
        }
        
        public static File getICASAFile(String sheetName) {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, sheetName + ".csv").toFile();
            return ret;
        }
        
        public static File getICASAMgnCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_MGN_CODE).toFile();
            return ret;
        }
        
        public static File getICASAOthCodeFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_OTH_CODE).toFile();
            return ret;
        }
        
        public static File getICASAMgnVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_MGN_VAR).toFile();
            return ret;
        }
        
        public static File getICASAObvVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_OBV_VAR).toFile();
            return ret;
        }
    }
    
    public static class Config {
        private final static HashMap<String, String> CONFIGS = readConfig();
        private static HashMap<String, String> readConfig() {
            HashMap<String, String> ret = new HashMap();
            ret.put("DATA_DIR", "Data");
            ret.put("TASK_DIR", "Task");
            ret.put("ICASA_DIR", "ICASA");
            ret.put("ICASA_CROP_CODE", "Crop_codes.csv");
            ret.put("ICASA_MGN_CODE", "Management_codes.csv");
            ret.put("ICASA_OTH_CODE", "Other_codes.csv");
            ret.put("ICASA_MGN_VAR", "Management_info.csv");
            ret.put("ICASA_OBV_VAR", "Measured_data.csv");
            ret.put("DEF_PORT", "8081");
            ret.put("URL_ROOT", "/");
            ret.put("URL_TOOLS_ROOT", Web.Tools.class.getSimpleName().toLowerCase());
            ret.put("URL_DATA_ROOT", Web.Data.class.getSimpleName().toLowerCase());
            try {
                BufferedReader br = new BufferedReader(new FileReader(new File("config.ini")));
                String line;
                while ((line = br.readLine()) != null) {
                    int dividerIdx = line.indexOf("=");
                    if (dividerIdx > 0) {
                        String key = line.substring(0, dividerIdx).trim();
                        String value = line.substring(dividerIdx + 1).trim();
                        if (!value.isEmpty()) {
                            ret.put(key, value);
                        }
                    }
                }
            } catch (FileNotFoundException e) {
                LOG.warn("Please create config.ini to setup necessery configuration");
            } catch(Exception ex) {
                ex.printStackTrace(System.err);
            }
            System.out.println("Load config as " + ret.toString());
            return ret;
        }
        public static String get(String key) {
            String ret = CONFIGS.get(key);
            if (ret == null) {
                ret = "";
            }
            if (key.endsWith("_DIR")) {
                File dir = new File(ret);
                if (!dir.exists()) {
                    dir.mkdirs();
                }
            }
            return ret;
        }
    }
}
