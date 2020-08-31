package org.agmip.tool.vmapper.util;

import org.agmip.tools.unithelper.UnitConverter;

/**
 *
 * @author Meng Zhang
 */
public class UnitUtil {
    
    public static JSONObject getUnitInfo(String unit) {
        JSONObject ret = new JSONObject();
        String desc = UnitConverter.getDescp(unit);
        if (desc == null || desc.isEmpty()) {
            desc = "undefined unit expression";
        }
        String category = UnitConverter.getCategory(unit);
        if (category == null || category.isEmpty()) {
            category = "unknown category";
        }
        ret.put("message", desc);
        ret.put("category", category);
        return ret;
    }
    
    public static JSONArray getUnitInfoByType(String unitType) {
        JSONArray ret = new JSONArray();
        ret.addAll(UnitConverter.listUnitJsonArray(unitType));
        return ret;
    }
    
    public static JSONObject convertUnit(String unitFrom, String unitTo, String valueFrom) {
        JSONObject ret = new JSONObject(UnitConverter.convertToJsonObj(unitFrom, unitTo, valueFrom));
        return ret;
    }
    
    public static JSONObject listBaseUnit() {
        return new JSONObject(UnitConverter.getBaseUnitMap());
    }
    
    public static JSONArray listPrefix() {
        JSONArray ret = new JSONArray();
        ret.putAll(UnitConverter.listPrefix());
        return ret;
    }
}
