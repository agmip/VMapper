package org.agmip.tools.unithelper;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.simple.JSONObject;
import ucar.units.BaseUnit;
import ucar.units.ConversionException;
import ucar.units.NameException;
import ucar.units.NoSuchUnitException;
import ucar.units.PrefixDBException;
import ucar.units.SpecificationException;
import ucar.units.Unit;
import ucar.units.UnitDB;
import ucar.units.UnitDBException;
import ucar.units.UnitDBManager;
import ucar.units.UnitFormat;
import ucar.units.UnitFormatManager;
import ucar.units.UnitParseException;
import ucar.units.UnitSystemException;
import ucar.units.UnknownUnit;

/**
 * Utility class which contains a collection of static method used for unit
 * conversion.
 *
 * @author Meng Zhang
 */
public class UnitConverter {

//    private static UnitDB DB = UnitDBManager.instance();
    private static final HashMap<String, String> AGMIP_UNIT = new HashMap();
    private static final UnitFormat PARSER = init();

    private UnitConverter() {
    }
    
    private static UnitFormat init() {
        AGMIP_UNIT.put("number", "count");
        AGMIP_UNIT.put("dap", "day");
        AGMIP_UNIT.put("doy", "day");
        AGMIP_UNIT.put("decimal_degree", "degree");
        AGMIP_UNIT.put("fraction", "1");
        AGMIP_UNIT.put("unitless", "1");
        AGMIP_UNIT.put("ratio", "1");
        try {
            UnitDB db = UnitDBManager.instance();
            for (String key : AGMIP_UNIT.keySet()) {
                db.addAlias(key, AGMIP_UNIT.get(key));
            }
        } catch (UnitDBException | NoSuchUnitException | NameException ex) {
            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return UnitFormatManager.instance();
    }

    public static BigDecimal convert(String fromUnit, String toUnit, String val) throws UnitParseException, SpecificationException, NoSuchUnitException, UnitDBException, PrefixDBException, UnitSystemException, ConversionException {
        return convert(fromUnit, toUnit, new BigDecimal(val));
    }

    public static BigDecimal convert(String fromUnit, String toUnit, String val, int scale) throws UnitParseException, SpecificationException, NoSuchUnitException, UnitDBException, PrefixDBException, UnitSystemException, ConversionException {
        return convert(fromUnit, toUnit, new BigDecimal(val), scale);
    }

    public static BigDecimal convert(String fromUnit, String toUnit, BigDecimal val) throws UnitParseException, SpecificationException, NoSuchUnitException, UnitDBException, PrefixDBException, UnitSystemException, ConversionException {
        Unit from = PARSER.parse(removeComment(fromUnit));
        Unit to = PARSER.parse(removeComment(toUnit));
        BigDecimal ret = new BigDecimal(from.convertTo(val.doubleValue(), to));
        int scale = ret.scale() + val.precision() - ret.precision();
        ret = ret.setScale(scale + 1, RoundingMode.HALF_UP);
        BigDecimal alt = ret.setScale(scale, RoundingMode.HALF_UP);
        while (ret.doubleValue() == alt.doubleValue()) {
            ret = alt;
            if (scale > 0) {
                scale--;
                alt = alt.setScale(scale, RoundingMode.HALF_UP);
            } else {
                break;
            }
        }
        return ret;
    }

    public static BigDecimal convert(String fromUnit, String toUnit, BigDecimal val, int scale) throws UnitParseException, SpecificationException, NoSuchUnitException, UnitDBException, PrefixDBException, UnitSystemException, ConversionException {
        Unit from = PARSER.parse(removeComment(fromUnit));
        Unit to = PARSER.parse(removeComment(toUnit));
        return new BigDecimal(from.convertTo(val.doubleValue(), to)).setScale(scale, RoundingMode.HALF_UP);
    }

    public static JSONObject convertToJsonObj(String fromUnit, String toUnit, String val) {
        return convertToJsonObj(fromUnit, toUnit, new BigDecimal(val));
    }

    public static JSONObject convertToJsonObj(String fromUnit, String toUnit, String val, int scale) {
        return convertToJsonObj(fromUnit, toUnit, new BigDecimal(val), scale);
    }

    public static JSONObject convertToJsonObj(String fromUnit, String toUnit, BigDecimal val) {
//        return convertToJsonObj(fromUnit, toUnit, val, val.scale());
        JSONObject ret = new JSONObject();
        ret.put("unit_from", fromUnit);
        ret.put("unit_to", toUnit);
        ret.put("value_from", val.toPlainString());
        try {
            ret.put("value_to", convert(fromUnit, toUnit, val).toPlainString());
            ret.put("status", "0");
            ret.put("message", "successful");
        } catch (SpecificationException | UnitDBException | PrefixDBException | UnitSystemException | ConversionException ex) {
            ret.put("status", "1");
            ret.put("message", ex.getMessage());
        } catch (Exception ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
            ret.put("status", "1");
            ret.put("message", "undefined unit");
        }
//        catch (SpecificationException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (UnitDBException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (PrefixDBException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (UnitSystemException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (ConversionException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        }

        return ret;
    }

    public static JSONObject convertToJsonObj(String fromUnit, String toUnit, BigDecimal val, int scale) {
        JSONObject ret = new JSONObject();
        ret.put("unit_from", fromUnit);
        ret.put("unit_to", toUnit);
        ret.put("value_from", val.toPlainString());
        try {
            ret.put("value_to", convert(fromUnit, toUnit, val, scale).toPlainString());
            ret.put("status", "0");
            ret.put("message", "successful");
        } catch (SpecificationException | UnitDBException | PrefixDBException | UnitSystemException | ConversionException ex) {
            ret.put("status", "1");
            ret.put("message", ex.getMessage());
        } catch (Exception ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
            ret.put("status", "1");
            ret.put("message", "undefined unit");
        }
//        catch (SpecificationException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (UnitDBException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (PrefixDBException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (UnitSystemException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        } catch (ConversionException ex) {
//            Logger.getLogger(UnitConverter.class.getName()).log(Level.SEVERE, null, ex);
//        }

        return ret;
    }

    public static String convertToJsonStr(String fromUnit, String toUnit, String val) {
        return convertToJsonStr(fromUnit, toUnit, new BigDecimal(val));
    }

    public static String convertToJsonStr(String fromUnit, String toUnit, String val, int scale) {
        return convertToJsonStr(fromUnit, toUnit, new BigDecimal(val), scale);
    }

    public static String convertToJsonStr(String fromUnit, String toUnit, BigDecimal val) {
        return convertToJsonObj(fromUnit, toUnit, val).toJSONString();
    }

    public static String convertToJsonStr(String fromUnit, String toUnit, BigDecimal val, int scale) {
        return convertToJsonObj(fromUnit, toUnit, val, scale).toJSONString();
    }

    protected static String removeComment(String unit) {
        return unit.replaceAll("[\\./]?\\[\\S*\\]\\^?-?\\d*", "").replaceAll("\\s", "");
    }

    public static boolean isValid(String unitStr) {
        try {
            return PARSER.parse(removeComment(unitStr)) != null;
        } catch (Exception ex) {
            return false;
        }
    }

    public static String getDescp(String unitStr) {
        String unitStrNoComment = removeComment(unitStr);
        if (AGMIP_UNIT.containsKey(unitStrNoComment)) {
            String agmipRet = AGMIP_UNIT.get(unitStrNoComment);
            if (agmipRet.equals("1")) {
                return unitStrNoComment;
            }
        }
        try {
            Unit unit = PARSER.parse(unitStrNoComment);
            String ret = unit.toString();
            if (unit instanceof UnknownUnit) {
                ret = "";
            } else if (unit instanceof BaseUnit) {
                ret = unit.getName();
            } else if (unit.getDerivedUnit() instanceof UnknownUnit) {
                ret = "";
            }
            return ret;
        } catch (Exception ex) {
            return "";
        }
    }
}
