package org.agmip.tool.vmapper.dao;

import com.mongodb.client.model.Projections;
import java.util.ArrayList;
import org.agmip.tool.vmapper.util.DBUtil.DSSATCollection;
import static org.agmip.tool.vmapper.util.DBUtil.getConnection;
import org.agmip.tool.vmapper.util.MongoDBHandler;
import org.bson.Document;
import org.bson.types.ObjectId;
import org.agmip.tool.vmapper.dao.bean.MetaData;

/**
 *
 * @author Meng Zhang
 */
public class MetaDataDAO {

    private static final String[] LIST_PARAMS = {"_id", "exname", "crid", "ex_address", "site_name", "person_notes", "exp_narr"};

    public static ArrayList<MetaData> list() {
        ArrayList<MetaData> ret = new ArrayList<>();
        ArrayList<Document> dbRetArr = MongoDBHandler.list(getConnection(DSSATCollection.MetaData),
                    Projections.include(LIST_PARAMS));

        for (Document data : dbRetArr) {
            ret.add(MetaData.readFromJson(data.toJson()));
        }
        return ret;
    }

    public static MetaData find(String exname, String userId) {
        if (exname == null || exname.isEmpty()) {
            return null;
        }
        Document dbRet = MongoDBHandler.find(getConnection(DSSATCollection.MetaData),
                new Document("exname", exname));
        if (dbRet != null) {
            return MetaData.readFromJson(dbRet.toJson());
        } else {
            return null;
        }
    }

    public static MetaData find(String id) {
        return find(new ObjectId(id));
    }

    public static MetaData find(ObjectId id) {
        if (id == null) {
            return null;
        }
        Document dbRet = MongoDBHandler.find(getConnection(DSSATCollection.MetaData),
                new Document("_id", id));
        if (dbRet != null) {
            return MetaData.readFromJson(dbRet.toJson());
        } else {
            return null;
        }
    }

//    public static ObjectId getId(String unitName, String userId) {
//        if (unitName == null || unitName.isEmpty()) {
//            return null;
//        }
//        Document dbRet = MongoDBHandler.find(getConnection(DSSATCollection.SoilData),
//                MongoDBHandler.getFindCritia(
//                        new String[]{"soil_unit_name", "user_id"},
//                        new String[]{unitName, userId}),
//                Projections.include("_id"));
//        if (dbRet != null) {
//            return dbRet.getObjectId("_id");
//        } else {
//            return null;
//        }
//    }
//
//    public static ObjectId add(SoilData soil, String currentUser) {
//        String json = AFSIRSModule.saveSoilDataJson(soil.toAFSIRSInputSoilData());
//        if (json != null && !json.isEmpty()) {
//            try {
//                String soilIdLoc = soil.getSoil_id();
//                String unitName = soil.getSoil_unit_name();
//                if (soilIdLoc != null && !soilIdLoc.isEmpty()) {
//                    ObjectId ret = getId(unitName, currentUser);
//                    if (ret != null && soilIdLoc.equals(ret.toString())) {
//                        return ret;
//                    }
//                }
//                HashCode hash = soil.getHash();
//                unitName = unitName.replaceAll("((?<!_)__\\(\\d+\\))?$", "");
//                Document data = Document.parse(json);
//                data.put("user_id", currentUser);
//                data.put("data_hash", hash.toString());
//                int count = 0;
//                while (!MongoDBHandler.add(getConnection(DSSATCollection.SoilData), data)) {
//                    if (count < 1) {
//                        count = 1;
//                        for (SoilData soilRet : list(currentUser)) {
//                            if (soilRet.getSoil_unit_name().matches("((?<!_)__\\(\\d+\\))?$") &&
//                                    soilRet.getSoil_unit_name().startsWith(unitName)) {
//                                count++;
//                            }
//                        }
//                    } else if (count > 100) {
//                        break; // TODO
//                    }
//                    soil.setSoil_unit_name(unitName + "__(" + count + ")");
//                    count++;
//                    data.put("soil_unit_name", soil.getSoil_unit_name());
//                    hash = soil.getHash();
//                    data.put("data_hash", hash.toString());
//                }
//                
//                return getId(hash);
//            } catch (Exception ex) {
//                ex.printStackTrace(System.err);
//                return null;
//            }
//        } else {
//            return null;
//        }
//    }
//
//    public static boolean update(SoilData soil, String currentUser) {
//        String json = AFSIRSModule.saveSoilDataJson(soil.toAFSIRSInputSoilData());
//        if (json != null && !json.isEmpty()) {
//            try {
//                Document data = Document.parse(json);
//                data.put("user_id", currentUser);
//                data.put("data_hash", soil.getHash().toString());
//                return MongoDBHandler.replace(getConnection(DSSATCollection.SoilData),
//                        MongoDBHandler.getFindCritia(
//                                new String[]{"soil_unit_name", "user_id"},
//                                new String[]{soil.getSoil_unit_name(), currentUser}),
//                        data) != null;
//            } catch (Exception ex) {
//                ex.printStackTrace(System.err);
//                return false;
//            }
//        } else {
//            return false;
//        }
//    }
    
    public static boolean delete(String id) {
        return delete(new ObjectId(id));
    }

    public static boolean delete(ObjectId id) {
        try {
            return MongoDBHandler.delete(getConnection(DSSATCollection.MetaData),
                    new Document("_id", id));
        } catch (Exception ex) {
            ex.printStackTrace(System.err);
            return false;
        }
    }
}
