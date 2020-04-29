package org.dssat.tool.gbuilder2d.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import lombok.*;

public class Path {

    // The @Getter methods are needed in order to access
    public static class Web {
        @Getter public static final String INDEX = "/index";
        @Getter public static final String REGISTER = "/register";
        @Getter public static final String LOGIN = "/login";
        @Getter public static final String LOGOUT = "/logout";
        @Getter public static final String UPLOAD = "/upload";
        
        public static class Demo {
            private static final String PACKAGE = "/" + Demo.class.getSimpleName().toLowerCase();
            public static final String IRRLIST = PACKAGE + "/irrlist";
            public static final String AUTOMAIL = PACKAGE + "/automail";
            public static final String GBUILDER1D = PACKAGE + "/gbuilder1d";
            public static final String GBUILDER2D = PACKAGE + "/gbuilder2d";
            public static final String XBUILDER2D = PACKAGE + "/xbuilder2d";
            public static final String METALIST = PACKAGE + "/metalist";
            public static final String XML_EDITOR = PACKAGE + "/xmleditor";
            public static final String UNIT_MASTER = PACKAGE + "/unit";
            public static final String DATA_FACTORY = PACKAGE + "/data_factory";
            public static final String VMAPPER = PACKAGE + "/vmapper";
        }
        
        public static class Data {
            private static final String PACKAGE = "/" + Data.class.getSimpleName().toLowerCase();
            public static final String CULTIVAR = PACKAGE + "/cultivar";
            public static final String UNIT_LOOKUP = PACKAGE + "/unit/lookup";
            public static final String UNIT_CONVERT = PACKAGE + "/unit/convert";
        }
        
        public static class Translator {
            private static final String PACKAGE = "/" + Translator.class.getSimpleName().toLowerCase();
            public static final String DSSAT = PACKAGE + "/dssat";
            public static final String DSSAT_EXP = PACKAGE + "/dssat_exp";
            public static final String XML = PACKAGE + "/xml";
        }
    }
    
    public static class Template {
        public final static String INDEX = "index.ftl";
        public final static String REGISTER = "register.ftl";
        public final static String LOGIN = "login.ftl";
        public final static String UPLOAD = "upload.ftl";
        public static final String NOT_FOUND = "notFound.ftl";
        
        public static class Demo {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String IRRLIST = PACKAGE + "/irrlist.ftl";
            public static final String GBUILDER1D = PACKAGE + "/gbuilder1d.ftl";
            public static final String GBUILDER2D = PACKAGE + "/gbuilder2d.ftl";
            public static final String XBUILDER2D = PACKAGE + "/xbuilder2d.ftl";
            public static final String METALIST = PACKAGE + "/meta_list.ftl";
            public static final String XML_EDITOR = PACKAGE + "/xml_editor.ftl";
            public static final String UNIT_MASTER = PACKAGE + "/unit_master.ftl";
            public static final String DATA_FACTORY = PACKAGE + "/data_factory.ftl";
        }
        
        public static class Translator {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String DSSAT_EXP = PACKAGE + "/xfile_template.ftl";
            public static final String XML = PACKAGE + "/xml_template.ftl";
        }
    }
    
    public static class Folder {
        public final static String DATA_DIR = Config.get("DATA_DIR"); //"Data";
        public final static String DSSAT_DIR = Config.get("DSSAT_DIR"); //"Data\\DSSAT47";
        public final static String DATA_SOIL_DIR = Config.get("DATA_SOIL_DIR"); //"Soil";
        public final static String DATA_WTH_DIR = Config.get("DATA_WTH_DIR"); //"Weather";
        public final static String CULTIVAR_DIR = Config.get("CULTIVAR_DIR"); //"Genotype";
        public final static String SOIL_LIST = Config.get("SOIL_LIST"); //"soil_list.json";
        public final static String WTH_LIST = Config.get("WTH_LIST"); //"wth_list.json";
        public final static String CULTIVAR_LIST = Config.get("CULTIVAR_LIST"); //"crop_list.csv";
        public final static String ICASA_DIR = Config.get("ICASA_DIR"); //"ICASA";
        public final static String ICASA_MGN_CODE = Config.get("ICASA_MGN_CODE"); //"Management_codes.csv";
        public final static String ICASA_MGN_VAR = Config.get("ICASA_MGN_VAR"); //"Management_info.csv";
        public final static String ICASA_OBV_VAR = Config.get("ICASA_OBV_VAR"); //"Measured_data.csv";
        public final static String DSSAT_VERSION = Config.get("DSSAT_VERSION"); //"47";
        public static File getCulFile(String modelName) {
            File ret = Paths.get(DSSAT_DIR, CULTIVAR_DIR, getDSSATFileNameWithVer(modelName, "CUL")).toFile();
            return ret;
        }
        public static File getCulListFile() {
            File ret = Paths.get(DATA_DIR, CULTIVAR_LIST).toFile();
            return ret;
        }
        public static File getSoilListDir() {
            File ret = Paths.get(DSSAT_DIR, DATA_SOIL_DIR).toFile();
            return ret;
        }
        public static File getSoilListFile() {
            File ret = Paths.get(DATA_DIR, SOIL_LIST).toFile();
            return ret;
        }
        public static File getWthListDir() {
            File ret = Paths.get(DSSAT_DIR, DATA_WTH_DIR).toFile();
            return ret;
        }
        public static File getWthListFile() {
            File ret = Paths.get(DATA_DIR, WTH_LIST).toFile();
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
        
        public static File getICASAMgnVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_MGN_VAR).toFile();
            return ret;
        }
        
        public static File getICASAObvVarFile() {
            File ret = Paths.get(DATA_DIR, ICASA_DIR, ICASA_OBV_VAR).toFile();
            return ret;
        }
        
        public static String getDSSATFileNameWithVer(String pref) {
            return getDSSATFileNameWithVer(pref, null);
        }
        
        public static String getDSSATFileNameWithVer(String pref, String ext) {
            if (pref == null || pref.trim().isEmpty()) {
                return "";
            } else if (ext == null || ext.trim().isEmpty()) {
                return pref.trim().toUpperCase() + "0" + DSSAT_VERSION;
            } else {
                return pref.trim().toUpperCase() + "0" + DSSAT_VERSION + "." + ext.trim().toUpperCase();
            }
        }
    }
    
    public static class Config {
        private final static HashMap<String, String> CONFIGS = readConfig();
        private static HashMap<String, String> readConfig() {
            HashMap<String, String> ret = new HashMap();
            ret.put("DATA_DIR", "Data");
            ret.put("DSSAT_DIR", Paths.get("Data", "DSSAT47").toString());
            ret.put("DATA_SOIL_DIR", "Soil");
            ret.put("DATA_WTH_DIR", "Weather");
            ret.put("CULTIVAR_DIR", "Genotype");
            ret.put("SOIL_LIST", "soil_list.json");
            ret.put("WTH_LIST", "wth_list.json");
            ret.put("CULTIVAR_LIST", "crop_list.csv");
            ret.put("ICASA_DIR", "ICASA");
            ret.put("ICASA_MGN_CODE", "Management_codes.csv");
            ret.put("ICASA_MGN_VAR", "Management_info.csv");
            ret.put("ICASA_OBV_VAR", "Measured_data.csv");
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
            return ret;
        }
    }
}
