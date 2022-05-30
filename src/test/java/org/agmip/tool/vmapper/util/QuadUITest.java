package org.agmip.tool.vmapper.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Base64;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.agmip.tool.vmapper.util.translator.ExcelHelper;
import org.junit.Test;

/**
 *
 * @author Meng Zhang
 */
public class QuadUITest {

//    @Test
    public void testRunQuadUI() throws URISyntaxException, IOException, InterruptedException {
        Process process;
        File log;
        ProcessBuilder pb = new ProcessBuilder("cmd.exe", "/c", "java -version");
        pb.command("cmd.exe", "/c", "dir");
        pb.redirectErrorStream(true);
        pb.redirectOutput(ProcessBuilder.Redirect.INHERIT);
        process = pb.start();
        System.out.println("Quit with " + process.waitFor());
        
        pb.directory(new File("ICASA"));
        pb.command("java", "-jar", "..//..//..//..//libs//quadui.jar", "-cli", "-help");
        log = new File("quadui.log");
        pb = pb.redirectOutput(log);
        process = pb.start();
        System.out.println("Quit with " + process.waitFor());
        log.delete();
        
        pb.directory(new File("libs"));
        pb.command("java", "-jar", "quadui.jar", "-cli", "-help");
        log = new File("ICASA\\quadui2.log");
        pb = pb.redirectOutput(log);
        process = pb.start();
        System.out.println("Quit with " + process.waitFor());
        log.delete();
    }
    
//    @Test
    public void testIO() {
        File input = new File("Test/AgMIP_Input_2.zip");
        File input2 = new File("debug.txt");
        File output = new File("Test/AgMIP_Input_3.zip");
        try (FileInputStream in = new FileInputStream(input);FileOutputStream out = new FileOutputStream(output);) {
            byte[] cache = new byte[4096];
            int end;
            while ((end = in.read(cache)) > 0) {
                out.write(cache, 0, end);
            }
        } catch (FileNotFoundException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        try {
            byte[] cache = Files.readAllBytes(input.toPath());
            String data = Base64.getEncoder().encodeToString(cache);
            
            Files.write(new File("Test/AgMIP_Input_4.zip").toPath(), Base64.getDecoder().decode(data));
        } catch (IOException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        try {
            byte[] cache = Files.readAllBytes(input.toPath());
            String data = new String(cache, StandardCharsets.UTF_8);
            
            Files.write(new File("Test/AgMIP_Input_5.zip").toPath(), data.getBytes(StandardCharsets.UTF_8));
        } catch (IOException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        try {
            byte[] cache = Files.readAllBytes(input2.toPath());
            String data = new String(cache, StandardCharsets.UTF_8);
            
            Files.write(new File("Test/AgMIP_Input_6.zip").toPath(), Base64.getDecoder().decode(data));
        } catch (IOException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
//    @Test
    public void testADA() {
        try {
            ExcelHelper.toCsvZip(new File("Test\\Field_Overlay-GACM1801-MZX.xlsx"), new File("Test\\Field_Overlay-GACM1801-MZX.xlsx.zip"));
        } catch (IOException ex) {
            Logger.getLogger(QuadUITest.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
