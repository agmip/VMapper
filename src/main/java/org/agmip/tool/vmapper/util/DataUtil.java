package org.agmip.tool.vmapper.util;

import au.com.bytecode.opencsv.CSVReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Meng Zhang
 */
public class DataUtil {
    
    private static final ArrayList<JSONObject> CUL_METADATA_LIST = new ArrayList();
    private static final ArrayList<JSONObject> ICASA_CROP_CODE_LIST = loadICASACropCode();
    private static final JSONObject ICASA_MGN_CODE_MAP = loadICASAMgnCode();
    private static final JSONObject ICASA_MGN_VAR_MAP = loadICASAMgnVarCode();
    private static final JSONObject ICASA_OBV_VAR_MAP = loadICASAObvVarCode();
    
    private static final String ICASA_MGN_CODE_HEADER_VAR_CODE = "code_display";
    private static final String ICASA_MGN_CODE_HEADER_VAR_CODE_VAL = "code";
    private static final String ICASA_MGN_CODE_HEADER_VAR_TEXT_VAL = "description";
    private static final String ICASA_MGN_VAR_HEADER_VAR_CODE = "code_display";
    private static final String ICASA_MGN_VAR_HEADER_VAR_DESC = "description";
    private static final String ICASA_MGN_VAR_HEADER_VAR_UNIT = "unit_or_type";
    private static final String ICASA_MGN_VAR_HEADER_VAR_DATASET = "dataset";
    private static final String ICASA_MGN_VAR_HEADER_VAR_SUBSET = "subset";
    private static final String ICASA_MGN_VAR_HEADER_VAR_GROUP = "group";
    private static final String ICASA_MGN_VAR_HEADER_VAR_SUBGROUP = "subgroup";
    private static final String ICASA_MGN_VAR_HEADER_VAR_ORDER = "set_group_order";
    private static final String ICASA_OBV_VAR_HEADER_VAR_SUBGROUP = "sub-group";
    private static final String ICASA_MGN_VAR_HEADER_VAR_RATING = "agmip_data_entry";
    private static final String ICASA_CROP_CODE_HEADER_CROP_CODE = "crop_code";
    private static final String ICASA_CROP_CODE_HEADER_COMMON_NAME = "common_name";
//    private static final String ICASA_CROP_CODE_HEADER_LATIN_NAME = "latin_name";
//    private static final String ICASA_CROP_CODE_HEADER_DSSAT_CODE = "DSSAT_code";
//    private static final String ICASA_CROP_CODE_HEADER_APSIM_CODE = "APSIM_code";
    private static final int ICASA_MIN_ACCEPTABLE_RATING_LEVEL = -1;
    private static Properties versionProperties = loadProperties();

    public static ArrayList getCulMetaDataList() {
        return CUL_METADATA_LIST;
    }
    
    public static JSONObject getCulDataList(File culFile) {
        JSONObject ret = new JSONObject();
        if (!culFile.exists()) {
            return ret;
        }
        String line;
        ArrayList<String> titles = new ArrayList();
        
        String titleLine = "";
        boolean titleLinePrinted = false;
        
        boolean titleFlg = false; 
        try (BufferedReader br = new BufferedReader(new FileReader(culFile))) {
            while ((line = br.readLine()) != null) {
                if (line.startsWith("!")) {
                } else if (line.startsWith("*")) {
                } else if (line.startsWith("@")) {
                    titleFlg = true;
                    titles = new ArrayList();
                    titleLinePrinted = false;
                    titleLine = line;
                    if (culFile.getName().toUpperCase().startsWith("SCCSP")) {
                        // TODO SCCSP need special handling for header
                        String[] items = {"LFMAX", "PHTMX", "Stalk", "Sucro", "Null1", "PLF1", "PLF2", "Gamma", "StkB", "StkM", "Null3", "SIZLF", "LIsun", "LIshd", "Null4", "TB(1)", "TO1(1)", "TO2(1)", "TM(1)", "PI1", "PI2", "DTPI", "LSFAC", "Null5", "LI1", "TELOM", "TB(2)", "TO1(2)", "TO2(2)", "TM(2)", "Ph1P", "Ph1R", "Ph2", "Ph3", "Ph4", "StHrv", "RTNFAC", "MinGr", "Null7", "RES30C", "RLF30C", "R30C2"};
                        for (String item : items) {
                            titles.add(item.toLowerCase());
                        }
                    } else if (!culFile.getName().toUpperCase().startsWith("RIORZ")) {
                        String[] items = line.substring(36).trim().split("\\s+");
                        for (String item : items) {
                            titles.add(item.toLowerCase());
                        }
                    }
                    
                } else if (titleFlg && !line.trim().isEmpty()) {
                    JSONObject culData = new JSONObject();
                    culData.put("cul_id", line.substring(0, 6).trim());
                    culData.put("cul_name", line.substring(6, 23).trim());
                    culData.put("exp_num", line.substring(23, 29).trim());
                    if (culFile.getName().toUpperCase().startsWith("RIORZ")) {
                        culData.put("oryza_file_name", line.substring(23).trim());
                    } else {
                        culData.put("eco_num", line.substring(29, 36).trim());
                        int end = line.indexOf("!");
                        if (end < 0) end = line.length();
                        String[] params = line.substring(36, end).trim().split("\\s+|\\|");

                        int limit = Math.min(params.length, titles.size());
                        for (int i = 0; i < limit; i++) {
                            culData.put(titles.get(i), params[i].trim());
                        }
                        
//                        if (params.length != titles.size()) {
//                            if (!titleLinePrinted) {
//                                System.out.print(titleLine);
//                                System.out.print("\t");
//                                System.out.println(culFile.getName());
//                                titleLinePrinted = true;
//                            }
//                            System.out.print(line.trim());
//                            System.out.println("\t" + titles.size() + "\t" + params.length);
//                        }
                    }
                    ret.put(culData.get("cul_id"), culData);
                }
            }
        } catch (FileNotFoundException ex) {
            ex.printStackTrace(System.out);
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }
    
    public static boolean isFallow(String crid) {
        if (crid == null) {
            return true;
        } else {
            crid = crid.trim();
            return crid.isEmpty() || crid.equals("FA") || crid.equals("FAL");
        }
    }
    
    private static JSONObject loadICASAMgnCode() {
        JSONObject ret = new JSONObject();
        File file = Path.Folder.getICASAMgnCodeFile();
        if (!file.exists()) {
            ICASAUtil.syncICASA();
        }

        try (CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',')) {
            int varNameIdx = -1;
            int codeIdx = -1;
            int textIdx = -1;
            String[] nextLine = reader.readNext();
            if (nextLine!= null) {
                ArrayList<String> titles = new ArrayList();
                for (String title : nextLine) {
                    titles.add(title.toLowerCase());
                }
                varNameIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_CODE);
                codeIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_CODE_VAL);
                textIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_TEXT_VAL);
                if (varNameIdx < 0 || codeIdx < 0 || textIdx < 0) {
                    throw new IOException("Missing required column in ICASA management code defination file!");
                }
            }
            int minLength = Math.min(Math.min(varNameIdx, codeIdx), textIdx);
            while ((nextLine = reader.readNext()) != null) {
                if (nextLine[0].startsWith("!") || nextLine.length <= minLength) {
                } else if (!nextLine[varNameIdx].trim().isEmpty()) {
                    if (nextLine[varNameIdx].equalsIgnoreCase("EC???")) {
                        nextLine[varNameIdx] = "ECDYL, ECRAD, ECMAX, ECMIN, ECRAI, ECCO2, ECDEW, ECWND";
                    }
                    String[] varNames = nextLine[varNameIdx].split("\\s*,\\s*");
                    if (varNames.length == 0) {
                        throw new IOException("Incorrect variable name [" + nextLine[varNameIdx] + "] used in ICASA management code defination file!");
                    }
                    JSONObject codeDef;
                    if (ret.containsKey(varNames[0].toLowerCase())) {
                        codeDef = ret.getAsObj(varNames[0].toLowerCase());
                    } else {
                        codeDef = new JSONObject();
                        for (String varName : varNames) {
                            ret.put(varName.toLowerCase(), codeDef);
                        }
                    }
                    if (!nextLine[codeIdx].trim().isEmpty()) {
                        codeDef.put(nextLine[codeIdx].trim(), nextLine[textIdx].trim());
                    }
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }

    private static ArrayList<JSONObject> loadICASACropCode() {
        ArrayList<JSONObject> ret = new ArrayList();
        File file = Path.Folder.getCropCodeFile();
        if (!file.exists()) {
            ICASAUtil.syncICASA();
        }

        try (CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',')) {
            int cropCodeIdx = -1;
            int commonNameIdx = -1;
//            int latinNameIdx = -1;
//            int dssatCodeIdx = -1;
//            int apsimCodeIdx = -1;
            ArrayList<String> titles = new ArrayList();
            String[] nextLine = reader.readNext();
            if (nextLine!= null) {
                for (String title : nextLine) {
                    titles.add(title.toLowerCase());
                }
                cropCodeIdx = titles.indexOf(ICASA_CROP_CODE_HEADER_CROP_CODE);
                commonNameIdx = titles.indexOf(ICASA_CROP_CODE_HEADER_COMMON_NAME);
//                latinNameIdx = titles.indexOf(ICASA_CROP_CODE_HEADER_LATIN_NAME);
//                dssatCodeIdx = titles.indexOf(ICASA_CROP_CODE_HEADER_DSSAT_CODE);
//                apsimCodeIdx = titles.indexOf(ICASA_CROP_CODE_HEADER_APSIM_CODE);
                if (cropCodeIdx < 0 || commonNameIdx < 0) {
                    throw new IOException("Missing required column in ICASA crop code defination file!");
                }
            }
            int minLength = Math.min(cropCodeIdx, commonNameIdx);
            while ((nextLine = reader.readNext()) != null) {
                if (nextLine[0].startsWith("!") || nextLine.length <= minLength) {
                } else {
                    String cropCode = nextLine[cropCodeIdx].trim();
                    if (cropCode.isEmpty()) {
                        continue;
                    }
                    JSONObject codeDef = new JSONObject();
                    for (int i = 0; i < titles.size(); i++) {
                        if (i < nextLine.length && !nextLine[i].trim().isEmpty()) {
                            codeDef.put(titles.get(i), nextLine[i].trim());
                        }
                    }
                    ret.add(codeDef);
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }
    
    public static JSONObject loadICASAMgnVarCode() {
        JSONObject ret = new JSONObject();
        File file = Path.Folder.getICASAMgnVarFile();
        if (!file.exists()) {
            ICASAUtil.syncICASA();
        }

        try (CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',')) {
            String[] headers = {
                ICASA_MGN_VAR_HEADER_VAR_CODE,
                ICASA_MGN_VAR_HEADER_VAR_DESC,
                ICASA_MGN_VAR_HEADER_VAR_UNIT,
                ICASA_MGN_VAR_HEADER_VAR_DATASET,
                ICASA_MGN_VAR_HEADER_VAR_SUBSET,
                ICASA_MGN_VAR_HEADER_VAR_GROUP,
                ICASA_MGN_VAR_HEADER_VAR_SUBGROUP,
                ICASA_MGN_VAR_HEADER_VAR_ORDER,
                ICASA_MGN_VAR_HEADER_VAR_RATING};
            int[] attrIdx = new int[headers.length];
            for (int i = 0; i < attrIdx.length; i++) {
                attrIdx[i] = -1;
            }
            int minLength = headers.length;
            String[] nextLine = reader.readNext();
            if (nextLine!= null) {
                ArrayList<String> titles = new ArrayList();
                for (String title : nextLine) {
                    titles.add(title.toLowerCase());
                }
                for (int i = 0; i < attrIdx.length; i++) {
                    attrIdx[i] = titles.indexOf(headers[i]);
                    minLength = Math.min(minLength, attrIdx[i]);
                }
                if (minLength < 0) {
                    throw new IOException("Missing required column in ICASA management variable defination file!");
                }
            }
            while ((nextLine = reader.readNext()) != null) {
                if (nextLine[0].startsWith("!") || nextLine.length <= minLength) {
                } else if (!nextLine[attrIdx[0]].trim().isEmpty()) {
                    JSONObject varDef = new JSONObject();
                    for (int i = 0; i < attrIdx.length; i++) {
                        varDef.put(headers[i], nextLine[attrIdx[i]].trim());
                    }
                    try {
                        if (Integer.parseInt(varDef.get(ICASA_MGN_VAR_HEADER_VAR_RATING).toString()) < ICASA_MIN_ACCEPTABLE_RATING_LEVEL) {
                            continue;
                        }
                    } catch (NumberFormatException ex) {}
                    if (ret.containsKey(nextLine[attrIdx[0]])) {
                        System.out.println("Detect repeated var id: " + nextLine[attrIdx[0]]);
                    } else {
                        ret.put(nextLine[attrIdx[0]], varDef);
                    }
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }
    
    public static JSONObject loadICASAObvVarCode() {
        JSONObject ret = new JSONObject();
        File file = Path.Folder.getICASAObvVarFile();
        if (!file.exists()) {
            ICASAUtil.syncICASA();
        }

        try (CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',')) {
            String[] headers = {
                ICASA_MGN_VAR_HEADER_VAR_CODE,
                ICASA_MGN_VAR_HEADER_VAR_DESC,
                ICASA_MGN_VAR_HEADER_VAR_UNIT,
                ICASA_MGN_VAR_HEADER_VAR_DATASET,
                ICASA_MGN_VAR_HEADER_VAR_SUBSET,
                ICASA_MGN_VAR_HEADER_VAR_GROUP,
                ICASA_OBV_VAR_HEADER_VAR_SUBGROUP,
                ICASA_MGN_VAR_HEADER_VAR_ORDER,
                ICASA_MGN_VAR_HEADER_VAR_RATING};
            int[] attrIdx = new int[headers.length];
            for (int i = 0; i < attrIdx.length; i++) {
                attrIdx[i] = -1;
            }
            int minLength = headers.length;
            String[] nextLine = reader.readNext();
            if (nextLine!= null) {
                ArrayList<String> titles = new ArrayList();
                for (String title : nextLine) {
                    titles.add(title.toLowerCase());
                }
                for (int i = 0; i < attrIdx.length; i++) {
                    attrIdx[i] = titles.indexOf(headers[i]);
                    minLength = Math.min(minLength, attrIdx[i]);
                }
                if (minLength < 0) {
                    throw new IOException("Missing required column in ICASA management variable defination file!");
                }
            }
            while ((nextLine = reader.readNext()) != null) {
                if (nextLine[0].startsWith("!") || nextLine.length <= minLength) {
                } else if (!nextLine[attrIdx[0]].trim().isEmpty()) {
                    JSONObject varDef = new JSONObject();
                    for (int i = 0; i < attrIdx.length; i++) {
                        varDef.put(headers[i], nextLine[attrIdx[i]].trim());
                    }
                    try {
                        if (Integer.parseInt(varDef.get(ICASA_MGN_VAR_HEADER_VAR_RATING).toString()) < ICASA_MIN_ACCEPTABLE_RATING_LEVEL) {
                            continue;
                        }
                    } catch (NumberFormatException ex) {}
                    if (ret.containsKey(nextLine[attrIdx[0]])) {
                        System.out.println("Detect repeated var id: " + nextLine[attrIdx[0]]);
                    } else {
                        ret.put(nextLine[attrIdx[0]], varDef);
                    }
                }
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }
    
    public static ArrayList<JSONObject> getICASACropCodeMap() {
        return ICASA_CROP_CODE_LIST;
    }
    
    public static JSONObject getICASAMgnCodeMap() {
        return ICASA_MGN_CODE_MAP;
    }
    
    public static JSONObject getICASAMgnVarMap() {
        return ICASA_MGN_VAR_MAP;
    }
    
    public static JSONObject getICASAObvVarMap() {
        return ICASA_OBV_VAR_MAP;
    }
    
    private static Properties loadProperties() {
        Properties p = new Properties();
        try (InputStream versionFile = DataUtil.class.getClassLoader().getResourceAsStream("product.properties")) {
            p.load(versionFile);
        } catch (IOException ex) {
            Logger.getLogger(DataUtil.class.getName()).log(Level.SEVERE, "Unable to load version information, version will be blank.", ex);
        }
        return p;
    }
    
    public static String getProductVersion() {
        return versionProperties.getProperty("product.version");
    }
    
    public static String getProductInfo() {
        
        StringBuilder qv = new StringBuilder();
        String buildType = versionProperties.getProperty("product.buildtype");
        qv.append("Version ");
        qv.append(getProductVersion());
        qv.append("-").append(versionProperties.getProperty("product.buildversion"));
        qv.append("(").append(buildType).append(")");
        if (buildType.equals("dev")) {
            qv.append(" [").append(versionProperties.getProperty("product.buildts")).append("]");
        }
        return qv.toString();
    }
}
