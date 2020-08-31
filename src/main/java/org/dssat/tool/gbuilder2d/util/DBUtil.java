package org.dssat.tool.gbuilder2d.util;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import org.bson.Document;

/**
 *
 * @author Meng Zhang
 */
public class DBUtil {
    
    private static MongoClient mongoClient;
    protected final static String DEF_SKIP = "0";
    protected final static String DEF_LIMIT = Integer.MAX_VALUE + "";
    
    public final static String DSSAT_DB = "dssat_db";
    
    public enum DSSATCollection {
        
        MetaData("metadata");

        private final String name;

        private DSSATCollection(String name) {
            this.name = name;
        }

        @Override
        public String toString() {
            return this.name;
        }
    }
    
    public static MongoClientURI getDBURI() {
        // Give your DB path here
        String dbPath = ""; //"mongodb://***:***@cluster0-shard-00-00-upixo.mongodb.net:27017,cluster0-shard-00-01-upixo.mongodb.net:27017,cluster0-shard-00-02-upixo.mongodb.net:27017/mydb?ssl=true&replicaSet=Cluster0-shard-0&authSource=admin";
        MongoClientURI uri = new MongoClientURI(dbPath);
        return uri;
    }
    
    public static MongoCollection<Document> getConnection(DSSATCollection collection) {
        return getConnection(collection.toString());
    }
    
    public static MongoCollection<Document> getConnection(String collectionName) {
        if (mongoClient == null) {
            mongoClient = new MongoClient(DBUtil.getDBURI());
        }
        return mongoClient.getDatabase(DSSAT_DB).getCollection(collectionName);
    }
}
