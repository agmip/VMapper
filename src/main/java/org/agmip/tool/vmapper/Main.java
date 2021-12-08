package org.agmip.tool.vmapper;

import ch.qos.logback.classic.Level;
import ch.qos.logback.classic.Logger;
import java.awt.Desktop;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import org.agmip.tool.vmapper.util.DataUtil;
import org.agmip.tool.vmapper.util.Path;
import org.agmip.tool.vmapper.util.rfl.RemoteFileLoader;
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
import static spark.Spark.staticFiles;
import static spark.Spark.webSocket;
import spark.embeddedserver.EmbeddedServers;
import spark.embeddedserver.jetty.EmbeddedJettyFactory;
import spark.embeddedserver.jetty.JettyServerFactory;
import spark.template.freemarker.FreeMarkerEngine;

/**
 *
 * @author Meng Zhang
 */
public class Main {
    
    private static final int DEF_PORT = Path.Folder.DEF_PORT;
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
        LOG.info(DataUtil.getProductInfo());

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
        webSocket(Path.Web.Data.LOAD_FILE, RemoteFileLoader.class);
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
            return new FreeMarkerEngine().render(new ModelAndView(getEnvData(), Path.Template.INDEX));
                });
        
        get(Path.Web.INDEX, (Request request, Response response) -> {
            return new FreeMarkerEngine().render(new ModelAndView(getEnvData(), Path.Template.INDEX));
                });
        
        get(Path.Web.Tools.UNIT_MASTER, (Request request, Response response) -> {
            HashMap data = getEnvData();
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
        
        get(Path.Web.Tools.DATA_FACTORY, (Request request, Response response) -> {
            response.redirect(Path.Web.Tools.VMAPPER);
            return "Redirect to " + Path.Web.Tools.VMAPPER;
                });
        
        get(Path.Web.Tools.VMAPPER, (Request request, Response response) -> {
            HashMap data = getEnvData();
            data.put("icasaMgnVarMap", DataUtil.getICASAMgnVarMap());
            data.put("icasaObvVarMap", DataUtil.getICASAObvVarMap());
            data.put("icasaMgnCodeMap", DataUtil.getICASAMgnCodeMap());
            data.put("culMetaList", DataUtil.getICASACropCodeMap());
            return new FreeMarkerEngine().render(new ModelAndView(data, Path.Template.Demo.DATA_FACTORY));
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
    
    private static HashMap getEnvData() {
        HashMap data = new HashMap();
        data.put("env_path_web_root", Path.Web.URL_ROOT);
        data.put("env_path_web_tools", new Path.Web.Tools());
        data.put("env_path_web_data", new Path.Web.Data());
        data.put("env_version", DataUtil.getProductVersion());
        return data;
    }
}
