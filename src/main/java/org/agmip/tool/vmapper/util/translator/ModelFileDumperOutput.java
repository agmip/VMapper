package org.agmip.tool.vmapper.util.translator;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import org.agmip.core.types.TranslatorOutput;

/**
 * Temporal solution for model specific data distribution purpose
 *
 * @author Meng Zhang
 */
public class ModelFileDumperOutput implements TranslatorOutput {

    @Override
    public void writeFile(String outputDirectory, Map data) throws IOException {
        Set<Entry> files = data.entrySet();
        for (Entry file : files) {
            String fileName = (String) file.getKey();
            char[] content = (char[]) file.getValue();
            OutputStream out = new FileOutputStream(outputDirectory + File.separator + fileName);
            try (BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(out, "utf-8"))) {
                bw.write(content);
                bw.flush();
            }
        }
    }
}
