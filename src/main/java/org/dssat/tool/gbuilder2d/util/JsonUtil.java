package org.dssat.tool.gbuilder2d.util;

import ch.qos.logback.classic.Logger;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.logging.Level;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Meng Zhang
 */
public class JsonUtil {

    private static final Logger LOG = (Logger) LoggerFactory.getLogger(JsonUtil.class);
    private static final JSONParser PARSER = new JSONParser();
//    private static final JsonFactory FACTORY = new JsonFactory();
    public static final String EMPTY_ARRAY = "[]";
    public static final String EMPTY_DOC = "{}";
    
//    public static String toJsonStr(Object data){
//        try {
//        return new String(toJsonByteArray(data));
//        } catch (JsonProcessingException ex) {
//            LOG.warn(ex.getMessage());
//            return null;
//        }
//    }
    
    public static JSONObject parseFrom(File jsonFile) {
        try (FileReader fr = new FileReader(jsonFile)) {
            Object tmp = PARSER.parse(fr);
            if (tmp instanceof org.json.simple.JSONArray) {
                return parseFrom(((org.json.simple.JSONArray) tmp).toJSONString());
            }
            return new JSONObject((Map) PARSER.parse(fr));
        } catch (FileNotFoundException ex) {
            java.util.logging.Logger.getLogger(JsonUtil.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException | ParseException ex) {
            java.util.logging.Logger.getLogger(JsonUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return new JSONObject();
    }
    
    public static JSONObject parseFrom(String jsonString) {
        try {
            if (jsonString.startsWith("[")) {
                jsonString = "{\"data\":" + jsonString + "}";
            }
            return new JSONObject((Map) PARSER.parse(jsonString));
        } catch (ParseException ex) {
            java.util.logging.Logger.getLogger(JsonUtil.class.getName()).log(Level.SEVERE, null, ex);
        }
        return new JSONObject();
    }
}
