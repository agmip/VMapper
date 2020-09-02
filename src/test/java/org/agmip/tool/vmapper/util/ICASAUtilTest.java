package org.dssat.tool.gbuilder2d.util;

import org.agmip.tool.vmapper.util.ICASAUtil;
import org.junit.Assert;
import org.junit.Test;

/**
 *
 * @author Meng Zhang
 */
public class ICASAUtilTest {
    
    @Test
    public void testSyncICASA() {
        Assert.assertTrue(ICASAUtil.syncICASA());
    }
}
