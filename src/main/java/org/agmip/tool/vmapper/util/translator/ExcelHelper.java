package org.agmip.tool.vmapper.util.translator;

import au.com.bytecode.opencsv.CSVWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import static java.nio.file.StandardCopyOption.REPLACE_EXISTING;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.apache.commons.io.FileUtils;

import org.apache.commons.io.FilenameUtils;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 * Replace the functionality from ADA tool
 * @author Meng Zhang
 */
public class ExcelHelper {

    public static boolean isExcel(File inputFile) {
        return isExcel(inputFile.getName());
    }

    public static boolean isExcel(String inputFileName) {
        String ext = FilenameUtils.getExtension(inputFileName);
        return ext.equalsIgnoreCase("xlsx") || ext.equalsIgnoreCase("xls");
    }
    
    public static void toCsvZip(File inputFile, File outputFile) throws IOException {
        toCsvZip(inputFile, outputFile, false, false);
    }
    
    public static void toCsvZip(File inputFile, File outputFile, boolean removeOriginal, boolean onlyFstCsv) throws IOException {
        toCsvZip(new FileInputStream(inputFile), inputFile.getName(), outputFile, onlyFstCsv);
        if (removeOriginal) {
            inputFile.delete();
        }
    }
    
    public static void toCsvZip(InputStream in, String inputFileName, File outputFile, boolean onlyFstCsv) throws IOException {

        outputFile.getParentFile().mkdirs();
        File tmpDir = Paths.get(outputFile.getParentFile().getPath(), System.currentTimeMillis() + "").toFile();
        tmpDir.mkdirs();

        try (Workbook workbook = readWorkbook(in, inputFileName)){
            Row row;
            Cell cell;
            
            // Iterate through each rows from first sheet
            for (int i = 0; i < workbook.getNumberOfSheets(); i++) {
                Sheet sheet = workbook.getSheetAt(i);
                File csvFile = Paths.get(tmpDir.getPath(), sheet.getSheetName() + ".csv").toFile();
                try (CSVWriter writer = new CSVWriter(new FileWriter(csvFile), ',')) {
                    Iterator<Row> rowIterator = sheet.iterator();
                    while (rowIterator.hasNext()) {
                        row = rowIterator.next();
                        // For each row, iterate through each columns
                        Iterator<Cell> cellIterator = row.cellIterator();
                        ArrayList<String> data = new ArrayList();
                        while (cellIterator.hasNext()) {
                            cell = cellIterator.next();
//                            data.add(cell.getStringCellValue());
                            switch (cell.getCellType()) {
                                
                            case BOOLEAN:
                                data.add(cell.getBooleanCellValue() + "");

                                break;
                            case NUMERIC:
                                data.add(cell.getNumericCellValue() + "");

                                break;
                            case STRING:
                                data.add(cell.getStringCellValue());
                                break;

                            case BLANK:
                                data.add("");
                                break;
                            default:
                                data.add(cell.toString());

                            }
                        }
                        writer.writeNext(data.toArray(new String[]{}));
                    }
                    writer.flush();
                }
                if (onlyFstCsv) {
                    Files.copy(csvFile.toPath(), outputFile.toPath(), REPLACE_EXISTING);
                    FileUtils.deleteDirectory(tmpDir);
                    return;
                }
            }
        }
        compressOutput(tmpDir, outputFile, true);
    }
    
    private static Workbook readWorkbook(InputStream is, String fileName) throws FileNotFoundException, IOException {
        Workbook workbook = null;
        String ext = FilenameUtils.getExtension(fileName);

        if (ext.equalsIgnoreCase("xlsx")) {
            workbook = new XSSFWorkbook(is);
        } else if (ext.equalsIgnoreCase("xls")) {
            workbook = new HSSFWorkbook(is);
        }
        return workbook;
    }
    
    public static void compressOutput(File inputDir, File zipFile, boolean removeDir) throws IOException {
        List<File> files   = Arrays.asList(inputDir.listFiles());
        
        try(ZipOutputStream  zos = new ZipOutputStream(new FileOutputStream(zipFile))) {
            for(File f : files) {
                ZipEntry ze = new ZipEntry(f.getName());
                zos.putNextEntry(ze);
                zos.write(Files.readAllBytes(f.toPath()));
                zos.closeEntry();
                f.delete();
            }
        }
        
        if (removeDir) {
            FileUtils.deleteDirectory(inputDir);
        }
    }
}
