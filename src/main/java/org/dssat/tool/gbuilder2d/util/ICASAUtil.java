package org.dssat.tool.gbuilder2d.util;

import au.com.bytecode.opencsv.CSVWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.net.URL;
import java.util.Iterator;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.FormulaEvaluator;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author Meng Zhang
 */
public class ICASAUtil {
    
    private static final String ICASA_URL = "https://docs.google.com/spreadsheets/d/1MYx1ukUsCAM1pcixbVQSu49NU-LfXg-Dtt-ncLBzGAM/pub?output=xlsx";
    private static final DataFormatter FORMARTTER = new DataFormatter(true);
    private static FormulaEvaluator evaluator = null;
    
    public static boolean syncICASA() {
        try (XSSFWorkbook workbook = new XSSFWorkbook(new URL(ICASA_URL).openStream());) {
            if (evaluator == null) {
                evaluator = workbook.getCreationHelper().createFormulaEvaluator();
            }
            Iterator<Sheet> it = workbook.sheetIterator();
            while (it.hasNext()) {
                Sheet sheet = it.next();
                try (CSVWriter writer = new CSVWriter(new FileWriter(Path.Folder.getICASAFile(sheet.getSheetName())), ',')) {
                    if(sheet.getPhysicalNumberOfRows() > 0) {
                        int lastRowNum = sheet.getLastRowNum();
                        int lastColNum = 0;
                        for(int j = 0; j <= lastRowNum; j++) {
                            Row row = sheet.getRow(j);
                            if (row != null) {
                                int cellNum = row.getLastCellNum();
                                if (lastColNum < cellNum) {
                                    lastColNum = cellNum;
                                }
                            }
                        }
                        for(int j = 0; j <= lastRowNum; j++) {
                            Row row = sheet.getRow(j);
                            writer.writeNext(getCSVLine(row, lastColNum));
                        }
                        writer.flush();
                    }
                }
            }
            
        } catch (IOException ex) {
            ex.printStackTrace(System.err);
            return false;
        }
        
        return true;
    }
    
    private static String[] getCSVLine(Row row) {
        if(row != null) {
            return getCSVLine(row, row.getLastCellNum());
        } else {
            return getCSVLine(row, 0);
        }
    }
    
    private static String[] getCSVLine(Row row, int lastCellNum) {
        if(row != null) {
            if (lastCellNum > 0) {
                String[] csvLine = new String[lastCellNum];
                for (int i = 0; i < lastCellNum; i++) {
                    Cell cell = row.getCell(i);
                    if(cell == null) {
                        csvLine[i] = "";
                    } else if(cell.getCellType() != CellType.FORMULA) {
                        csvLine[i] = FORMARTTER.formatCellValue(cell);
                    } else {
                        csvLine[i] = FORMARTTER.formatCellValue(cell, evaluator);
                    }
                }
                return csvLine;
            }
        }
        return new String[]{};
    }
}
