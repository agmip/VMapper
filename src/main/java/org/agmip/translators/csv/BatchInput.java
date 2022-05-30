package org.agmip.translators.csv;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import au.com.bytecode.opencsv.CSVReader;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.agmip.core.types.TranslatorInput;
import org.agmip.util.MapUtil;

public class BatchInput implements TranslatorInput {

    private static final Logger log = LoggerFactory.getLogger(BatchInput.class);
    private final HashMap<String, Object> dome = new HashMap<String, Object>();
    private final ArrayList<HashMap<String, Object>> batchDomes = new ArrayList();

    @Override
    public Map readFile(String fileName) throws Exception {
        if (fileName.toUpperCase().endsWith("CSV")) {
            FileInputStream stream = new FileInputStream(fileName);
            readCSV(new FileInputStream(fileName));
            stream.close();
        }
        return dome;
    }

    public void readCSV(InputStream stream) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(stream));
        HashMap<String, String> info = new HashMap<String, String>();
//        HashMap<String, String> linkOvl = new HashMap<String, String>();
//        HashMap<String, String> linkStg = new HashMap<String, String>();
        ArrayList<HashMap<String, String>> rules = new ArrayList<HashMap<String, String>>();
//        ArrayList<HashMap<String, String>> generators = new ArrayList<HashMap<String, String>>();
//        ArrayList<ArrayList<HashMap<String, String>>> genGroups = new ArrayList<ArrayList<HashMap<String, String>>>();
        CSVReader reader = new CSVReader(br);
        String[] nextLine;
        int ln = 0;

        HashMap<String, Object> batchDome = new HashMap();
        HashMap<String, Object> batchRun;
        HashMap<String, String> lineMap;
        String lastGroupId = null;
        String lastRunNum = null;
        while ((nextLine = reader.readNext()) != null) {

            ln++;
            if (nextLine[0].startsWith("&")) {
                // This is an official dome line.
                log.debug("Found a batch DOME info at line {}", ln);
                String cmd = nextLine[1].trim().toUpperCase(); // TODO fix the file format for sensitive analysis
                if (cmd.equals("INFO")) {
                    info.put(nextLine[2].toLowerCase(), nextLine[3].toUpperCase());
                } else {
                    log.error("Found invalid command {} at line {}", cmd, ln);
                }
            } else if (nextLine[0].startsWith("@")) {
                log.debug("Found a batch DOME instruction at line {}", ln);
                lineMap = new HashMap<String, String>();
                String groupId = nextLine[1].trim().toUpperCase();
                String runNum = nextLine[2].trim().toUpperCase();
                String cmd = nextLine[3].trim().toUpperCase();

                if (lastGroupId == null || !lastGroupId.equals(groupId)) {
                    lastGroupId = groupId;
                    batchDome = getBatchDome(groupId, true);
                    lastRunNum = null;
                }
                if (lastRunNum == null || !lastRunNum.equals(runNum)) {
                    lastRunNum = runNum;
                    batchRun = getBatchRun(batchDome, runNum, true);
                    rules = (ArrayList<HashMap<String, String>>) batchRun.get("rules");
                }

                if ((cmd.equals("FILL") || cmd.equals("REPLACE"))) {
                    StringBuilder args = new StringBuilder();
                    if (nextLine[5].endsWith("()")) {
                        log.debug("Found fun {}", nextLine[5].toUpperCase());

                        int argLen = nextLine.length - 5;

                        if (argLen != 0) {
                            args.append(nextLine[5]);
                            if (argLen > 1) {
                                for (int i = 6; i < nextLine.length; i++) {
                                    args.append("|");
                                    if (!nextLine[i].startsWith("!")) {
                                        args.append(nextLine[i].toUpperCase());
                                    }
                                }
                            }
                        }

                        log.debug("Current Args: {}", args.toString());
//                        int chopIndex = args.indexOf("||", 0);
//                        if (chopIndex == -1) {
//                            chopIndex = args.length();
//                        }
//                        if (args.substring(0, chopIndex).endsWith("|")) {
//                            chopIndex--;
//                        }
//                        lineMap.put("args", args.substring(0, chopIndex));
                        lineMap.put("args", args.toString());
                    } else {
                        // Variable or static
                        lineMap.put("args", nextLine[5].toUpperCase());
                    }

                    lineMap.put("cmd", cmd);
                    lineMap.put("variable", nextLine[4].toLowerCase());
                    rules.add(lineMap);

                } else {
                    log.error("Found invalid command {} at line {}", cmd, ln);
                }
            }
        }
        br.close();
        dome.put("info", info);
        dome.put("batch_group", batchDomes);
    }

    public HashMap<String, Object> getDome() {
        return dome;
    }

    public HashMap<String, Object> getBatchDome(String batchId) {
        return getBatchDome(batchId, false);
    }
    
    public HashMap<String, Object> getBatchDome(String groupId, boolean addNew) {
        for (HashMap<String, Object> batchDome : batchDomes) {
            if (groupId.equals(batchDome.get("group_id"))) {
                return batchDome;
            }
        }
        
        HashMap<String, Object> batchDome = new HashMap();
        if (addNew) {
            batchDomes.add(batchDome);
            batchDome.put("group_id", groupId);
            batchDome.put("batch_runs", new ArrayList<HashMap<String, String>>());
        }
        return batchDome;
    }
    
    public HashMap<String, Object> getBatchRun(HashMap batchDome, String runNum, boolean addNew) {
        ArrayList<HashMap<String, Object>> batchRuns = MapUtil.getObjectOr(batchDome, "batch_runs", new ArrayList());
        for (HashMap<String, Object> batchRun : batchRuns) {
            if (runNum.equals(batchRun.get("batch_run#"))) {
                return batchRun;
            }
        }
        
        HashMap<String, Object> batchRun = new HashMap();
        if (addNew) {
            if (batchRuns.isEmpty()) {
                batchDome.put("batch_runs", batchRuns);
            }
            batchRuns.add(batchRun);
            batchRun.put("rules", new ArrayList());
            batchRun.put("batch_run#", runNum);
        }
        return batchRun;
    }
}
