package org.agmip.tool.vmapper.util;

import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;
import org.junit.Test;

/**
 *
 * @author Meng Zhang
 */
public class QuadUITest {

    @Test
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
}
