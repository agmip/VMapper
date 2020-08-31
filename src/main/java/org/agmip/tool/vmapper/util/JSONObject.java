package org.agmip.tool.vmapper.util;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Map;

/**
 *
 * @author Meng Zhang
 */
public class JSONObject extends org.json.simple.JSONObject {

    public JSONObject() {
        super();
    }

    public JSONObject(Map m) {
        super(m);
        for (Object key : m.keySet()) {
            if (m.get(key) instanceof Map) {
                super.put(key, new JSONObject((Map) m.get(key)));
            }
        }
    }

    public JSONObject(org.json.simple.JSONObject o) {
        super(o);
        for (Object key : o.keySet()) {
            if (o.get(key) instanceof org.json.simple.JSONObject) {
                super.put(key, new JSONObject((org.json.simple.JSONObject) o.get(key)));
            }
        }
    }

    public String getOrBlank(String key) {
        return (String) getOrDefault(key, "");
    }

    public String getOrDefault(String key, String def) {
        Object val = super.getOrDefault(key, def);
        if (val == null) {
            return def;
        } else {
            return val.toString();
        }
    }

    public Integer getAsInteger(String key) {
        String read = getOrBlank(key);
        if (!read.isEmpty()) {
            return new BigDecimal(read).intValue();
        }
        return null;
    }

    public Double getAsDouble(String key, int round) {
        String read = getOrBlank(key);
        if (!read.isEmpty()) {
            return new BigDecimal(read).setScale(round, BigDecimal.ROUND_HALF_UP).doubleValue();
        }
        return null;
    }

    public JSONObject getAsObj(String key) {
        if (!this.containsKey(key)) {
            this.put(key, new JSONObject());
        }
        return (JSONObject) this.get(key);
    }

    public Double getAsDouble(String key) {
        String read = getOrBlank(key);
        if (!read.isEmpty()) {
            return new BigDecimal(read).doubleValue();
        }
        return null;
    }

    public ArrayList<String> getArr() {
        return getArr("data");
    }

    public ArrayList<String> getArr(String key) {
        if (this.containsKey(key)) {
            ArrayList<String> ret = new ArrayList();
            for (Object o : (ArrayList) this.get(key)) {
                ret.add(o.toString());
            }
            return ret;
        } else {
            return new ArrayList();
        }
    }

    public ArrayList<Double> getArrAsDouble() {
        return getArrAsDouble("data");
    }

    public ArrayList<Double> getArrAsDouble(String key) {
        if (this.containsKey(key)) {
            ArrayList<Double> ret = new ArrayList();
            for (Object o : (ArrayList) this.get(key)) {
                ret.add((Double) o);
            }
            return ret;
        } else {
            return new ArrayList();
        }
    }

    public ArrayList<JSONObject> getObjArr() {
        return getObjArr("data");
    }

    public JSONArray getObjArr(String key) {
        if (this.containsKey(key)) {
            JSONArray ret = new JSONArray();
            for (Object o : (ArrayList) this.get(key)) {
                ret.add(new JSONObject((Map) o));
            }
            return ret;
        } else {
            return new JSONArray();
        }
    }
    
    public String getObjId() {
        return getObjId("_id");
    }
    
    public String getObjId(String key) {
        Object id = this.get(key);
        if (id != null) {
            return ((Map)id).get("$oid").toString();
        } else {
            return "";
        }
    }
    
    @Override
    public JSONObject put(Object key, Object value) {
        super.put(key, value);
        return this;
    }
}
