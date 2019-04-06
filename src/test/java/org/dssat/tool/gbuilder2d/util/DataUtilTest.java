package org.dssat.tool.gbuilder2d.util;

import java.io.File;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Meng Zhang
 */
public class DataUtilTest {
    
    @Test
    public void testCulDataList() {
        JSONObject metaMap = DataUtil.getCulMetaData();
        for (Object crid : metaMap.keySet()) {
            if (crid.equals("FAL")) {
                assertTrue("Test default cultivar file for " + crid, DataUtil.getCulDataList(crid.toString()).isEmpty());
            } else {
                assertTrue("Test default cultivar file for " + crid, !DataUtil.getCulDataList(crid.toString()).isEmpty());
            }
        }
        for (Object crid : metaMap.keySet()) {
            String altModel = metaMap.getAsObj(crid.toString()).getOrBlank("alt_model");
            if (!altModel.isEmpty()) {
                String[] altModels = altModel.split(";");
                for (String model : altModels) {
                    File culFile = Path.Folder.getCulFile(model);
                    assertTrue("Test alternative cultivar file for " + model, !DataUtil.getCulDataList(culFile).isEmpty());
                }
            }
        }
    }
}
