package org.agmip.tools.unithelper;

import java.math.BigDecimal;
import java.math.RoundingMode;
import org.json.simple.JSONObject;
import ucar.units.ConversionException;
import ucar.units.NoSuchUnitException;
import ucar.units.PrefixDBException;
import ucar.units.SpecificationException;
import ucar.units.Unit;
import ucar.units.UnitDBException;
import ucar.units.UnitFormat;
import ucar.units.UnitFormatManager;
import ucar.units.UnitParseException;
import ucar.units.UnitSystemException;

/**
 * Utility class which contains a collection of static method used for unit
 * conversion.
 *
 * @author Meng Zhang
 */
public class UnitConverter {

//    private static UnitDB DB = UnitDBManager.instance();
    private static final UnitFormat PARSER = UnitFormatManager.instance();

    private UnitConverter() {
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
        int scale = -1;
        String ret = Double.toString(from.convertTo(val.doubleValue(), to));
//        if (!ret.contains(".")) {
//            scale = 0;
//        } else {
//            String retDec = ret.split("\\.")[1];
//            if (!retDec.contains("0")) {
//                scale = -1;
//            } else {
//                char[] retDecArr = retDec.toCharArray();
//                for (int i = 0; i < retDecArr.length; i++) {
//                    if (retDecArr[i] == )
//                }
//                scale = retDec.indexOf("0");
//            }
//            
//        }
        if (scale < 0) {
            return new BigDecimal(ret);
        } else {
            return new BigDecimal(ret).setScale(scale, RoundingMode.HALF_UP);
        }
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

    private static String removeComment(String unit) {
        return unit.replaceAll("\\[\\S*\\]", "").replaceAll("\\s", "");
    }

    public static boolean isValid(String unitStr) {
        try {
            return PARSER.parse(removeComment(unitStr)) != null;
        } catch (Exception ex) {
            return false;
        }
    }

    public static String getDescp(String unitStr) {
        try {
            Unit unit = PARSER.parse(removeComment(unitStr));
            String ret = unit.toString();
            if (ret.equals(unitStr)) {
                ret = unit.getName();
            }
            return ret;
        } catch (Exception ex) {
            return "";
        }
    }
}
