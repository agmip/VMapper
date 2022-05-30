package org.agmip.translators.csv;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;

import au.com.bytecode.opencsv.CSVReader;
import java.util.HashSet;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.agmip.ace.AcePathfinder;
import org.agmip.ace.util.AcePathfinderUtil;
import org.agmip.core.types.TranslatorInput;
import org.agmip.util.MapUtil;

/**
 * This class converts CSV formatted files into the AgMIP ACE JSON format. It
 * uses a common file pattern as described below.
 *
 * <p><b>First Column Descriptors</b></p> <p># - Lines with the first column
 * text containing only a "#" is considered a header row</p> <p>! - Lines with
 * the first column text containing only a "!" are considered a comment and not
 * parsed.
 *
 * The first header/datarow(s) are metadata (or global data) if there are
 * multiple rows of metadata, they are considered to be a collection of
 * experiments.
 *
 */
public class CSVInput implements TranslatorInput {

    private static Logger LOG = LoggerFactory.getLogger(CSVInput.class);
//    private HashMap<String, HashMap<String, HashMap<String, Object>>> finalMap;
    private HashMap<String, HashMap<String, Object>> expMap, weatherMap, soilMap; // Storage maps
    private HashMap<String, Integer> trtTracker;
    private HashMap<String, String> idMap;
    private ArrayList<String> orderring;
    private String listSeparator;
    private AcePathfinder pathfinder = AcePathfinderUtil.getInstance();
    private static HashSet unknowVars = new HashSet();

    private enum HeaderType {

        UNKNOWN, // Probably uninitialized
        SUMMARY, // #
        SERIES   // %
    }

    private static class CSVHeader {

        private final ArrayList<String> headers;
        private final ArrayList<Integer> skippedColumns;
        private final String defPath;
        private final AcePathfinderUtil.PathType defPathType;
        private final HashMap<String, Integer> subListKeyMap;

        public CSVHeader(ArrayList<String> headers, ArrayList<Integer> sc) {
            this(headers, sc, null, AcePathfinderUtil.PathType.UNKNOWN);
        }

        public CSVHeader(ArrayList<String> headers, ArrayList<Integer> sc, String defPath, AcePathfinderUtil.PathType defPathType) {
            this.headers = headers;
            this.skippedColumns = sc;
            this.defPath = defPath;
            this.defPathType = defPathType;
            this.subListKeyMap = new HashMap();
            if (defPath != null && defPath.contains("@")) {
                if (defPath.equals("soil@soilLayer")) {
//                    if (headers.contains("SLLT")) {
//                        subListKeyMap.put("sllt", headers.indexOf("SLLT") + 1);
//                    }
                    if (headers.contains("SLLB")) {
                        subListKeyMap.put("sllb", headers.indexOf("SLLB") + 1);
                    }
                } else if (defPath.equals("weather@dailyWeather")) {
                    if (headers.contains("W_DATE")) {
                        subListKeyMap.put("w_date", headers.indexOf("W_DATE") + 1);
                    }
                } else if (defPath.equals("initial_conditions@soilLayer")) {
//                    if (headers.contains("ICTL")) {
//                        subListKeyMap.put("ictl", headers.indexOf("ICTL") + 1);
//                    }
                    if (headers.contains("ICBL")) {
                        subListKeyMap.put("icbl", headers.indexOf("ICBL") + 1);
                    }
                } else if (defPath.equals("observed@timeSeries")) {
                    if (headers.contains("DATE")) {
                        subListKeyMap.put("date", headers.indexOf("DATE") + 1);
                    }
                }
            }
        }

        public CSVHeader() {
            this.headers = new ArrayList<String>();
            this.skippedColumns = new ArrayList<Integer>();
            this.defPath = null;
            this.defPathType = AcePathfinderUtil.PathType.UNKNOWN;
            this.subListKeyMap = new HashMap();
        }

        public ArrayList<String> getHeaders() {
            return headers;
        }

        public ArrayList<Integer> getSkippedColumns() {
            return skippedColumns;
        }

        public String getDefPath() {
            return defPath;
        }

        public AcePathfinderUtil.PathType getDefPathType() {
            return defPathType;
        }
        
        public ArrayList<String> getSubListKeys() {
            return new ArrayList(subListKeyMap.keySet());
        }
        
        public HashMap<String, String> getSubListKeys(String[] data) {
            HashMap<String, String> keys = new HashMap();
            for (String key : subListKeyMap.keySet()) {
                keys.put(key, data[subListKeyMap.get(key)]);
            }
            return keys;
        }
    }

    public CSVInput() {
        expMap = new HashMap<String, HashMap<String, Object>>();
        weatherMap = new HashMap<String, HashMap<String, Object>>();
        soilMap = new HashMap<String, HashMap<String, Object>>();
        trtTracker = new HashMap<String, Integer>();
        idMap = new HashMap<String, String>();

        orderring = new ArrayList<String>();
//        finalMap = new HashMap<String, HashMap<String, HashMap<String, Object>>>();
        this.listSeparator = ",";
//        finalMap.put("experiments", expMap);
//        finalMap.put("weather", weatherMap);
//        finalMap.put("soil", soilMap);
    }

    @Override
    public Map readFile(String fileName) throws Exception {
        if (fileName.toUpperCase().endsWith("CSV")) {
            readCSV(new FileInputStream(fileName));
        } else if (fileName.toUpperCase().endsWith("ZIP")) {
            //Handle a ZipInputStream instead
            LOG.debug("Launching zip file handler");
            try (ZipFile zf = new ZipFile(fileName)) {
                Enumeration<? extends ZipEntry> e = zf.entries();
                while (e.hasMoreElements()) {
                    ZipEntry ze = (ZipEntry) e.nextElement();
                    LOG.debug("Entering file: " + ze);
                    if (ze.getName().toLowerCase().endsWith(".csv")) {
                        readCSV(zf.getInputStream(ze));
                    }
                }
            }
        }
        return cleanUpFinalMap();
    }

    protected void readCSV(InputStream fileStream) throws Exception {
        HeaderType section = HeaderType.UNKNOWN;
        CSVHeader currentHeader = new CSVHeader();
        String[] nextLine;
        BufferedReader br = new BufferedReader(new InputStreamReader(fileStream));

        // Check to see if this is an international CSV. (;, vs ,.)
        setListSeparator(br);
        CSVReader reader = new CSVReader(br, this.listSeparator.charAt(0));

        // Clear out the idMap for every file created.
        idMap.clear();
        int ln = 0;

        while ((nextLine = reader.readNext()) != null) {
            ln++;
            LOG.debug("Line number: " + ln);
            if (nextLine[0].startsWith("!")) {
                LOG.debug("Found a comment line");
                continue;
            } else if (nextLine[0].startsWith("#")) {
                LOG.debug("Found a summary header line");
                section = HeaderType.SUMMARY;
                currentHeader = parseHeaderLine(nextLine);
            } else if (nextLine[0].startsWith("%")) {
                LOG.debug("Found a series header line");
                section = HeaderType.SERIES;
                currentHeader = parseHeaderLine(nextLine);
            } else if (nextLine[0].startsWith("*")) {
                LOG.debug("Found a complete experiment line");
                section = HeaderType.SUMMARY;
                parseDataLine(currentHeader, section, nextLine, true);
            } else if (nextLine[0].startsWith("&")) {
                LOG.debug("Found a DOME line, skipping");
            } else if (nextLine.length == 1) {
                LOG.debug("Found a blank line, skipping");
            } else {
                boolean isBlank = true;
                // Check the nextLine array for all blanks
                int nlLen = nextLine.length;
                for (int i = 0; i < nlLen; i++) {
                    if (!nextLine[i].equals("")) {
                        isBlank = false;
                        break;
                    }
                }
                if (!isBlank) {
                    LOG.debug("Found a data line with [" + nextLine[0] + "] as the index");
                    parseDataLine(currentHeader, section, nextLine, false);
                } else {
                    LOG.debug("Found a blank line, skipping");
                }
            }
        }
        reader.close();
    }

    protected CSVHeader parseHeaderLine(String[] data) {
        ArrayList<String> h = new ArrayList<String>();
        ArrayList<Integer> sc = new ArrayList<Integer>();
        String defPath = null;
        AcePathfinderUtil.PathType defPathType = AcePathfinderUtil.PathType.UNKNOWN;

        int l = data.length;
        for (int i = 1; i < l; i++) {
            if (data[i].startsWith("!")) {
                sc.add(i);
            }
            if (data[i].trim().length() != 0) {
                h.add(data[i]);
            }
            if (defPath == null) {
                defPath = AcePathfinderUtil.getInstance().getPath(data[i].trim());
                if (defPath != null) {
                    defPath = defPath.replaceAll(",", "").trim();
                    defPathType = AcePathfinderUtil.getVariableType(data[i].trim());
                }
            }
        }
        return new CSVHeader(h, sc, defPath, defPathType);
    }

    protected void parseDataLine(CSVHeader header, HeaderType section, String[] data, boolean isComplete) throws Exception {
        ArrayList<String> headers = header.getHeaders();
        int l = headers.size();
        String dataIndex;
        dataIndex = UUID.randomUUID().toString();
        HashMap<String, String> subListKeys = header.getSubListKeys(data);

        if (!isComplete) {
            if (idMap.containsKey(data[0])) {
                dataIndex = idMap.get(data[0]);
            } else {
                idMap.put(data[0], dataIndex);
            }
        }
        if (data[1].toLowerCase().equals("event")) {
            if (header.getDefPath() != null && !"".equals(header.getDefPath())) {
                for (int i = 3; i < data.length; i++) {
                    String var = data[i].toLowerCase();
                    i++;
                    if (i < data.length) {
                        String val = data[i];
                        LOG.debug("Trimmed var: " + var.trim() + " and length: " + var.trim().length());
                        if (var.trim().length() != 0 && val.trim().length() != 0) {
                            LOG.debug("INSERTING! Var: " + var + " Val: " + val);
                            insertValue(dataIndex, var, val, header, subListKeys);
                        }
                    }
                }
            } else {
                HashMap event = insertUnknownEvent(dataIndex, data[2]);
                for (int i = 3; i < data.length; i++) {
                    String var = data[i].toLowerCase();
                    i++;
                    if (i < data.length) {
                        String value = data[i];
                        LOG.debug("Trimmed var: " + var.trim() + " and length: " + var.trim().length());
                        if (pathfinder.isDate(var)) {
                            LOG.debug("Converting date from: " + value);
                            value = value.replace("/", "-");
                            DateFormat f = new SimpleDateFormat("yyyymmdd");
                            Date d = new SimpleDateFormat("yyyy-mm-dd").parse(value);
                            value = f.format(d);
                            LOG.debug("Converting date to: " + value);

                        }
                        if (var.trim().length() != 0 && value.trim().length() != 0) {
                            LOG.debug("INSERTING! Var: " + var + " Val: " + value);
                            event.put(var, value);
                        }
                    }
                }
            }
            LOG.debug("Leaving event loop");
        } else if (header.getSkippedColumns().isEmpty()) {
            for (int i = 0; i < l; i++) {
                if (!data[i + 1].trim().equals("")) {
                    insertValue(dataIndex, headers.get(i), data[i + 1], header, subListKeys);
                }
            }
        } else {
            ArrayList<Integer> skipped = header.getSkippedColumns();
            for (int i = 0; i < l; i++) {
                if (!data[i + 1].trim().equals("")) {
                    if (!skipped.contains(i + 1)) {
                        insertValue(dataIndex, headers.get(i), data[i + 1], header, subListKeys);
                    }
                }
            }
        }
    }
    
    protected HashMap<String, String> insertUnknownEvent(String index, String eventType) {
        insertIndex(expMap, index, true);
        HashMap<String, Object> currentMap = expMap.get(index);
        ArrayList<HashMap<String, String>> events = MapUtil.getBucket(currentMap, "management").getDataList();
        HashMap<String, String> event = new HashMap();
        event.put("event", eventType);
        events.add(event);
        return event;
    }

    protected void insertValue(String index, String variable, String value, CSVHeader header, HashMap<String, String> subListKeys) throws Exception {
        try {
            String var = variable.toLowerCase();
            HashMap<String, HashMap<String, Object>> topMap = null;
            if (var.equals("wst_id") || var.equals("soil_id")) {
                insertIndex(expMap, index, true);
                HashMap<String, Object> temp = expMap.get(index);
                temp.put(var, value);
            } else if (var.equals("exname")) {
                Integer i = 0;
                if (trtTracker.containsKey(value)) {
                    i = trtTracker.get(value);
                }
                i = i + 1;
                trtTracker.put(value, i);
                value = value + "_" + i;
            } else {
                if (pathfinder.isDate(var)) {
                    LOG.debug("Converting date from: " + value);
                    value = value.replace("/", "-");
                    DateFormat f = new SimpleDateFormat("yyyymmdd");
                    Date d = new SimpleDateFormat("yyyy-mm-dd").parse(value);
                    value = f.format(d);
                    LOG.debug("Converting date to: " + value);

                }
            }
            boolean isExperimentMap = false;
            String path = null;
            switch (AcePathfinderUtil.getVariableType(var)) {
                case WEATHER:
                    topMap = weatherMap;
                    break;
                case SOIL:
                    topMap = soilMap;
                    break;
                case UNKNOWN:
                    switch (header.getDefPathType()) {
                        case WEATHER:
                            topMap = weatherMap;
                            break;
                        case SOIL:
                            topMap = soilMap;
                            break;
                    }
                    path = header.getDefPath();
                    if (!unknowVars.contains(var)) {
                        if (path != null || "".equals(path)) {
                            LOG.warn("Putting unknow variable into [{}] section: [{}]", path, var);
                        } else {
                            LOG.warn("Putting unknow variable into root: [{}]", var);
                        }
                        unknowVars.add(var);
                    }
                    if (topMap != null) {
                        break;
                    }
                default:
                    isExperimentMap = true;
                    topMap = expMap;
                    break;
            }
            insertIndex(topMap, index, isExperimentMap);
            HashMap<String, Object> currentMap = topMap.get(index);
            path = AcePathfinderUtil.getInstance().getPath(var);
            if (!subListKeys.isEmpty() && (header.getDefPath().equals(path) || path == null || path.isEmpty())) {
                path = header.getDefPath();
                ArrayList<HashMap<String, String>> subList;
                String[] paths = path.split("@");
                HashMap<String, Object> tmp = (HashMap<String, Object>) currentMap.get(paths[0]);
                if (tmp != null) {
                    subList = (ArrayList<HashMap<String, String>>) tmp.get(paths[1]);
                    if (subList == null) {
                        subList = new ArrayList();
                    }
                    for (HashMap<String, String> record : subList) {
                        boolean found = true;
                        for (String key : subListKeys.keySet()) {
                            if (!subListKeys.get(key).equals(record.get(key))) {
                                found = false;
                                break;
                            }
                        }
                        if (found) {
                            record.put(var, value);
                            return;
                        }
                    }
                }
            }
            AcePathfinderUtil.insertValue(currentMap, var, value, path, true);
        } catch (Exception ex) {
            throw new Exception(ex);
        }
    }

    protected void insertIndex(HashMap<String, HashMap<String, Object>> map, String index, boolean isExperimentMap) {
        if (!map.containsKey(index)) {
            map.put(index, new HashMap<String, Object>());
            if (isExperimentMap) {
                orderring.add(index);
            }

        }
    }

    protected HashMap<String, ArrayList<HashMap<String, Object>>> cleanUpFinalMap() {
        HashMap<String, ArrayList<HashMap<String, Object>>> base = new HashMap<String, ArrayList<HashMap<String, Object>>>();
        ArrayList<HashMap<String, Object>> experiments = new ArrayList<HashMap<String, Object>>();
        ArrayList<HashMap<String, Object>> weathers = new ArrayList<HashMap<String, Object>>();
        ArrayList<HashMap<String, Object>> soils = new ArrayList<HashMap<String, Object>>();

        for (String id : orderring) {
            //for (HashMap<String, Object> ex : expMap.values()) {
            HashMap<String, Object> ex = expMap.get(id);
            ex.remove("weather");
            ex.remove("soil");
            if (ex.size() == 2 && ex.containsKey("wst_id") && ex.containsKey("soil_id")) {
            } else if (ex.size() == 1 && (ex.containsKey("wst_id") || ex.containsKey("soil_id"))) {
            } else {
                experiments.add(ex);
            }
        }

        for (Object wth : weatherMap.values()) {
            if (wth instanceof HashMap) {
                @SuppressWarnings("unchecked")
                HashMap<String, Object> temp = (HashMap<String, Object>) wth;
                if (temp.containsKey("weather")) {
                    @SuppressWarnings("unchecked")
                    HashMap<String, Object> weather = (HashMap<String, Object>) temp.get("weather");
                    if (weather.size() == 1 && weather.containsKey("wst_id")) {
                    } else {
                        weathers.add(weather);
                    }
                }
            }
        }

        for (Object sl : soilMap.values()) {
            if (sl instanceof HashMap) {
                @SuppressWarnings("unchecked")
                HashMap<String, Object> temp = (HashMap<String, Object>) sl;
                if (temp.containsKey("soil")) {
                    @SuppressWarnings("unchecked")
                    HashMap<String, Object> soil = (HashMap<String, Object>) temp.get("soil");
                    if (soil.size() == 1 && soil.containsKey("soil_id")) {
                    } else {
                        soils.add(soil);
                    }
                }
            }
        }

        base.put("experiments", experiments);
        base.put("weathers", weathers);
        base.put("soils", soils);
        return base;
    }

    protected void setListSeparator(BufferedReader in) throws Exception {
        // Set a mark at the beginning of the file, so we can get back to it.
        in.mark(7168);
        String sample;
        while ((sample = in.readLine()) != null) {
            if (sample.startsWith("#") || sample.startsWith("%") || sample.startsWith("*")) {
                String listSeperator = sample.substring(1, 2);
                LOG.debug("FOUND SEPARATOR: " + listSeperator);
                this.listSeparator = listSeperator;
                break;
            }
        }
        in.reset();
    }
}
