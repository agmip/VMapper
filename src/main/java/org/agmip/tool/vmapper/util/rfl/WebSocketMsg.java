package org.agmip.tool.vmapper.util.rfl;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Base64;
import lombok.Data;
import lombok.Getter;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.JsonUtil;

/**
 *
 * @author Meng Zhang
 */
@Data
public class WebSocketMsg {

    public enum WSAction {
        Init,
        Finish,
        Sent,
        Received,
//        AllSent,
        Resent,
        UnknownAct
    }

    public enum WSStatus {

        Success(200),
        Init_Failed(601),
        Sent_Failed(602),
        Error(900),
        UnknownRet(0);

        private final int code;

        private WSStatus(int code) {
            this.code = code;
        }

        public int getStatusCode() {
            return this.code;
        }
    }

    @Getter private JSONObject msg;
    @Getter private boolean response;
    @Getter private int status;
    @Getter private WSAction action;
    @Getter private String hash;
    @Getter private String message;
    @Getter private String data;

    private static final String ACTION = "action";
    private static final String STATUS = "status";
    private static final String HASH = "hash";
    private static final String MESSAGE = "message";
    private static final String DATA = "buff";

    public WebSocketMsg(String msg) {
        this.msg = JsonUtil.parseFrom(msg);
        init();
    }

    public WebSocketMsg(JSONObject msg) {
        this.msg = msg;
        init();
    }

    public WebSocketMsg(WSAction action, WSStatus status) {
        this.action = action;
        this.status = status.getStatusCode();
        this.msg = new JSONObject()
                .put(ACTION, action.toString())
                .put(STATUS, status.getStatusCode());
    }

    private void init() {
        try {
            action = Enum.valueOf(WSAction.class, msg.getOrBlank(ACTION));
        } catch (Exception e) {
            action = WSAction.UnknownAct;
        }
        try {
            status = Integer.parseInt(msg.getOrBlank(STATUS));
        } catch (Exception e) {
            status = 0;
        }
        response = status > 0;
        hash = msg.getOrBlank(HASH);
        message = msg.getOrBlank(MESSAGE);
    }
    
    public void setMessage(String message) {
        this.message = message;
        this.msg.put(MESSAGE, message);
    }
    
    public void setData(String base64StrData) {
        this.data = base64StrData;
        this.msg.put(DATA, this.data);
    }
    
    public void setData(ByteBuffer data) {
        byte[] arr = data.array();
        if (arr.length > data.limit()) {
            arr = Arrays.copyOfRange(arr, 0, data.limit());
        }
        this.data = Base64.getEncoder().encodeToString(arr);
        this.msg.put(DATA, this.data);
    }
}
