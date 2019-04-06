package org.dssat.tool.gbuilder2d.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

/**
 *
 * @author Meng Zhang
 */
public class DataUtil {
    
    private static final JSONObject CROP_CODE_MAP = new JSONObject();
    private static final JSONObject CUL_METADATA_MAP = loadCulData();
    
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
    
}
