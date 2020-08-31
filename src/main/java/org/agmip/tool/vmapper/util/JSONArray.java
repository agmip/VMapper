package org.agmip.tool.vmapper.util;

import java.util.Collection;
import java.util.Map;

/**
 *
 * @author Meng Zhang
 */
public class JSONArray extends org.json.simple.JSONArray {
    
    public JSONArray put(Object e) {
        super.add(e);
        return this;
    }
    
    public JSONArray putAll(Collection c) {
        super.addAll(c);
        return this;
    }
    
    public JSONObject getObj(int index) {
        Object ret = super.get(index);
        if (ret instanceof Map) {
            return new JSONObject((Map) ret);
        } else {
            return new JSONObject();
        }
    }
    
    public String getString(int index) {
        Object ret = super.get(index);
        if (ret instanceof String) {
            return (String) ret;
        } else {
            return "";
        }
    }
    
    public Double getDouble(int index) {
        Object ret = super.get(index);
        if (ret instanceof Double) {
            return (Double) ret;
        } else {
            try {
                return Double.parseDouble(ret.toString());
            } catch (Exception e) {
                return null;
            }
        }
    }
    
    public Integer getInteger(int index) {
        Object ret = super.get(index);
        if (ret instanceof Integer) {
            return (Integer) ret;
        } else {
            try {
                return Integer.parseInt(ret.toString());
            } catch (Exception e) {
                return null;
            }
        }
    }
}
