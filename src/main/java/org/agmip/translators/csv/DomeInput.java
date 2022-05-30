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

public class DomeInput implements TranslatorInput {

    private static final Logger log = LoggerFactory.getLogger(DomeInput.class);
    private HashMap<String, Object> dome = new HashMap<String, Object>();
    private ArrayList<String> generatorFunctions = new ArrayList<String>();
    private ArrayList<String> ruleFunctions = new ArrayList<String>();

    public DomeInput() {
        generatorFunctions.add("AUTO_PDATE()");
        generatorFunctions.add("AUTO_REPLICATE_EVENTS()");
        ruleFunctions.add("AUTO_PDATE()");
    }

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
        HashMap<String, String> linkOvl = new HashMap<String, String>();
        HashMap<String, String> linkStg = new HashMap<String, String>();
        ArrayList<HashMap<String, String>> rules = new ArrayList<HashMap<String, String>>();
        ArrayList<HashMap<String, String>> generators = new ArrayList<HashMap<String, String>>();
        ArrayList<ArrayList<HashMap<String, String>>> genGroups = new ArrayList<ArrayList<HashMap<String, String>>>();
        CSVReader reader = new CSVReader(br);
        String[] nextLine;
        int ln = 0;
//        boolean hasGenerator = false;

        HashMap<String, String> lineMap = new HashMap<String, String>();
        while ((nextLine = reader.readNext()) != null) {
            boolean isGenerator = false;
            ln++;
            if (nextLine[0].startsWith("&")) {
                // This is an official dome line.
                log.debug("Found a DOME instruction at line {}", ln);
                lineMap = new HashMap<String, String>();
                String cmd = nextLine[1].trim().toUpperCase();
                if (cmd.equals("INFO")) {
                    info.put(nextLine[2].toLowerCase(), nextLine[3].toUpperCase());
                } else if ((cmd.equals("FILL") || cmd.equals("REPLACE") || cmd.equals("REPLACE_FIELD_ONLY") || cmd.equals("REPLACE_STRATEGY_ONLY") || cmd.equals("CREATE"))) {
                    StringBuilder args = new StringBuilder();
                    if (nextLine[3].endsWith("()")) {
                        log.debug("Found fun {}", nextLine[3].toUpperCase());
                        // Handle Arguments
                        if (generatorFunctions.contains(nextLine[3].toUpperCase())) {
                            if (cmd.equals("REPLACE") || !ruleFunctions.contains(nextLine[3].toUpperCase())) {
                                log.debug("Found a generator!!!");
                                isGenerator = true;
//                                hasGenerator = true;
                            }
                        }
                        int argLen = nextLine.length - 3;

                        if (argLen != 0) {
                            args.append(nextLine[3]);
                            if (argLen > 1) {
                                for (int i = 4; i < nextLine.length; i++) {
                                    args.append("|");
                                    if (!nextLine[i].startsWith("!")) {
                                        args.append(nextLine[i].toUpperCase());
                                    }
                                }
                            }
                        }

                        log.debug("Current Args: {}", args.toString());
                        int chopIndex = args.indexOf("||", 0);
                        if (chopIndex == -1) {
                            chopIndex = args.length();
                        }
                        if (args.substring(0, chopIndex).endsWith("|")) {
                            chopIndex--;
                        }
                        lineMap.put("args", args.substring(0, chopIndex));
                    } else {
                        // Variable or static
                        lineMap.put("args", nextLine[3]);
                    }

                    lineMap.put("cmd", cmd);
                    lineMap.put("variable", nextLine[2]);
                    if (isGenerator) {
                        generators.add(lineMap);
                        genGroups.add(generators);
                        generators = new ArrayList<HashMap<String, String>>();
                    } else {
                        rules.add(lineMap);
                        generators.add(lineMap);
                    }
                } else if (cmd.equals("LINK")) {
                    log.debug("Found a DOME LINK discription at line {}", ln);
                    String keyType = nextLine[2].trim().toUpperCase();
                    String keyValue = nextLine[3].trim();
                    String key = keyType + "_" + keyValue;
                    String domeType = nextLine[4].trim();
                    if (domeType.toUpperCase().equals("OVERLAY")) {
                        setDomeIds(linkOvl, key, nextLine);
                    } else if (domeType.toUpperCase().equals("STRATEGY")) {
                        setDomeIds(linkStg, key, nextLine);
                    } else {
                        log.error("Found invalid DOME type {} at line {}", domeType, ln);
                        continue;
                    }
                } else {
                    log.error("Found invalid command {} at line {}", cmd, ln);
                }
            } else if (nextLine[0].startsWith("+")) {
                log.debug("Found a DOME instruction continuance at line {}", ln);
                String preArgs = lineMap.get("args");
                if (preArgs != null && !"".equals(preArgs)) {
                    StringBuilder addArgs = new StringBuilder();
                    addArgs.append(preArgs);
                    for (int i = 4; i < nextLine.length; i++) {
                        if(nextLine[i].startsWith("!")) {
                            break;
                        }
                        if (!nextLine[i].equals("")) {
                            addArgs.append("|");
                            addArgs.append(nextLine[i].toUpperCase());
                        }
                    }
                    lineMap.put("args", addArgs.toString());
                }
            }
        }
        br.close();
        if (!generators.isEmpty()) {
            generators.add(new HashMap());
            genGroups.add(generators);
        }
        dome.put("generators", genGroups);
        dome.put("info", info);
        dome.put("rules", rules);
        if (!linkOvl.isEmpty()) {
            dome.put("link_overlay", linkOvl);
        }
        if (!linkStg.isEmpty()) {
            dome.put("link_stragty", linkStg);
        }
    }

    public HashMap<String, Object> getDome() {
        return dome;
    }

    private void setDomeIds(HashMap<String, String> link, String key, String[] domeIds) {
        int start = 5;
        String ids = link.get(key);
        if ((ids == null || "".equals(ids)) && start < domeIds.length) {
            ids = domeIds[start].trim();
            start++;
        }
        
        for (int i = start; i < domeIds.length; i++) {
            if (domeIds[i].trim().startsWith("!")) {
                break;
            } else if (!domeIds[i].trim().equals("")) {
                ids += "|" + domeIds[i].trim();
            }
        }
        if (ids != null && !"".equals(ids)) {
            link.put(key, ids);
        }
    }
}
