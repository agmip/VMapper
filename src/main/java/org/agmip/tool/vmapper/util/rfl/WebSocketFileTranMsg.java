package org.agmip.tool.vmapper.util.rfl;

import lombok.Getter;
import org.agmip.tool.vmapper.util.JSONObject;

/**
 *
 * @author Meng Zhang
 */
public class WebSocketFileTranMsg extends WebSocketMsg {
    
    @Getter String fileUrl;
    @Getter int buffIdx;
    @Getter int progressPct;
    
    private static final String FILE_URL = "file_url";
    private static final String BUFF_IDX = "buff_idx";
    
    public WebSocketFileTranMsg(String msg) {
        super(msg);
        init();
    }

    public WebSocketFileTranMsg(JSONObject msg) {
        super(msg);
        init();
    }
    
    public WebSocketFileTranMsg(WSAction action, WSStatus status) {
        super(action, status);
    }

    private void init() {
        fileUrl = super.getMsg().getOrBlank(FILE_URL);
        buffIdx = super.getMsg().getAsIntegerOr(BUFF_IDX, -1);
    }
}
