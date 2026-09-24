import java.awt.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import java.io.File;
public class SyntheticReceipt {
 public static void main(String[] args) throws Exception {
  var image=new BufferedImage(720,900,BufferedImage.TYPE_INT_RGB);var g=image.createGraphics();
  g.setColor(Color.WHITE);g.fillRect(0,0,720,900);g.setColor(new Color(23,108,102));g.fillRect(0,0,720,130);
  g.setColor(Color.WHITE);g.setFont(new Font("SansSerif",Font.BOLD,32));g.drawString("SYNTHETIC TEST RECEIPT",65,80);
  g.setColor(Color.DARK_GRAY);g.setFont(new Font("SansSerif",Font.PLAIN,25));
  String[] lines={"Equipment Platform — local testing","No real supplier / no real transaction","Date: 2026-09-24","Category: FUEL","Total: SAR 350.00","Paid: SAR 350.00","Remaining: SAR 0.00","Fixture only — not a tax invoice"};
  int y=210;for(String line:lines){g.drawString(line,50,y);y+=75;}g.dispose();ImageIO.write(image,"png",new File("tests/fixtures/synthetic-receipt.png"));
 }
}
