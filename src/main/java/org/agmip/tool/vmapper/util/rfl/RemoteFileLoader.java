package org.agmip.tool.vmapper.util.rfl;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashMap;
import org.agmip.tool.vmapper.util.JSONObject;
import static org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSAction.*;
import static org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSStatus.*;
import org.eclipse.jetty.websocket.api.Session;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketClose;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketConnect;
import org.eclipse.jetty.websocket.api.annotations.OnWebSocketMessage;
import org.eclipse.jetty.websocket.api.annotations.WebSocket;

/**
 *
 * @author Meng Zhang
 */
@WebSocket
public class RemoteFileLoader {

    private HashMap<Integer, String> cache;

    @OnWebSocketConnect
    public void onConnect(Session user) throws Exception {
    }

    @OnWebSocketClose
    public void onClose(Session user, int statusCode, String reason) {
    }

    @OnWebSocketMessage
    public void onMessage(Session user, String message) {
        WebSocketFileTranMsg wsmsg = new WebSocketFileTranMsg(message);
        if (wsmsg.isResponse()) {

        } else {
            switch (wsmsg.getAction()) {
                case Init:
                    try {
                        URL url = new URL(wsmsg.fileUrl);
                        URLConnection conn = url.openConnection();
                        cache = new HashMap();
                        if (WebSocketUtil.sendMsg(user, Init, Success, new JSONObject()
                                .put("name", WebSocketUtil.getRemoteFileName(url))
//                                .put("type", conn.getContentType())
                                .put("type", WebSocketUtil.getRemoteMIMEType(url))
                                .put("size", conn.getContentLengthLong()))) {
                            try (InputStream is = conn.getInputStream()) {
                                byte[] buff = new byte[is.available()];
                                if (buff.length == 0) {
                                    buff = new byte[1024];
                                }
                                int count = 0;
                                int ret = is.read(buff);
                                while (ret > 0) {
                                    if (ret < buff.length) {
                                        buff = Arrays.copyOfRange(buff, 0, ret);
                                    }
                                    String data = Base64.getEncoder().encodeToString(buff);
                                    cache.put(count, data);
                                    
                                    int resent = 0;
                                    while(!WebSocketUtil.sendMsg(user, Sent, Success, new JSONObject()
                                            .put("buff", cache.get(count))
                                            .put("idx", count)
                                            .put("size", ret))
                                            && resent < 5
                                    ) { resent++; }
                                    if (resent >= 5) {
                                        WebSocketUtil.sendMsg(user, Sent, Sent_Failed, new JSONObject()
                                            .put("idx", count));
                                    }
                                    ret = is.read(buff);
                                    count++;
                                }
                            }
                        } else {
                            WebSocketUtil.sendMsg(user, Init, Init_Failed);
                        }
                    } catch (MalformedURLException e) {
                        e.printStackTrace(System.err);
                        WebSocketUtil.sendMsg(user, Init, Error, e.getMessage());
                    } catch (IOException e) {
                        e.printStackTrace(System.err);
                        WebSocketUtil.sendMsg(user, Init, Error, e.getMessage());
                    }
                    break;
                case Received:
                    cache.remove(wsmsg.getBuffIdx());
                    if (cache.isEmpty()) {
                        WebSocketUtil.sendMsg(user, Finish, Success);
                    }
                    break;
                case Resent:
                    int idx = wsmsg.getBuffIdx();
                    if (idx > -1) {
                        String bb = cache.get(idx);
                        if (bb != null) {
                            if (!WebSocketUtil.sendMsg(user, Sent, Success, new JSONObject()
                                    .put("buff", bb)
                                    .put("idx", idx)
                                    .put("size", Base64.getDecoder().decode(bb).length))) {
                                WebSocketUtil.sendMsg(user, Sent, Sent_Failed, new JSONObject()
                                            .put("idx", idx));
                            }
                        }
                    } else {
                        for (int i : cache.keySet().toArray(new Integer[0])) {
                            String bb = cache.get(i);
                            if (bb != null) {
                                WebSocketUtil.sendMsg(user, Sent, Success, new JSONObject()
                                        .put("buff_data", bb)
                                        .put("buff_idx", i));
                            }
                        }
//                        WebSocketUtil.sendMsg(user, AllSent, Success);
                    }
                    break;
                case Finish:
                    cache = null;
                    break;
                default:
                    WebSocketUtil.sendMsg(user, UnknownAct, UnknownRet);
            }
        }
    }
}
