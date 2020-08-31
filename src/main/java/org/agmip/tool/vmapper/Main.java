package org.agmip.tool.vmapper;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.HashMap;
import org.agmip.tool.vmapper.dao.MetaDataDAO;
import org.agmip.tool.vmapper.util.DataUtil;
import org.agmip.tool.vmapper.util.DssatDataUtil;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.JsonUtil;
import org.agmip.tool.vmapper.util.Path;
import org.agmip.tool.vmapper.util.UnitUtil;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.thread.QueuedThreadPool;
import org.eclipse.jetty.util.thread.ThreadPool;
import org.slf4j.LoggerFactory;
import spark.ModelAndView;
import spark.Request;
import spark.Response;
import spark.Spark;
import static spark.Spark.before;
import static spark.Spark.get;
import static spark.Spark.options;
import static spark.Spark.port;
import static spark.Spark.post;
import static spark.Spark.staticFiles;
import spark.embeddedserver.EmbeddedServers;
import spark.embeddedserver.jetty.EmbeddedJettyFactory;
import spark.embeddedserver.jetty.JettyServerFactory;
import spark.template.freemarker.FreeMarkerEngine;

/**
 *
 * @author Meng Zhang
 */
public class Main {
    
    private static final int DEF_PORT = 8081;
    public static final Logger LOG = (Logger) LoggerFactory.getLogger(Logger.ROOT_LOGGER_NAME);
    
    public static void main(String[] args) {
        // Configure Spark
        EmbeddedServers.add(EmbeddedServers.Identifiers.JETTY, new EmbeddedJettyFactory(new JettyServerFactory() {
            @Override
            public Server create(int maxThreads, int minThreads, int threadTimeoutMillis) {
                Server server;

                if (maxThreads > 0) {
                    int max = maxThreads;
                    int min = (minThreads > 0) ? minThreads : 8;
                    int idleTimeout = (threadTimeoutMillis > 0) ? threadTimeoutMillis : 60000;

                    server = new Server(new QueuedThreadPool(max, min, idleTimeout));
                } else {
                    server = new Server();
                }
                server.setAttribute("org.eclipse.jetty.server.Request.maxFormContentSize", 1024 * 1024);

                return server;
            }

            @Override
            public Server create(ThreadPool threadPool) {
                Server server = threadPool != null ? new Server(threadPool) : new Server();
                server.setAttribute("org.eclipse.jetty.server.Request.maxFormContentSize", 1024 * 1024);
                return server;
            }
        }));
//                (maxThreads, minThreads, threadTimeoutMillis) -> {
//            Server server = new Server();
//            server.setAttribute("org.eclipse.jetty.server.Request.maxFormContentSize", 1024 * 1024);
//            return server;
//        }));
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
        options("/*",
        (request, response) -> {

            String accessControlRequestHeaders = request
                    .headers("Access-Control-Request-Headers");
            if (accessControlRequestHeaders != null) {
                response.header("Access-Control-Allow-Headers",
                        accessControlRequestHeaders);
            }

            String accessControlRequestMethod = request
                    .headers("Access-Control-Request-Method");
            if (accessControlRequestMethod != null) {
                response.header("Access-Control-Allow-Methods",
                        accessControlRequestMethod);
            }

            return "OK";
        });
        before((request, response) -> response.header("Access-Control-Allow-Origin", "*"));

        // Set up before-filters (called before each get/post)
//        before("*",                  Filters.addTrailingSlashes);
//        before("*",                  Filters.handleLocaleChange);

        // Set up routes
        get("/", (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("culMetaList", DataUtil.getCulMetaDataList());
            data.put("soils", DataUtil.getSoilDataList());
            data.put("weathers", DataUtil.getWthDataList());
            data.put("icasaMgnCodeMap", DataUtil.getICASAMgnCodeMap());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.XBUILDER2D));
                });
        
        get(Path.Web.Demo.GBUILDER1D, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.GBUILDER1D));
                });
        
        get(Path.Web.Demo.GBUILDER2D, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(new HashMap(), Path.Template.Demo.GBUILDER2D));
                });
        
        get(Path.Web.Demo.UNIT_MASTER, (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("baseUnits", UnitUtil.listBaseUnit());
            data.put("prefixes", UnitUtil.listPrefix());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.UNIT_MASTER));
                });
        
        get(Path.Web.Data.UNIT_LOOKUP, (Request request, Response response) -> {
            String unit = request.queryParams("unit");
            String type = request.queryParams("type");
            if (type != null && unit == null) {
                return UnitUtil.getUnitInfoByType(type).toJSONString();
            } else {
                return UnitUtil.getUnitInfo(unit).toJSONString();
            }
                });
        
        get(Path.Web.Data.UNIT_CONVERT, (Request request, Response response) -> {
            String unitFrom = request.queryParams("unit_from");
            String unitTo = request.queryParams("unit_to");
            String valueFrom = request.queryParams("value_from");
            return UnitUtil.convertUnit(unitFrom, unitTo, valueFrom).toJSONString();
                });
        
        get(Path.Web.Demo.XBUILDER2D, (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("culMetaList", DataUtil.getCulMetaDataList());
            data.put("soils", DataUtil.getSoilDataList());
            data.put("weathers", DataUtil.getWthDataList());
            data.put("icasaMgnCodeMap", DataUtil.getICASAMgnCodeMap());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.XBUILDER2D));
                });
        
        get(Path.Web.Demo.METALIST, (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("metalist", MetaDataDAO.list());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.METALIST));
                });
        
        get(Path.Web.Demo.XML_EDITOR, (Request request, Response response) -> {
            HashMap data = new HashMap();
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.XML_EDITOR));
                });
        
        get(Path.Web.Demo.DATA_FACTORY, (Request request, Response response) -> {
            response.redirect(Path.Web.Demo.VMAPPER);
            return "Redirect to " + Path.Web.Demo.VMAPPER;
                });
        
        get(Path.Web.Demo.VMAPPER, (Request request, Response response) -> {
            HashMap data = new HashMap();
            data.put("icasaMgnVarMap", DataUtil.getICASAMgnVarMap());
            data.put("icasaObvVarMap", DataUtil.getICASAObvVarMap());
            data.put("icasaMgnCodeMap", DataUtil.getICASAMgnCodeMap());
            data.put("culMetaList", DataUtil.getICASACropCodeMap());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.DATA_FACTORY));
                });
        
        post(Path.Web.Translator.XML, (Request request, Response response) -> {
            HashMap data = new HashMap();
            String jsonStr = request.queryParams("io");
            JSONObject rawData = JsonUtil.parseFrom(jsonStr);
            
            // Handle io data
            ArrayList<JSONObject> ioData = rawData.getObjArr();
            data.put("io", ioData);
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Translator.XML));
        });
        
        get(Path.Web.Data.CULTIVAR, (Request request, Response response) -> {
            String crid = request.queryParams("crid");
            return DataUtil.getCulDataList(crid).toJSONString();
                });
        
        post(Path.Web.Translator.DSSAT_EXP, (Request request, Response response) -> {
            HashMap data = DssatDataUtil.readFromRequest(request);
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Translator.DSSAT_EXP));
                });
//        get("*",                     PageController.serveNotFoundPage, new FreeMarkerEngine());

        //Set up after-filters (called after each get/post)
        
//        after("*",                   Filters.addGzipHeader);
        } catch (Exception e) {
            e.printStackTrace(System.err);
        }
//        System.out.println("System start @ " + port + " on " + DataUtil.getLastBuildTS());
        if (Desktop.isDesktopSupported()) {
            try {
                Desktop.getDesktop().browse(new URI("http://localhost:" + port + "/"));
            } catch (IOException | URISyntaxException ex) {
                LOG.warn(ex.getMessage());
            }
        }
    }
}
