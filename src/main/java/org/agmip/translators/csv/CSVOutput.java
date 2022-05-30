package org.agmip.translators.csv;

import au.com.bytecode.opencsv.CSVWriter;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import org.agmip.common.Functions;
import org.agmip.core.types.TranslatorOutput;
import static org.agmip.util.MapUtil.*;

/**
 * This class converts the data from AgMIP ACE JSON format into CSV formatted
 * files.
 *
 * @author Meng Zhang
 */
public class CSVOutput implements TranslatorOutput {

    protected ArrayList<File> outputWthFiles;

    @Override
    public void writeFile(String outputDirectory, Map data) throws IOException {
        outputDirectory = Functions.revisePath(outputDirectory);
        writeWthFile(outputDirectory, data);
    }

    protected void writeWthFile(String outputDirectory, Map data) throws IOException {
        outputWthFiles = new ArrayList();
        // Get Weather data from data set
        ArrayList<HashMap> wthArr;
        if (data.containsKey("weathers")) {
            wthArr = getObjectOr(data, "weathers", new ArrayList());
        } else {
            wthArr = new ArrayList();
            if (data.containsKey("weather")) {
                wthArr.add(getObjectOr(data, "weather", new HashMap()));
            }
        }

        // Output weather csv file for each weather station
        for (HashMap<String, Object> wthData : wthArr) {
            File csv = getWthFileName(wthData, outputDirectory);
            BufferedWriter bw = new BufferedWriter(new FileWriter(csv));
            CSVWriter writer = new CSVWriter(bw, ',');
            ArrayList<String> headerKeys = new ArrayList();
            ArrayList<String> nextLine;

            // Write weahter file site section headers
            nextLine = new ArrayList();
            nextLine.add("#");
            nextLine.add("WST_ID");
            headerKeys.add("wst_id");
            for (String key : wthData.keySet()) {
                if (!key.equals("wst_id") && !key.equals("dailyWeather")) {
                    nextLine.add(key.toUpperCase());
                    headerKeys.add(key);
                }
            }
            writer.writeNext(nextLine.toArray(new String[0]));

            // Write weahter file site section values
            nextLine = new ArrayList();
            nextLine.add("");
            for (String key : headerKeys) {
                nextLine.add(getValueOr(wthData, key, ""));
            }
            writer.writeNext(nextLine.toArray(new String[0]));

            // Write weahter file daily section headers
            ArrayList<HashMap<String, String>> dailyArr = new BucketEntry(wthData).getDataList();
            headerKeys = new ArrayList();
            if (!dailyArr.isEmpty()) {
                HashMap<String, String> dailyData = dailyArr.get(0);
                nextLine = new ArrayList();
                nextLine.add("%");
                nextLine.add("W_DATE");
                headerKeys.add("w_date");
                for (String key : dailyData.keySet()) {
                    if (!key.equals("w_date")) {
                        nextLine.add(key.toUpperCase());
                        headerKeys.add(key);
                    }
                }
                writer.writeNext(nextLine.toArray(new String[0]));
            }

            // Write weahter file daily section values
            for (HashMap<String, String> dailyData : dailyArr) {
                nextLine = new ArrayList();
                nextLine.add("");
                for (String key : headerKeys) {
                    if (key.equals("w_date")) {
                        String date = Functions.formatAgmipDateString(getValueOr(dailyData, key, ""), "yyyy-MM-dd");
                        if (date == null) {
                            date = "";
                        }
                        nextLine.add(date);
                    } else {
                        nextLine.add(getValueOr(dailyData, key, ""));
                    }
                }
                writer.writeNext(nextLine.toArray(new String[0]));
            }

            writer.flush();
            writer.close();
            outputWthFiles.add(csv);
        }
    }

    private File getWthFileName(HashMap wthData, String outputDirectory) {
        String path = getValueOr(wthData, "wst_id", "TEMP");
        path += getValueOr(wthData, "clim_id", "");
        path = outputDirectory + File.separator + path;
        File f = new File(path + ".csv");
        int count = 1;
        while (f.exists()) {
            f = new File(path + "_" + count + ".csv");
            count++;
        }
        return f;
    }

    public ArrayList<File> getOutputWthFiles() {
        return this.outputWthFiles;
    }
}
