package org.dssat.tool.gbuilder2d.util;

import java.io.File;
import java.nio.file.Paths;
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
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String IRRLIST = PACKAGE + "/irrlist";
            public static final String AUTOMAIL = PACKAGE + "/automail";
            public static final String GBUILDER1D = PACKAGE + "/gbuilder1d";
            public static final String GBUILDER2D = PACKAGE + "/gbuilder2d";
            public static final String XBUILDER2D = PACKAGE + "/xbuilder2d";
            public static final String METALIST = PACKAGE + "/metalist";
            public static final String XML_EDITOR = PACKAGE + "/xmleditor";
        }
        
        public static class Data {
            private static final String PACKAGE = Data.class.getSimpleName().toLowerCase();
            public static final String CULTIVAR = PACKAGE + "/cultivar";
        }
        
        public static class Translator {
            private static final String PACKAGE = Translator.class.getSimpleName().toLowerCase();
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
        }
        
        public static class Translator {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String DSSAT_EXP = PACKAGE + "/xfile_template.ftl";
            public static final String XML = PACKAGE + "/xml_template.ftl";
        }
    }
    
    public static class Folder {
        public final static String DATA = "Data";
        public final static String CULTIVAR = "Genotype";
        public final static String CULTIVAR_LIST = "crop_list.csv";
        public final static String ICASA_MGN_CODE = "ICASA_management_code.csv";
        public static final int DSSAT_VERSION = 47;
        public static File getCulFile(String modelName) {
            File ret = Paths.get(DATA, CULTIVAR, getDSSATFileNameWithVer(modelName, "CUL")).toFile();
            return ret;
        }
        public static File getCulListFile() {
            File ret = Paths.get(DATA, CULTIVAR_LIST).toFile();
            return ret;
        }
        public static File getICASAMgnCodeFile() {
            File ret = Paths.get(DATA, ICASA_MGN_CODE).toFile();
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
}
