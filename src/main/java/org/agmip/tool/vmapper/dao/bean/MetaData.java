package org.agmip.tool.vmapper.dao.bean;

import lombok.Data;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.JsonUtil;

/**
 *
 * @author Meng Zhang
 */
@Data
public class MetaData {
    
    private String exname;
    private String crid;
    private String address;
    private String people;
    private String site;
    private String notes;
    
    public static MetaData readFromJson(String jsonStr) {
        JSONObject data = JsonUtil.parseFrom(jsonStr);
        return readFromJson(data);
    }
    
    public static MetaData readFromJson(JSONObject data) {
        MetaData ret = new MetaData();
        ret.setExname(data.getOrDefault("exname", ""));
        ret.setCrid(data.getOrDefault("crid", ""));
        ret.setAddress(data.getOrDefault("ex_address", ""));
        ret.setSite(data.getOrDefault("site_name", ""));
        ret.setPeople(data.getOrDefault("person_notes", ""));
        ret.setNotes(data.getOrDefault("exp_narr", ""));
        return ret;
    }
    
    public String getCrop() {
        if (crid == null) {
            return "";
        } else if (crid.equalsIgnoreCase("TOM")) {
            return "Tomato";
        } else if (crid.equalsIgnoreCase("POT")) {
            return "Potato";
        } else {
            return crid;
        }
    }
}
