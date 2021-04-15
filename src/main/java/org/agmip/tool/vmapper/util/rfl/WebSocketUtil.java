package org.agmip.tool.vmapper.util.rfl;

import ch.qos.logback.classic.Logger;
import java.io.IOException;
import java.nio.ByteBuffer;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSAction;
import org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSStatus;
import org.eclipse.jetty.websocket.api.Session;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Meng Zhang
 */
public class WebSocketUtil {
    
    private static final Logger LOG = (Logger) LoggerFactory.getLogger(WebSocketUtil.class);
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status) {
        return sendMsg(receiver, action, status, "");
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, String message) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (message != null && !message.isEmpty()) {
            msg.setMessage(message);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, ByteBuffer data) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (data != null) {
            msg.setData(data);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, ByteBuffer data, JSONObject messages) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (data != null) {
            msg.setData(data);
        }
        if (messages != null) {
            msg.getMsg().putAll(messages);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, JSONObject messages) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (messages != null) {
            msg.getMsg().putAll(messages);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WebSocketMsg msg) {
        try {
            receiver.getRemote().sendString(String.valueOf(msg.getMsg()));
        } catch (IOException ex) {
            LOG.warn(ex.getMessage());
            return false;
        }
        return true;
    }
}
