package org.dssat.tool.gbuilder2d;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
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
import static spark.Spark.after;
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
        } catch (Exception e) {
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
            JSONObject expData = JsonUtil.parseFrom(request.queryParams("exp"));
            switch (expData.getOrBlank("crid")) {
                case "TOM": expData.put("crid_dssat", "TM");break;
                case "POT": expData.put("crid_dssat", "PT");break;
            }
            data.put("expData", expData);
            JSONObject fieldData = JsonUtil.parseFrom(request.queryParams("field"));
            ArrayList<JSONObject> treatments = JsonUtil.parseFrom(request.queryParams("treatment")).getObjArr();
            ArrayList<String> fieldNameList = new ArrayList();
            ArrayList fieldList = new ArrayList();
            for (JSONObject trt : treatments) {
                String field = trt.getOrBlank("field");
                if (!field.isEmpty()) {
                    if (!fieldNameList.contains(field)) {
                        fieldNameList.add(field);
                        fieldList.add(fieldData.get(field));
                    }
                    trt.put("fid", fieldNameList.indexOf(field) + 1);
                }
                
            }
            data.put("fields", fieldList);
            data.put("treatments", treatments);
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
}
