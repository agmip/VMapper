package org.agmip.translators.csv;

import au.com.bytecode.opencsv.CSVWriter;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import org.agmip.common.Functions;
import org.agmip.core.types.TranslatorOutput;
import static org.agmip.util.MapUtil.*;

/**
 * This class converts the linkage information into ALNK(CSV) formatted file.
 *
 * @author Meng Zhang
 */
public class AlnkOutput implements TranslatorOutput {

    protected File alnkFile;

    @Override
    public void writeFile(String outputDirectory, Map data) throws IOException {

        alnkFile = null;
        boolean isNoExp = isNoExp(data);
//        // Get Weather data from data set
//        ArrayList<HashMap> wthArr;
//        if (data.containsKey("weathers")) {
//            wthArr = getObjectOr(data, "weathers", new ArrayList());
//        } else {
//            wthArr = new ArrayList();
//            if (data.containsKey("weather")) {
//                wthArr.add(getObjectOr(data, "weather", new HashMap()));
//            }
//        }

        // Output weather csv file for each weather station
//        for (HashMap<String, Object> wthData : wthArr) {
        alnkFile = getOutputFile(outputDirectory);
        BufferedWriter bw = new BufferedWriter(new FileWriter(alnkFile));
        CSVWriter writer = new CSVWriter(bw, ',', CSVWriter.NO_QUOTE_CHARACTER, CSVWriter.NO_ESCAPE_CHARACTER);
        ArrayList<String> headerKeys = new ArrayList();
        ArrayList<String> nextLine;

        // Write the comment lines
        nextLine = new ArrayList();
        nextLine.add("!");
        if (!isNoExp) {
            nextLine.add("\"Name of experiment, field test or survey\"");
        } else {
            nextLine.add("Weather station ID");
            nextLine.add("Soil ID");
        }
        nextLine.add("Field Overlay (DOME) ID");
        nextLine.add("Seaonal Strategy (DOME) ID");
        nextLine.add("Rotational Analysis (DOME) ID");

        writer.writeNext(nextLine.toArray(new String[0]));

        nextLine = new ArrayList();
        nextLine.add("!");
        if (isNoExp) {
            nextLine.add("text");
        }
        nextLine.add("text");
        nextLine.add("text");
        nextLine.add("text");
        nextLine.add("text");
        writer.writeNext(nextLine.toArray(new String[0]));

        // Write header line
        nextLine = new ArrayList();
        nextLine.add("#");
        if (!isNoExp) {
            nextLine.add("EXNAME");
        } else {
            nextLine.add("WST_ID");
            nextLine.add("SOIL_ID");
        }
        nextLine.add("FIELD_OVERLAY");
        nextLine.add("SEASONAL_STRATEGY");
        nextLine.add("ROTATIONAL_ANALYSIS");
        writer.writeNext(nextLine.toArray(new String[0]));

        // Write weahter file site section values
        ArrayList<HashMap> dataArr;
        if (!isNoExp) {
//            headerKeys.add("exname");
            dataArr = getObjectOr(data, "experiments", new ArrayList());
        } else {
            headerKeys.add("wst_id");
            headerKeys.add("soil_id");
            dataArr = getObjectOr(data, "weathers", new ArrayList());
            dataArr.addAll(getObjectOr(data, "soils", new ArrayList()));
        }
        headerKeys.add("field_overlay");
        headerKeys.add("seasonal_strategy");
        headerKeys.add("rotational_analysis");

        HashSet finExnames = new HashSet();
        for (HashMap m : dataArr) {
            nextLine = new ArrayList();
            nextLine.add("*");
            if (!isNoExp) {
                String exname = getValueOr(m, "exname", "");
                if ("Y".equals(getValueOr(m, "seasonal_dome_applied", ""))) {
                    exname = exname.replaceAll("_\\d+__\\d+$", "");
                } else if ("Y".equals(getValueOr(m, "field_dome_applied", ""))) {
                    exname = exname.replaceAll("_\\d+$", "");
                }
                if (!finExnames.contains(exname)) {
                    nextLine.add("\"" + exname + "\"");
                    finExnames.add(exname);
                } else {
                    continue;
                }
            }
            for (String key : headerKeys) {
                nextLine.add(getValueOr(m, key, ""));
            }
            writer.writeNext(nextLine.toArray(new String[0]));
        }

        writer.flush();
        writer.close();
//        }
    }

    private File getOutputFile(String outputDirectory) {
        File f;
        if (outputDirectory.toLowerCase().endsWith(".alnk")) {
            f = new File(outputDirectory);
            Functions.revisePath(f.getParent());
        } else {
            outputDirectory = Functions.revisePath(outputDirectory);
            String path = outputDirectory + File.separator + "Linkage";
            f = new File(path + ".alnk");
            int count = 1;
            while (f.exists()) {
                f = new File(path + "_" + count + ".csv");
                count++;
            }
        }
        return f;
    }

    public File getAlnkFile() {
        return this.alnkFile;
    }

    private boolean isNoExp(Map data) {
        return getObjectOr(data, "experiments", new ArrayList()).isEmpty();
    }
}
