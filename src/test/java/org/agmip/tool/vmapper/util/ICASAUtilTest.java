package org.agmip.tool.vmapper.util;

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
