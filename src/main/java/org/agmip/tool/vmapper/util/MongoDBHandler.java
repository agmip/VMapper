package org.agmip.tool.vmapper.util;

import ch.qos.logback.classic.Logger;
import com.mongodb.Block;
import com.mongodb.MongoWriteException;
import com.mongodb.client.MongoCollection;
import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Updates.combine;
import static com.mongodb.client.model.Updates.set;
import java.util.ArrayList;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Meng Zhang
 */
public class MongoDBHandler {

    private static final Logger LOG = (Logger) LoggerFactory.getLogger(MongoDBHandler.class);

    public static Bson getFindCritia(String[] keys, Object[] values) {
        Bson[] params = new Bson[keys.length];
        for (int i = 0; i < keys.length; i++) {
            params[i] = eq(keys[i], values[i]);
        }
        return and(params);
    }
    
    public static Bson getUpdateParams(String[] keys, Object[] values) {
        ArrayList<Bson> updates = new ArrayList();
        for (int i = 0; i < keys.length; i++) {
            updates.add(set(keys[i], values[i]));
        }
        return combine(updates);
    }

    public static ArrayList<Document> list(MongoCollection<Document> collection) {
        return list(collection, 0, Integer.MAX_VALUE);
    }

    public static ArrayList<Document> list(MongoCollection<Document> collection, Bson projection) {
        return list(collection, 0, Integer.MAX_VALUE, projection);
    }

    public static ArrayList<Document> list(MongoCollection<Document> collection, int skip, int limit) {

        ArrayList<Document> ret = new ArrayList();
        collection.find().skip(skip).limit(limit).forEach((Block<Document>) ret::add);
        return ret;

    }

    public static ArrayList<Document> list(MongoCollection<Document> collection, int skip, int limit, Bson projection) {

        ArrayList<Document> ret = new ArrayList();
        collection.find().projection(projection).skip(skip).limit(limit).forEach((Block<Document>) ret::add);
        return ret;

    }

    public static Document find(MongoCollection<Document> collection, String id) {
        return find(collection, new ObjectId(id));
    }

    public static Document find(MongoCollection<Document> collection, ObjectId id) {
        return find(collection, eq("_id", id));
    }

    public static Document find(MongoCollection<Document> collection, Bson search) {
        return find(collection, search, null);
    }

    public static Document find(MongoCollection<Document> collection, Bson search, Bson projection) {
        if (projection == null) {
            return collection.find(search).first();
        } else {
            return collection.find(search).projection(projection).first();
        }
    }

    public static ArrayList<Document> search(MongoCollection<Document> collection, Bson search) {
        return search(collection, search, 0, Integer.MAX_VALUE);
    }

    public static ArrayList<Document> search(MongoCollection<Document> collection, Bson search, Bson projection) {
        return search(collection, search, 0, Integer.MAX_VALUE, projection);
    }

    public static ArrayList<Document> search(MongoCollection<Document> collection, Bson search, int skip, int limit) {
        return search(collection, search, skip, limit, null);
    }

    public static ArrayList<Document> search(MongoCollection<Document> collection, Bson search, int skip, int limit, Bson projection) {
        ArrayList<Document> ret = new ArrayList<>();
        if (projection == null) {
            collection.find(search).skip(skip).limit(limit).forEach((Block<Document>) ret::add);
        } else {
            collection.find(search).projection(projection).skip(skip).limit(limit).forEach((Block<Document>) ret::add);
        }
        return ret;
    }

    public static boolean add(MongoCollection<Document> collection, Document record) throws MongoWriteException {
        try {
            collection.insertOne(record);
            return true;
        } catch (MongoWriteException ex) {
            if (ex.getMessage().contains("duplicate key")) {
                return false;
            } else {
                throw ex;
            }
        }
    }

    public static boolean addSub(MongoCollection<Document> collection, Bson search, Bson record) {
        try {
            collection.findOneAndUpdate(search, record);
            return true;
        } catch (MongoWriteException ex) {
            LOG.warn(ex.getMessage());
            return false;
        }
    }

    public static <T> ArrayList<T> distinct(MongoCollection<Document> collection, String field, Class<T> type) {

        ArrayList<T> ret = new ArrayList();
        collection.distinct(field, type).forEach((Block<T>) ret::add);
        return ret;

    }

    public static Document update(MongoCollection<Document> collection, Bson search, Bson update) {
        return collection.findOneAndUpdate(search, update);
    }

    public static Document replace(MongoCollection<Document> collection, Bson search, Document replace) {
        return collection.findOneAndReplace(search, replace);
    }

    public static boolean delete(MongoCollection<Document> collection, Bson search) {
        return collection.deleteOne(search).getDeletedCount() > 0;
    }

    public static boolean clean(MongoCollection<Document> collection) {
        for (Document record : list(collection)) {
            collection.deleteOne(new Document("_id", record.getObjectId("_id")));
        }
        return true;
    }
}
