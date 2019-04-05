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
        @Getter public static final String Worker = "/worker";
        
        public static class Simulation {
            private static final String PACKAGE = "/" + Simulation.class.getSimpleName().toLowerCase();
            @Getter public static final String AFSIRS = PACKAGE + "/afsirs";
            @Getter public static final String AFSIRS_RESULT = PACKAGE + "/afsirs_result";
            @Getter public static final String AFSIRS_LOAD = PACKAGE + "/afsirs_load";
            @Getter public static final String AFSIRS_WAIT = PACKAGE + "/afsirs_wait";
        }
        
        public static class WaterUse {
            private static final String PACKAGE = "/" + WaterUse.class.getSimpleName().toLowerCase() + "/permit";
            @Getter public static final String CREATE = PACKAGE + "/create";
            @Getter public static final String LIST = PACKAGE + "/list";
            @Getter public static final String SEARCH = PACKAGE + "/search";
            @Getter public static final String FIND = PACKAGE + "/find";
            @Getter public static final String AFSIRS = PACKAGE + "/afsirs";
        }
        
        public static class DataTools {
            private static final String PACKAGE = "/" + DataTools.class.getSimpleName().toLowerCase();
            @Getter public static final String SOILMAP = PACKAGE + "/soilmap/";
            @Getter public static final String WTHSHEET = PACKAGE + "/wthsheet/";
            
        }
            
        public static class SoilData {
            private static final String PACKAGE = "/" + SoilData.class.getSimpleName().toLowerCase();
            @Getter public static final String LIST = PACKAGE + "/list";
            @Getter public static final String CREATE = PACKAGE + "/create";
            @Getter public static final String FIND = PACKAGE + "/find";
            @Getter public static final String DELETE = PACKAGE + "/delete";
        }
        
        public static class Demo {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String IRRLIST = PACKAGE + "/irrlist";
            public static final String AUTOMAIL = PACKAGE + "/automail";
            public static final String GBUILDER1D = PACKAGE + "/gbuilder1d";
            public static final String GBUILDER2D = PACKAGE + "/gbuilder2d";
            public static final String XBUILDER2D = PACKAGE + "/xbuilder2d";
            public static final String METALIST = PACKAGE + "/metalist";
        }
        
        public static class Translator {
            private static final String PACKAGE = Translator.class.getSimpleName().toLowerCase();
            public static final String DSSAT = PACKAGE + "/dssat";
            public static final String DSSAT_EXP = PACKAGE + "/dssat_exp";
        }
        
//        public static class Worker {
//            private static final String PACKAGE = "/" + Worker.class.getSimpleName().toLowerCase();;
//            @Getter public static final String LOGIN = PACKAGE + "/login";
//            @Getter public static final String LOGOUT = PACKAGE + "/logout";
//        }
    }
    
    public static class Template {
        public final static String INDEX = "index.ftl";
        public final static String REGISTER = "register.ftl";
        public final static String LOGIN = "login.ftl";
        public final static String UPLOAD = "upload.ftl";
        public static final String NOT_FOUND = "notFound.ftl";
        
        public static class Simulation {
            private static final String PACKAGE = Simulation.class.getSimpleName().toLowerCase();
            public static final String AFSIRS = PACKAGE + "/afsirs.ftl";
            public static final String AFSIRS_RESULT = PACKAGE + "/afsirs_result.ftl";
            public static final String AFSIRS_RESULT_ASYN = PACKAGE + "/afsirs_result_asyn.ftl";
        }
        
        public static class WaterUse {
            private static final String PACKAGE = WaterUse.class.getSimpleName().toLowerCase() + "/permit";
            public static final String CREATE = PACKAGE + "/create.ftl";
            public static final String LIST = PACKAGE + "/list.ftl";
            public static final String SEARCH = PACKAGE + "/search.ftl";
            public static final String DETAIL = PACKAGE + "/detail.ftl";
            public static final String AFSIRS = PACKAGE + "/afsirs.ftl";
        }
        
        public static class DataTools {
            private static final String PACKAGE = DataTools.class.getSimpleName().toLowerCase();
            public static final String SOILMAP = PACKAGE + "/soilmap.ftl";
            public static final String WTHSHEET = PACKAGE + "/wthsheet.ftl";
        }
        
        public static class SoilData {
            private static final String PACKAGE = SoilData.class.getSimpleName().toLowerCase();
            public static final String LIST = PACKAGE + "/list.ftl";
        }
        
        public static class Demo {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String IRRLIST = PACKAGE + "/irrlist.ftl";
            public static final String GBUILDER1D = PACKAGE + "/gbuilder1d.ftl";
            public static final String GBUILDER2D = PACKAGE + "/gbuilder2d.ftl";
            public static final String XBUILDER2D = PACKAGE + "/xbuilder2d.ftl";
            public static final String METALIST = PACKAGE + "/meta_list.ftl";
        }
        
        public static class Translator {
            private static final String PACKAGE = Demo.class.getSimpleName().toLowerCase();
            public static final String DSSAT_EXP = PACKAGE + "/xfile_template.ftl";
        }
    }
    
    public static class Folder {
        public final static String DATA = "Data";
        public final static String CULTIVAR = "Genotype";
        public final static String CULTIVAR_LIST = "crop_list.csv";
        public static final int DSSAT_VERSION = 47;
        public static File getCulFile(String modelName) {
            File ret = Paths.get(DATA, CULTIVAR, getDSSATFileNameWithVer(modelName, "CUL")).toFile();
            return ret;
        }
        public static File getCulListFile() {
            File ret = Paths.get(DATA, CULTIVAR_LIST).toFile();
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
