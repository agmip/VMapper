package org.agmip.tool.vmapper.util;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Arrays;
import java.util.Base64;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.tika.Tika;
import org.junit.Test;

/**
 *
 * @author Meng Zhang
 */
public class RemoteFileLoaderTest {
    
    private final Tika tika = new Tika();

    @Test
    public void testReadFile() throws URISyntaxException {
        try {
//            URL url = new URL("https://data.nal.usda.gov/system/files/GVT_graincorn_2014-2019%20%281%29.xlsx");
//            URL url = new URL("https://raw.githubusercontent.com/MengZhang/supermaas-aggregate-pythia-outputs/develop/DATA_CDE.csv");
            URL url = new URL("https://file-examples-com.github.io/uploads/2017/02/file_example_XLS_10.xls");
//            URL url = new URL("https://drive.google.com/u/0/uc?id=1h00Fl-q_NvNy93rgxXOAdQI7F04RkkGk&export=download"); // xlsx fake to csv
//            URL url = new URL("https://drive.google.com/u/0/uc?id=14-AfKU7ySswkEaC3PIgtclrS4w-oSOuS&export=download"); // xls fake to csv
//            URL url = new URL("https://drive.google.com/u/0/uc?id=1p7P2gAi7BkfJW-zudRPBzaU31bItvRkm&export=download"); // csv fake to xlsx
//            FileOutputStream fos = new FileOutputStream(new File(url.getFile()).getName());
            String fileName;
            Map<String, List<String>> headers = url.openConnection().getHeaderFields();
            List<String> list = headers.get("Content-Disposition");
            if (list != null && !list.isEmpty()) {
                fileName = list.get(0).replaceFirst("(?i)^.*filename=\"?([^\"]+)\"?.*$", "$1");
            } else {
                fileName = new File(url.getFile()).getName();
            }
            System.out.println(fileName);
            File f = new File("Test" + File.separator + fileName) ;
            f.getParentFile().mkdirs();
            FileOutputStream fos = new FileOutputStream(f);
            try {
                System.out.println(tika.detect(url.openStream()));
                System.out.println(url.openConnection().getContentType());
            } catch (IOException ex) {
                Logger.getLogger(RemoteFileLoaderTest.class.getName()).log(Level.SEVERE, null, ex);
            }
            try (InputStream is = url.openStream()) {
                byte[] buff = new byte[is.available()];
                int ret;
                int count = 0;
                while ((ret = is.read(buff)) > 0) {
                    if (ret < buff.length) {
                        buff = Arrays.copyOfRange(buff, 0, ret);
                    }
                    String data = Base64.getEncoder().encodeToString(buff);
                    byte[] tmp = Base64.getDecoder().decode(data);
                    for (int i = 0; i < ret; i++) {
                        if (buff[i] != tmp[i]) {
                            System.out.println("Detect error @"+ count + "_" + i + ": buff=" + buff[i] + ", tmp=" + tmp[i]);
                        }
                    }
                    fos.write(tmp);
                    count++;
                }
            } catch (IOException e) {
                e.printStackTrace(System.err);
            }
        } catch (MalformedURLException e) {
            e.printStackTrace(System.err);
        } catch (FileNotFoundException e) {
            e.printStackTrace(System.err);
        } catch (IOException e) {
            e.printStackTrace(System.err);
        }
    }
}
