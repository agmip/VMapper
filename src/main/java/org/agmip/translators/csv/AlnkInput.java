package org.agmip.translators.csv;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import au.com.bytecode.opencsv.CSVReader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.agmip.core.types.TranslatorInput;

/**
 * This class read the linkage information from ALNK (CSV) files. It uses a
 * common file pattern as described below.
 *
 * <p>
 * <b>First Column Descriptors</b></p>
 * <p>
 * # - Lines with the first column text containing only a "#" is considered a
 * header row</p>
 * <p>
 * ! - Lines with the first column text containing only a "!" are considered a
 * comment and not parsed.
 *
 * The first header/datarow(s) are metadata (or global data) if there are
 * multiple rows of metadata, they are considered to be a collection of
 * experiments.
 *
 * The variable name used in the header will match with the ones used in the
 * ACMO CSV report file.
 *
 * @author Meng Zhang
 */
public class AlnkInput implements TranslatorInput {

    private static final Logger LOG = LoggerFactory.getLogger(AlnkInput.class);
    private HashMap<String, String> ovlLinks, stgLinks, rotLinks; // Storage maps
    private String listSeparator = ",";
    private AlnkHeader header;

    private enum HeaderType {

        UNKNOWN, // Probably uninitialized
        SUMMARY, // #
    }

    private static class AlnkHeader {

        private final HashMap<String, Integer> headers;

        public AlnkHeader(String[] line) {
            headers = new HashMap();
            for (int i = 1; i < line.length; i++) {
                String title = line[i].trim().toLowerCase();
                if (!"".equals(title) && !title.startsWith("!")) {
                    headers.put(title, i);
                }
            }
        }

        public String getValueOr(String[] line, String key) {
            return getValueOr(line, key, "");
        }

        public String getValueOr(String[] line, String key, String defVal) {
            if (headers.containsKey(key)) {
                int idx = headers.get(key);
                if (idx < line.length) {
                    return line[idx].trim();
                }
            }
            return defVal;
        }
    }

    @Override
    public Map readFile(String fileName) throws Exception {
        String fn = fileName.toUpperCase();
        if (fn.endsWith("ALNK") || fn.endsWith("CSV")) {
            readCSV(new FileInputStream(fileName));
        }
        return cleanupResult();
    }

    protected void readCSV(InputStream fileStream) throws Exception {
        header = null;
        String[] nextLine;
        BufferedReader br = new BufferedReader(new InputStreamReader(fileStream));

        // Check to see if this is an international CSV. (;, vs ,.)
        init(br);
        CSVReader reader = new CSVReader(br, this.listSeparator.charAt(0));

        // Read ALNK file content
        int ln = 0;
        while ((nextLine = reader.readNext()) != null) {
            ln++;
            LOG.debug("Line number: " + ln);
            if (nextLine[0].startsWith("!")) {
                LOG.debug("Found a comment line");
            } else if (nextLine[0].startsWith("#")) {
                LOG.debug("Found a summary header line");
                header = new AlnkHeader(nextLine);
            } else if (nextLine[0].startsWith("*")) {
                LOG.debug("Found a complete experiment line");
                parseDataLine(nextLine);
            } else if (nextLine.length == 1) {
                LOG.debug("Found a blank line, skipping");
            } else {
                boolean isBlank = true;
                // Check the nextLine array for all blanks
                int nlLen = nextLine.length;
                for (int i = 0; i < nlLen; i++) {
                    if (!nextLine[i].equals("")) {
                        isBlank = false;
                        break;
                    }
                }
                if (!isBlank) {
                    LOG.debug("Found a data line with [" + nextLine[0] + "] as the index");
                    parseDataLine(nextLine);
                } else {
                    LOG.debug("Found a blank line, skipping");
                }
            }
        }
        reader.close();
    }

    protected void parseDataLine(String[] data) throws Exception {
        String exname = header.getValueOr(data, "exname");
        String ovlDome = header.getValueOr(data, "field_overlay");
        String stgDome = header.getValueOr(data, "seasonal_strategy");
        String rotDome = header.getValueOr(data, "rotational_analysis");
        if (!"".equals(exname)) {
            setDomeID("EXNAME_" + exname, ovlDome, stgDome, rotDome);
        } else {
            String soilId = header.getValueOr(data, "soil_id");
            String wstId = header.getValueOr(data, "wst_id");
            if (!"".equals(soilId)) {
                setDomeID("SOIL_ID_" + soilId, ovlDome, stgDome, rotDome);
            }
            if (!"".equals(wstId)) {
                setDomeID("WST_ID_" + wstId, ovlDome, stgDome, rotDome);
            }
        }
    }

    private void setDomeID(String key, String... domes) {
        if (!"".equals(domes[0])) {
            saveDomeID(ovlLinks, key, domes[0]);
        }
        if (!"".equals(domes[1])) {
            saveDomeID(stgLinks, key, domes[1]);
        }
        if (!"".equals(domes[2])) {
            saveDomeID(rotLinks, key, domes[2]);
        }
    }
    
    private void saveDomeID(HashMap<String, String> m, String key, String value) {
        if (m.containsKey(key)) {
            String link = m.get(key);
            if (!link.contains(value)) {
                m.put(key, link + "|" + value);
            }
        } else {
            m.put(key, value);
        }
    }

    private HashMap cleanupResult() {
        HashMap ret = new HashMap();
        if (!ovlLinks.isEmpty()) {
            ret.put("link_overlay", ovlLinks);
        }
        if (!stgLinks.isEmpty()) {
            ret.put("link_stragty", stgLinks);
        }
        if (!rotLinks.isEmpty()) {
            ret.put("link_rotational", rotLinks);
        }
        return ret;
    }

    protected void init(BufferedReader in) throws Exception {
        ovlLinks = new HashMap();
        stgLinks = new HashMap();
        rotLinks = new HashMap();
        setListSeparator(in);
    }

    protected void setListSeparator(BufferedReader in) throws Exception {
        // Set a mark at the beginning of the file, so we can get back to it.
        in.mark(7168);
        String sample;
        while ((sample = in.readLine()) != null) {
            if (sample.startsWith("#")) {
                String listSeperator = sample.substring(1, 2);
                LOG.debug("FOUND SEPARATOR: " + listSeperator);
                this.listSeparator = listSeperator;
                break;
            } else if (sample.startsWith("\"#\"")) {
                String listSeperator = sample.substring(3, 4);
                LOG.debug("FOUND SEPARATOR: " + listSeperator);
                this.listSeparator = listSeperator;
                break;
            }
        }
        in.reset();
    }
}
