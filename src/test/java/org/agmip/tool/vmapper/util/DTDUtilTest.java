package org.agmip.tool.vmapper.util;

import org.agmip.tool.vmapper.util.JSONObject;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import org.junit.Test;
import org.xml.sax.SAXException;

/**
 *
 * @author Meng Zhang
 */
public class DTDUtilTest {
    
    @Test
    public void testCulDataList() throws IOException, SAXException {
        URL url = new URL("https://raw.githubusercontent.com/AgriculturalModelExchangeInitiative/crop2ml/master/ModelUnit.dtd");
        String line;
        JSONObject root = new JSONObject();
        JSONObject current = root;
        try (BufferedReader br = new BufferedReader(new InputStreamReader(url.openStream()))) {
            boolean attFlg = false;
            while ((line = br.readLine()) != null) {
                line = line.trim();
                String lineU = line.toUpperCase();
                String lineL = line.toLowerCase();
                if (lineU.startsWith("<!ELEMENT ")) {
                    attFlg = false;
                    String[] tmp = line.split("[ ,()>]+");
                    JSONObject element = new JSONObject();
                    current.put(tmp[1], element);
                    current = element;
                    for (int i = 2; i < tmp.length; i++) {
                        if (tmp[i].endsWith("?")) {
                            
                        } else if (tmp[i].endsWith("*")) {
                            
                        } else if (tmp[i].endsWith("+")) {
                            
                        } else {
                            
                        }
                    }
                    
                } else if (lineU.startsWith("<!ATTLIST ")) {
                    attFlg = true;
                } else if (line.isEmpty() && attFlg) {
                    
                }
            }
        }
    }
}
