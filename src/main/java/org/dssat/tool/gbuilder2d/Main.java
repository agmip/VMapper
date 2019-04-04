package org.dssat.tool.gbuilder2d;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import org.dssat.tool.gbuilder2d.dao.MetaDataDAO;
import org.dssat.tool.gbuilder2d.util.JSONObject;
import org.dssat.tool.gbuilder2d.util.JsonUtil;
import org.dssat.tool.gbuilder2d.util.Path;
import org.slf4j.LoggerFactory;
import spark.ModelAndView;
import spark.Request;
import spark.Response;
import spark.Spark;
import static spark.Spark.get;
import static spark.Spark.port;
import static spark.Spark.post;
import static spark.Spark.staticFiles;
import spark.template.freemarker.FreeMarkerEngine;

/**
 *
 * @author Meng Zhang
 */
public class Main {
    
    private static final int DEF_PORT = 8081;
    public static final Logger LOG = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);

    public Main() {
    }
    
    public static void main(String[] args) {
        // Configure Spark
        LOG.setLevel(Level.INFO);

        String portStr = System.getenv("PORT");
        int port;
        try {
            port = Integer.parseInt(portStr);
        } catch (NumberFormatException e) {
            port = DEF_PORT;
        }
        try {
        port(port);
        staticFiles.location("/public");
        staticFiles.expireTime(600L);
        Spark.webSocketIdleTimeoutMillis(60000);

        // Set up before-filters (called before each get/post)
//        before("*",                  Filters.addTrailingSlashes);
//        before("*",                  Filters.handleLocaleChange);

        // Set up routes
        get("/", (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.XBUILDER2D));
                });
        
        get(Path.Web.Demo.GBUILDER1D, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.GBUILDER1D));
                });
        
        get(Path.Web.Demo.GBUILDER2D, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.GBUILDER2D));
                });
        
        get(Path.Web.Demo.XBUILDER2D, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.XBUILDER2D));
                });
        
        get(Path.Web.Demo.METALIST, (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("metalist", MetaDataDAO.list());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.METALIST));
                });
        
        post(Path.Web.Translator.DSSAT_EXP, (Request request, Response response) -> {
            HashMap data = new HashMap();
            
            // Handle meta data
            JSONObject expData = JsonUtil.parseFrom(request.queryParams("exp"));
            switch (expData.getOrBlank("crid")) {
                case "TOM": expData.put("crid_dssat", "TM");break;
                case "POT": expData.put("crid_dssat", "PT");break;
            }
            
            // Handle field and management data
            // Initialize data containers
            JSONObject fieldData = JsonUtil.parseFrom(request.queryParams("field"));
            JSONObject mgnData = JsonUtil.parseFrom(request.queryParams("management"));
            ArrayList<JSONObject> treatments = JsonUtil.parseFrom(request.queryParams("treatment")).getObjArr();
            ArrayList<String> fieldIdList = new ArrayList();
            HashMap<String, ArrayList<String>> mgnIdList = new HashMap();
            mgnIdList.put("planting",  new ArrayList());
            mgnIdList.put("irrigation",  new ArrayList());
            mgnIdList.put("fertilizer",  new ArrayList());
            mgnIdList.put("harvest",  new ArrayList());
            ArrayList fieldList = new ArrayList();
            HashMap<String, ArrayList<ArrayList>> mgnList = new HashMap();
            mgnList.put("planting",  new ArrayList());
            mgnList.put("irrigation",  new ArrayList());
            mgnList.put("fertilizer",  new ArrayList());
            mgnList.put("harvest",  new ArrayList());
            ArrayList<JSONObject> configList = new ArrayList();
            for (JSONObject trt : treatments) {
                
                // Handle field data
                setupFields(trt, fieldData, fieldIdList, fieldList);
                
                // Handle management event data
                setupEvents(trt, mgnData, mgnIdList, mgnList);
                
                // Handle config data
                setupConfigs(trt, configList);
            }
            
            data.put("expData", expData);
            data.put("fields", fieldList);
            data.put("managements", mgnList);
            data.put("treatments", treatments);
            data.put("configs", configList);
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Translator.DSSAT_EXP));
                });
//        get("*",                     PageController.serveNotFoundPage, new FreeMarkerEngine());

        //Set up after-filters (called after each get/post)
        
//        after("*",                   Filters.addGzipHeader);
        } catch (Exception e) {
            e.printStackTrace(System.err);
        }
//        System.out.println("System start @ " + port + " on " + DataUtil.getLastBuildTS());
        if(Desktop.isDesktopSupported())
        {
            try {
                Desktop.getDesktop().browse(new URI("http://localhost:" + port + "/"));
            } catch (IOException | URISyntaxException ex) {
                LOG.warn(ex.getMessage());
            }
        }
    }
    
    private static void setupFields(JSONObject trt, JSONObject fieldData, ArrayList<String> fieldIdList, ArrayList fieldList) {
        String fieldId = trt.getOrBlank("field");
        if (!fieldId.isEmpty()) {
            if (!fieldIdList.contains(fieldId)) {
                fieldIdList.add(fieldId);
                fieldList.add(fieldData.get(fieldId));
            }
            trt.put("flid", fieldIdList.indexOf(fieldId) + 1);
        }
    }
    
    private static void setupConfigs(JSONObject trt, ArrayList configList) {
        JSONObject config = new JSONObject();
        config.put("general", new JSONObject());
        config.put("options", new JSONObject());
        config.put("methods", new JSONObject());
        config.put("mangement", new JSONObject());
        if (!trt.getOrBlank("irid").isEmpty()) {
            config.getAsObj("options").put("water", "Y");
        } else {
            config.getAsObj("options").put("water", "N");
        }
        if (trt.getOrBlank("feid").isEmpty()) {
            config.getAsObj("options").put("nitro", "N");
        } else {
            config.getAsObj("options").put("nitro", "Y");
        }
        if (!trt.getOrBlank("sdate").isEmpty()) {
            config.getAsObj("general").put("sdate", trt.get("sdate"));
        }
        
        int smid = configList.indexOf(config);
        if (smid < 0) {
            configList.add(config);
            smid = configList.size() - 1;
        }
        trt.put("smid", smid + 1);
    }
    
    private static void setupEvents(JSONObject trt, JSONObject mgnData, HashMap<String, ArrayList<String>> mgnIdList, HashMap<String, ArrayList<ArrayList>> mgnList) {
        ArrayList<String> mgnArr = trt.getArr("management");
        HashMap<String, String> eventFullIds = new HashMap();
        HashMap<String, String> eventFullNames = new HashMap();
        HashMap<String, ArrayList> eventFullData = new HashMap();
        eventFullData.put("planting",  new ArrayList());
        eventFullData.put("irrigation",  new ArrayList());
        eventFullData.put("fertilizer",  new ArrayList());
        eventFullData.put("harvest",  new ArrayList());
        for (String mgnId : mgnArr) {
            HashMap<String, ArrayList<String>> eventIds = new HashMap();
            String mgnName = mgnData.getAsObj(mgnId).getOrBlank("mgn_name");
            for (JSONObject event : mgnData.getAsObj(mgnId).getObjArr()) {
                String eventType = event.getOrBlank("event");
                if (!eventType.isEmpty()) {
                    ArrayList arr = eventIds.getOrDefault(eventType, new ArrayList());
                    arr.add(mgnId);
                    eventIds.put(eventType, arr);
                    eventFullData.get(eventType).add(event);
                }
            }
            for (String eventType : eventIds.keySet()) {
                if (eventFullIds.containsKey(eventType)) {
                    eventFullIds.put(eventType, eventFullIds.get(eventType) + ";" + eventIds.get(eventType));
                    eventFullNames.put(eventType, eventFullNames.get(eventType) + ";" + mgnName);
                } else {
                    eventIds.get(eventType).sort(new Comparator<String>() {
                        @Override
                        public int compare(String o1, String o2) {
                            return o1.compareTo(o2);
                        }
                    });
                    StringBuilder sb = new StringBuilder();
                    for (String id : eventIds.get(eventType)) {
                        sb.append(id).append(";");
                    }
                    sb.delete(sb.length() -1, sb.length());
                    eventFullIds.put(eventType, sb.toString());
                    eventFullNames.put(eventType, mgnName);
                }
            }
        }

        for (String eventType : eventFullIds.keySet()) {
            ArrayList<String> eventIdList = mgnIdList.get(eventType);
            ArrayList<ArrayList> eventList = mgnList.get(eventType);
            String eventId = eventFullIds.get(eventType);
            String eventName = eventFullNames.get(eventType);
            ArrayList eventArr;
            if (!eventIdList.contains(eventId)) {
                eventArr = eventFullData.get(eventType);
                for (Object eventData : eventArr) {
                    JSONObject event = (JSONObject) eventData;
                    event.put("date", toYYDDDStr(event.getOrBlank("date")));
                    if (event.containsKey("edate")) {
                        event.put("edate", toYYDDDStr(event.getOrBlank("edate")));
                    }
                }
                eventIdList.add(eventId);
                eventList.add(eventArr);
                eventArr.sort(new Comparator<JSONObject>() {
                    @Override
                    public int compare(JSONObject o1, JSONObject o2) {
                        String date1 = o1.getOrBlank("date");
                        String date2 = o2.getOrBlank("date");
                        if (date1.isEmpty()) {
                            return -1;
                        } else if(date2.isEmpty()) {
                            return 1;
                        } else {
                            return date1.compareTo(date2);
                        }
                    }
                });
                for (JSONObject event : (ArrayList<JSONObject>) eventArr) {
                    event.put(eventType.substring(0, 2) + "_name", eventName);
                }
            } else {
                eventArr = eventList.get(eventIdList.indexOf(eventId));
            }
            if (eventType.equals("planting") && !eventArr.isEmpty()) {
                trt.put("sdate", ((JSONObject) eventArr.get(0)).getOrBlank("date"));
            }
            trt.put(eventType.substring(0, 2) + "id", eventIdList.indexOf(eventId) + 1);
        }
    }
    
    private static String toYYDDDStr(String dateUTCStr) {
        LocalDate localDate = LocalDate.parse(dateUTCStr, DateTimeFormatter.ISO_DATE);
        return String.format("%02d%03d", localDate.getYear() % 100, localDate.getDayOfYear());
    }
}
