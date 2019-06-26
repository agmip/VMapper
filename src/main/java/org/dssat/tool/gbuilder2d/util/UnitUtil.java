package org.dssat.tool.gbuilder2d.util;

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
        ret.put("message", desc);
        return ret;
    }
    
    public static JSONObject convertUnit(String unitFrom, String unitTo, String valueFrom) {
        JSONObject ret = new JSONObject(UnitConverter.convertToJsonObj(unitFrom, unitTo, valueFrom));
        return ret;
    }
}
