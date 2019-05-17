package org.dssat.tool.gbuilder2d.util;

import au.com.bytecode.opencsv.CSVReader;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import org.agmip.translators.dssat.DssatSoilInput;
import static org.dssat.tool.gbuilder2d.util.JsonUtil.parseFrom;
import static org.dssat.tool.gbuilder2d.util.Path.Folder.getSoilListDir;
import static org.dssat.tool.gbuilder2d.util.Path.Folder.getSoilListFile;
import static org.dssat.tool.gbuilder2d.util.Path.Folder.getWthListDir;
import static org.dssat.tool.gbuilder2d.util.Path.Folder.getWthListFile;

/**
 *
 * @author Meng Zhang
 */
public class DataUtil {
    
    private static final JSONObject CROP_CODE_MAP = new JSONObject();
    private static final ArrayList<JSONObject> CUL_METADATA_LIST = new ArrayList();
    private static final JSONObject CUL_METADATA_MAP = loadCulData();
    private static final ArrayList<JSONObject> SOILDATA_LIST = getSoilDataList(getSoilListDir(), getSoilListFile());
    private static final ArrayList<JSONObject> WTHDATA_LIST = getWthDataList(getWthListDir(), getWthListFile());
    private static final JSONObject ICASA_MGN_CODE_MAP = loadICASAMgnCode();
    
    private static final String ICASA_MGN_CODE_HEADER_VAR_CODE = "code_display";
    private static final String ICASA_MGN_CODE_HEADER_VAR_CODE_VAL = "code";
    private static final String ICASA_MGN_CODE_HEADER_VAR_TEXT_VAL = "description";
    
    private static JSONObject loadCulData() {
        
        JSONObject ret = new JSONObject();
        File culListFile = Path.Folder.getCulListFile();
        String line;
        ArrayList<String> titles = new ArrayList();
        boolean titleFlg = false; 
        try (BufferedReader br = new BufferedReader(new FileReader(culListFile))) {
            while ((line = br.readLine()) != null) {
                String[] arr = line.split(",");
                if (arr.length == 0) {
                    continue;
                }
                String marker = arr[0].trim();
                if (marker.startsWith("!")) {
                } else if (marker.startsWith("@")) {
                    titleFlg = true;
                    titles = new ArrayList();
                    for (String item : arr) {
                        titles.add(item.trim());
                    }
                } else if (titleFlg) {
                    JSONObject culData = new JSONObject();
                    int limit = Math.min(arr.length, titles.size());
                    for (int i = 1; i < limit; i++) {
                        culData.put(titles.get(i), arr[i].trim());
                    }
                    ret.put(culData.get("agmip_code"), culData);
                    CROP_CODE_MAP.put(culData.get("dssat_code"), culData.get("agmip_code"));
                }
            }
        } catch (FileNotFoundException ex) {
            ex.printStackTrace(System.out);
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        CUL_METADATA_LIST.addAll(ret.values());
        CUL_METADATA_LIST.sort(new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject o1, JSONObject o2) {
                int ret = o1.getOrBlank("category").compareTo(o2.getOrBlank("category"));
                if (ret == 0) {
                    ret = o1.getOrBlank("name").compareTo(o2.getOrBlank("name"));
                }
                return ret;
            }
        });
        for (Object cridObj : ret.keySet()) {
            String crid = cridObj.toString();
            JSONObject culData;
            if (isFallow(crid)) {
                culData = new JSONObject();
            } else {
                JSONObject meta = ret.getAsObj(crid);
                File culFile = Path.Folder.getCulFile(meta.getOrBlank("model"));
                culData = getCulDataList(culFile);
            }
            ret.getAsObj(crid).put("cultivars", culData);
        }
        return ret;
    }
    
    public static JSONObject getCulMetaData(String crid) {
        if (crid.length() == 3) {
            return CUL_METADATA_MAP.getAsObj(crid);
        } else {
            return CUL_METADATA_MAP.getAsObj(getAgmipCropCode(crid));
        }
    }
    
    public static JSONObject getCulMetaData() {
        return CUL_METADATA_MAP;
    }
    
    public static ArrayList getCulMetaDataList() {
        return CUL_METADATA_LIST;
    }
    
    public static JSONObject getCulDataList(String crid) {
        if (isFallow(crid)) {
            return new JSONObject();
        }
        JSONObject meta = getCulMetaData(crid);
        File culFile = Path.Folder.getCulFile(meta.getOrBlank("model"));
        return getCulDataList(culFile);
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
    
    public static String getDssatCropCode(String crid) {
        if (crid == null) {
            return "";
        } else if (crid.length() == 3) {
            return CUL_METADATA_MAP.getAsObj(crid).getOrBlank("dssat_code");
        } else {
            return crid;
        }
    }
    
    public static String getAgmipCropCode(String crid) {
        if (crid == null) {
            return "";
        } else if (crid.length() == 2) {
            return CROP_CODE_MAP.getOrBlank(crid);
        } else {
            return crid;
        }
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

        try (CSVReader reader = new CSVReader(new BufferedReader(new FileReader(file)), ',')) {
            int varNameIdx = -1;
            int codeIdx = -1;
            int textIdx = -1;
            String[] nextLine;
            while ((nextLine = reader.readNext()) != null) {
                if (nextLine[0].startsWith("!")) {
                } else if (nextLine[0].startsWith("@")) {
                    ArrayList<String> titles = new ArrayList();
                    for (int i = 0; i < nextLine.length; i++) {
                        titles.add(nextLine[i].toLowerCase());
                    }
                    varNameIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_CODE);
                    codeIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_CODE_VAL);
                    textIdx = titles.indexOf(ICASA_MGN_CODE_HEADER_VAR_TEXT_VAL);
                    if (varNameIdx < 0 || codeIdx < 0 || textIdx < 0) {
                        throw new IOException("Missing required column in ICASA management code defination file!");
                    }
                } else if (!nextLine[varNameIdx].trim().isEmpty()) {
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
                        codeDef.put(nextLine[codeIdx].trim(), nextLine[textIdx]);
                    }
                }
                
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.out);
        }
        return ret;
    }
    
    public static JSONObject getICASAMgnCodeMap() {
        return ICASA_MGN_CODE_MAP;
    }
    
    public static ArrayList<JSONObject> getSoilDataList() {
        return SOILDATA_LIST;
    }
    
    private static ArrayList<JSONObject> getSoilDataList(File dir, File cacheFile) {
        ArrayList<JSONObject> ret = new ArrayList();
        if (dir.isDirectory() && dir.exists()) {
            
            // Read Soil Data from given directory
            DssatSoilInput soilDataReader = new DssatSoilInput();
            
            for (File file : dir.listFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.toUpperCase().endsWith(".SOL");
                }
            })) {
                JSONObject profile = new JSONObject(soilDataReader.readFile(file.getPath()));
                JSONArray soils = profile.getObjArr("soils");
                for (Object item : soils) {
                    JSONObject soil = (JSONObject) item;
                    String name = soil.getOrBlank("soil_name");
                    if (name.matches("\\d\\s+.+")) {
                        System.out.println("[warn] Incorrect data format detected in " + file.getName() + " for " + soil.getOrBlank("soil_id"));
                        soil.put("soil_name", name.substring(1).trim());
                        soil.put("sldp", soil.getOrBlank("sldp") + name.substring(0, 1));
                    }
                    if (soil.getObjArr("soilLayer").isEmpty()) {
                        System.out.println("[warn] Empty layer data detected in " + file.getName() + " for " + soil.getOrBlank("soil_id"));
                    }
                }
                profile.put("soils", soils);
                for (Object item : soils) {
                    JSONObject soil = (JSONObject) item;
                    String notes = soil.getOrBlank("sl_notes");
                    if (!notes.isEmpty()) {
                        profile.put("sl_notes", notes);
                        break;
                    }
                }
                profile.put("file_name", file.getName());
                ret.add(profile);
            }
            
            // Save Loaded data into cache file for future usage
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(cacheFile, false))) {
                JSONArray arr = new JSONArray();
                arr.addAll(ret);
                bw.write(arr.toJSONString());
                bw.flush();
            } catch (IOException ex) {
                ex.printStackTrace(System.err);
            }
            
        } else if (cacheFile.exists()) {
            ret = parseFrom(cacheFile).getObjArr();
        }
        
        return ret;
    }
    
    public static ArrayList<JSONObject> getWthDataList() {
        return WTHDATA_LIST;
    }
    
    private static ArrayList<JSONObject> getWthDataList(File dir, File cacheFile) {
        ArrayList<JSONObject> ret = new ArrayList();
        HashMap<String, JSONObject> wthMap = new HashMap();
        if (dir.isDirectory() && dir.exists()) {
            
            // Read Soil Data from given directory
            for (File file : dir.listFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.toUpperCase().endsWith(".WTH");
                }
            })) {
                JSONObject profile = readWthFile(file);
                String wstId = profile.getOrBlank("wst_id");
                if (wthMap.containsKey(wstId)) {
                    if (!wthMap.get(wstId).getOrBlank("wst_notes").equals(profile.getOrBlank("wst_notes"))) {
                        System.out.println("[warn] Inconsistent wst_notes detected in " + file.getName());
                    }
                    ((ArrayList) wthMap.get(wstId).get("wst_years")).addAll(profile.getArr("wst_years"));
                } else {
                    ret.add(profile);
                    wthMap.put(wstId, profile);
                }
                
            }
            
            // Save Loaded data into cache file for future usage
            try (BufferedWriter bw = new BufferedWriter(new FileWriter(cacheFile, false))) {
                JSONArray arr = new JSONArray();
                arr.addAll(ret);
                bw.write(arr.toJSONString());
                bw.flush();
            } catch (IOException ex) {
                ex.printStackTrace(System.err);
            }
            
        } else if (cacheFile.exists()) {
            ret = parseFrom(cacheFile).getObjArr();
        }
        
        return ret;
    }
    
    private static JSONObject readWthFile(File wthFile) {
        JSONObject ret = new JSONObject();
        String name = wthFile.getName().toUpperCase();
        if (name.length() == 12) {
            ret.put("wst_id", name.substring(0, 4));
            String yearStr = name.substring(4, 6);
            String durStr = name.substring(6, 8);
            int year = Integer.parseInt(yearStr);
            int dur = Integer.parseInt(durStr);
            ArrayList<String> years = new ArrayList();
            String yearPre = "19";
            if (year < 50) {
                yearPre = "20";
            }
            for (int i = 0; i < dur; i++) {
                years.add(String.format("%1$s%2$02d", yearPre, year + i));
            }
            ret.put("wst_years", years);
        } else if (name.length() == 8) {
            ret.put("wst_id", name.substring(0, 4));
            System.out.println("[warn] Detect weather file with short name as " + wthFile.getName());
        }
        
        try (BufferedReader br = new BufferedReader(new FileReader(wthFile))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith("*")) {
                    String notes = line.replaceFirst("\\*[Ww][Ee][Aa][Tt][Hh][Ee][Rr]\\s*([Dd][Aa][Tt][Aa]\\s*)*:?", "").trim();
                    if (!notes.isEmpty()) {
                        ret.put("wst_notes", notes);
                    }
                    break;
                }
                
            }
        } catch (IOException ex) {
            ex.printStackTrace(System.err);
        }
        return ret;
    }
}
