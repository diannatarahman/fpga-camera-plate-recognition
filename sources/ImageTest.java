package imagetest;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ComponentEvent;
import java.awt.event.ComponentListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.geom.Path2D;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;

import javax.imageio.ImageIO;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextArea;

public class ImageTest extends JPanel implements ActionListener, KeyListener, FocusListener, MouseListener, ComponentListener, ItemListener {
 private static final long serialVersionUID = 1L;
 private final BufferedImage[] testImages;
 private final BufferedImage[] fontImages;
 private BufferedImage image;
 private BufferedImage[] segmentedImages;
 private Graph[] xgraphs, ygraphs;
 private BufferedImage xProj, yProj;
 private int refreshCount = 0;
 private boolean drawProj;
 private boolean segmentation = false;
 private final JButton prevButton;
 private final JButton nextButton;
 private final JButton projButton;
 private final JButton resetButton;
 private final JButton segmentButton;
 private final JButton plateNumberButton;
 private final JComboBox<String> comboBox;
 private final JButton saveImageButton;
 private final Filter[] filters;
 private final JLabel imgLabel;
 private final JTextArea summaryTextArea;
 private int index;
 private int indexSegmented;
 private long timeCheck;
 private long timeExecution;
 private long timeExecutionTotal;
 private int executionCount;
 private int rangeValueGraph = 256;
 private static final double Kr = 0.2126, Kg = 0.7152, Kb = 0.0722;
 private static final int Cmb = 1, Cmp = 1, Cms = 1, Cmas0 = 3, Cmas1 = 1, Cmc = 1, Cmac = 1, Csb = 2, Csp = 3, Css = 4, Csas0 = 5, Csas1 = 1, Csc = 4, Csac = 1, Ct = 2, Ce = 2, Cw = 320, Ch = 240, Csat0t = 0, Csat1t = 255, Csat0e = sat(48, Ce, false), Csat1e = sat(48, Ce, true);
 private static final char[] NUMBERS_AND_LETTERS = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
 private static final boolean[] R;
 private static final boolean[] SE;
 private static final boolean[] R2;
 private static final boolean[] SE2;
 private static final boolean[] SE3;
 private static final boolean[] R3;
 private static final boolean[] R4;
 private static final int IMAGE_COUNT = 31;
 private static final int PANEL_WIDTH_MIN = 900;
 private static final int PANEL_HEIGHT_MIN = 700;
 private static final int BUTTON_WIDTH = 120;
 private static final int BUTTON_HEIGHT = 30;
 private static final int SPACE = 10;
 static {
  R = new boolean[9];
  SE = new boolean[39];
  Arrays.fill(R, true);
  Arrays.fill(SE, true);
  R2 = new boolean[25];
  Arrays.fill(R2, true);
  SE2 = new boolean[90];
  Arrays.fill(SE2, true);
  SE3 = new boolean[3];
  Arrays.fill(SE3, true);
  R3 = Arrays.copyOf(R, R.length);
  R3[0] = false;
  R3[2] = false;
  R3[6] = false;
  R3[8] = false;
  R4 = Arrays.copyOf(R, R.length);
  R4[4] = false;
 }

 private static final class Graph {
  private int[] curve;
  private int[] uPoints;
  private int[] points;
  private int[] uBoundOrigins;
  private int[] boundOrigins;
  private int[] uBoundLengths;
  private int[] boundLengths;
 }

 private static abstract class Filter {
  private final JButton button;

  Filter(String s) {
   button = new JButton(s);
  }

  public abstract BufferedImage filter(BufferedImage image);
 }

 private static abstract class RGBFilter extends Filter {

  RGBFilter(String s) {
   super(s);
  }

  public final BufferedImage filter(BufferedImage image) {
   int[] d = new int[2], pixels = getPixels(image, d);
   pixels = process(image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth()), d);
   BufferedImage filteredImage = new BufferedImage(d[0], d[1], BufferedImage.TYPE_INT_RGB);
   filteredImage.setRGB(0, 0, d[0], d[1], pixels, 0, d[0]);
   return filteredImage;
  }

  public abstract int[] process(int[] pixels, int[] d);
 }

 public static void main(String[] args) {
  JFrame window = new JFrame("Image Test");
  Toolkit dt = Toolkit.getDefaultToolkit();
  ImageTest imgtest = new ImageTest();
  window.setContentPane(imgtest);
  window.pack();
  Dimension ukuranLayar = dt.getScreenSize();
  window.setLocation((ukuranLayar.width - window.getWidth()) / 2, (ukuranLayar.height - window.getHeight()) / 2);
  window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
  window.setVisible(true);
  window.setMinimumSize(new Dimension(PANEL_WIDTH_MIN+20, PANEL_HEIGHT_MIN+40));
 }

 private static int sat(int t, int l, boolean b) {
  int temp;
  if (b) {
   temp = l*t > 256 ? 255 : l*t-1;
  }
  else {
   temp = l*t > 256 ? t-(int)Math.ceil((256-t)/(l-1.0)) : 0;
  }
  return temp;
 }

 public ImageTest() {
  setLayout(null);
  setPreferredSize(new Dimension(PANEL_WIDTH_MIN, PANEL_HEIGHT_MIN));
  setSize(PANEL_WIDTH_MIN, PANEL_HEIGHT_MIN);
  setBackground(Color.GRAY);
  ClassLoader cl = getClass().getClassLoader();
  testImages = new BufferedImage[IMAGE_COUNT];
  for (int i=0; i<IMAGE_COUNT; i++) {
   try {
    testImages[i] = ImageIO.read(cl.getResource("test (" + i + ").jpg"));
   } catch (IOException e) {
    e.printStackTrace();
    System.exit(1);
   }
  }
  fontImages = new BufferedImage[36];
  for (int i=0; i<10; i++) {
   try {
    fontImages[i] = ImageIO.read(cl.getResource("font - " + i + ".jpg"));
   } catch (IOException e) {
    e.printStackTrace();
    System.exit(1);
   }
  }
  for (int i=0; i<26; i++) {
   try {
    fontImages[i+10] = ImageIO.read(cl.getResource("font - " + (char)('A'+i) + ".jpg"));
   } catch (IOException e) {
    e.printStackTrace();
    System.exit(1);
   }
  }
  image = testImages[index];
  xgraphs = new Graph[]{new Graph()};
  ygraphs = new Graph[]{new Graph()};
  prevButton = new JButton("<");
  nextButton = new JButton(">");
  projButton = new JButton("proyeksi off");
  resetButton = new JButton("reset");
  segmentButton = new JButton("segmen");
  plateNumberButton = new JButton("plat nomor");
  comboBox = new JComboBox<String>(new String[]{"max", "top"});
  saveImageButton = new JButton("save image");
  filters = new Filter[7];
  filters[0] = new RGBFilter("normalisasi") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    return (int[]) numberPlate(pixels, d, 1);
   }
  };
  filters[1] = new RGBFilter("VED") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    pixels = (int[]) numberPlate(pixels, d, 1);
    pixels = simpleEdge(getBrightness(pixels, d), d, Ce, Csat0e, Csat1e);
    brightnessToRGB(pixels);
    return pixels;
   }
  };
  filters[2] = new RGBFilter("band clipping") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    return (int[]) numberPlate(pixels, d, 2);
   }
  };
  filters[3] = new RGBFilter("plate clipping") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    return (int[]) numberPlate(pixels, d, 3);
   }
  };
  filters[4] = new RGBFilter("threshold") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    return (int[]) numberPlate(pixels, d, 4);
   }
  };
  filters[5] = new RGBFilter("band clipping 2") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    pixels = (int[]) numberPlate(pixels, d, 2);
    pixels = simpleEdge(getBrightness(pixels, d), d, Ce, Csat0e, Csat1e);
    brightnessToRGB(pixels);
    return pixels;
   }
  };
  filters[6] = new RGBFilter("resize") {
   @Override
   public int[] process(int[] pixels, int[] d) {
    return resizeTo(pixels, d, 16, 16);
   }
  };
  imgLabel = new JLabel("citra " + index, JLabel.CENTER);
  imgLabel.setFont(new Font("Arial", Font.BOLD, 20));
  summaryTextArea = new JTextArea("");
  summaryTextArea.setFont(new Font("Segoe UI", Font.BOLD, 10));
  add(prevButton);
  add(nextButton);
  add(projButton);
  add(resetButton);
  add(segmentButton);
  add(plateNumberButton);
  add(comboBox);
  add(saveImageButton);
  for (Filter f : filters) {
   add(f.button);
  }
  add(imgLabel);
  add(summaryTextArea);
  computeBounds();
  prevButton.addActionListener(this);
  prevButton.setFocusable(false);
  nextButton.addActionListener(this);
  nextButton.setFocusable(false);
  projButton.addActionListener(this);
  projButton.setFocusable(false);
  resetButton.addActionListener(this);
  resetButton.setFocusable(false);
  segmentButton.addActionListener(this);
  segmentButton.setFocusable(false);
  plateNumberButton.addActionListener(this);
  plateNumberButton.setFocusable(false);
  comboBox.setFocusable(false);
  saveImageButton.addActionListener(this);
  saveImageButton.setFocusable(false);
  for (Filter f : filters) {
   f.button.addActionListener(this);
   f.button.setFocusable(false);
  }
  filters[6].button.setEnabled(false);
  summaryTextArea.setFocusable(false);
  comboBox.addItemListener(this);
  addKeyListener(this);
  addFocusListener(this);
  addMouseListener(this);
  addComponentListener(this);
  updateGraphDefault();
  index = 5;
  do {
   numberPlate();
  } while (timeExecution > 15);
  index = 0;
  timeExecutionTotal = 0;
  executionCount = 0;
 }

 @Override
 public void paintComponent(Graphics g) {
  super.paintComponent(g);
  g.drawImage(image, SPACE, SPACE, this);
  g.drawImage(xProj, SPACE, image.getHeight(this)+SPACE*2, this);
  g.drawImage(yProj, image.getWidth(this)+SPACE*2, SPACE, this);
 }

 private static int[] getColorSet(int in, int length) {
  length = length < 1530 ? length : 1530;
  in %= length;
  int set = traverseSet(in, length);
  set = (int) (set*1530.0/length + 0.5);
  int[] colorSet = new int[3];
  colorSet[0] = getHSBColorFullSB(set+510);
  colorSet[1] = getHSBColorFullSB(set+1020);
  colorSet[2] = getHSBColorFullSB(set);
  return colorSet;
 }

 private static int traverseSet(int set, int length) {
  if (length<=1)
   return 0;
  if (set%2==0)
   return traverseSet(set/2, length-length/2);
  else
   return length-length/2+traverseSet(set/2, length/2);
 }

 private static int getHSBColorFullSB(int in) {
  in %= 1530;
  int rgb;
  switch (in/255) {
  case 0 :
   rgb = 0xffff0000 | (in%255)<<8; break;
  case 1 :
   rgb = 0xff00ff00 | (255-(in%255))<<16; break;
  case 2 :
   rgb = 0xff00ff00 | (in%255); break;
  case 3 :
   rgb = 0xff0000ff | (255-(in%255))<<8; break;
  case 4 :
   rgb = 0xff0000ff | (in%255)<<16; break;
  default :
   rgb = 0xffff0000 | (255-(in%255)); break;
  }
  return rgb;
 }

 @Override
 public void actionPerformed(ActionEvent evt) {
  Object src = evt.getSource();
  if (src == prevButton) {
   previousImage();
   int[] dist = computeKNN(image);
   summaryTextArea.setText(distanceText(dist));
  }
  else if (src == nextButton) {
   nextImage();
   int[] dist = computeKNN(image);
   summaryTextArea.setText(distanceText(dist));
  }
  else if (src == projButton) {
   drawProj = !drawProj;
   projButton.setText(drawProj ? "proyeksi on" : "proyeksi off");
   refreshCount = 0;
  }
  else if (src == resetButton) {
   if (segmentation)
    image = segmentedImages[indexSegmented];
   else
    image = testImages[index];
   refreshCount = 0;
   int[] dist = computeKNN(image);
   summaryTextArea.setText(distanceText(dist));
  }
  else if (src == segmentButton) {
   segmentation = !segmentation;
   for (Filter f : filters) {
    f.button.setEnabled(!f.button.isEnabled());
   }
   segmentButton.setText(segmentation ? "citra" : "segmentasi");
   if (segmentation) {
    int[] d = new int[2], pixels = getPixels(testImages[index], d);
    segmentedImages = (BufferedImage[]) numberPlate(pixels, d, 5);
    indexSegmented = 0;
    if (segmentedImages.length == 0) {
     summaryTextArea.setText("tidak ada segmen!");
     segmentation = !segmentation;
     segmentButton.setText(segmentation ? "citra" : "segmentasi");
    }
    else {
     image = segmentedImages[indexSegmented];
     int[] dist = computeKNN(image);
     summaryTextArea.setText(distanceText(dist));
     summaryTextArea.append("waktu eksekusi " + timeExecution + " ms");
    }
   }
   else {
    image = testImages[index];
    int[] dist = computeKNN(image);
    summaryTextArea.setText(distanceText(dist));
   }
   refreshCount = 0;
  }
  else if (src == plateNumberButton) {
   summaryTextArea.setText(numberPlate());
   summaryTextArea.append("\nwaktu eksekusi " + timeExecution + " ms");
   summaryTextArea.append("\nwaktu eksekusi rata-rata " + (timeExecutionTotal/(double)executionCount) + " ms");
  }
  else if (src == saveImageButton) {
   summaryTextArea.setText("image saved");
   try {
             ImageIO.write(image, "JPG", new File("C:/Users/Diannata Rahman/Desktop/test_image.JPG"));
         } catch (Exception e) {
    summaryTextArea.setText(e.getMessage());
         }
  }
  for (Filter f : filters) {
   if (src == f.button) {
    summaryTextArea.setText("");
    if (segmentation) {
     image = f.filter(segmentedImages[indexSegmented]);
     int[] dist = computeKNN(image);
     summaryTextArea.setText(distanceText(dist));
    }
    else
     image = f.filter(testImages[index]);
    refreshCount = 0;
    summaryTextArea.append("waktu eksekusi " + timeExecution + " ms");
    break;
   }
  }
  if (src == filters[1].button || src == filters[5].button) {
   updateGraphCrop();
  }
  else if (src == filters[4].button) {
   updateGraphSegments();
  }
  else {
   updateGraphDefault();
  }
  if (segmentation)
   imgLabel.setText("segmen " + indexSegmented);
  else
   imgLabel.setText("citra " + index);
  repaint();
 }

 private void previousImage() {
  if (segmentation) {
   if (indexSegmented>0) {
    indexSegmented--;
    refreshCount = 0;
    image = segmentedImages[indexSegmented];
   }
  }
  else {
   if (index>0) {
    index--;
    refreshCount = 0;
    image = testImages[index];
   }
  }
 }

 private void nextImage() {
  if (segmentation) {
   if (indexSegmented<segmentedImages.length-1) {
    indexSegmented++;
    refreshCount = 0;
    image = segmentedImages[indexSegmented];
   }
  }
  else {
   if (index<IMAGE_COUNT-1) {
    index++;
    refreshCount = 0;
    image = testImages[index];
   }
  }
 }

 private String distanceText(int[] dist) {
  int[] in = sort(dist);
  String s = "";
  for (int i=0; i<36; i++) {
   s += NUMBERS_AND_LETTERS[in[i]] + " = " + dist[in[i]];
   i++;
   s += "\t" + NUMBERS_AND_LETTERS[in[i]] + " = " + dist[in[i]];
   s += "\n";
  }
  return s;
 }

 private static int[] getProjection(int[] pixels, int[] d, boolean h, int l) {
  int[] pr = new int[h ? d[0] : d[1]];
  for (int y=0; y<d[1]; y++) {
   for (int x=0; x<d[0]; x++) {
    int px = pixels[y*d[0]+x];
    px = (int)(px/255.0*(l-1.0)+0.5);
    if (h)
     pr[x] += px;
    else
     pr[y] += px;
   }
  }
  return pr;
 }

 private BufferedImage[] createSegmentedImages(int[] pixels, int[] d) {
  int[] bounds = segmentedImageBounds(pixels, d);
  int count = bounds.length/4;
  BufferedImage[] si = new BufferedImage[count];
  for (int i=0; i<count; i++) {
   int[] dd = Arrays.copyOf(d, d.length);
   int[] fc = crop(pixels, dd, bounds[i*4], bounds[i*4+2], bounds[i*4+1]-bounds[i*4]+1, bounds[i*4+3]-bounds[i*4+2]+1);
   si[i] = new BufferedImage(dd[0], dd[1], BufferedImage.TYPE_INT_RGB);
   si[i].setRGB(0, 0, dd[0], dd[1], fc, 0, dd[0]);
  }
  return si;
 }

 private int[] segmentedImageBounds(int[] pixels, int[] d) {
  int[] px = getProjection(getBrightness(pixels, d), d, true, Ct);
  int[] bounds = new int[80];
  boolean valid = false;
  boolean up = true;
  int count = 0, area = 0, t = (d[1]*(Ct-1)*Cms)>>Css, ta0 = (d[1]*d[1]*(Ct-1)*Cmas0)>>Csas0, ta1 = (d[1]*d[1]*(Ct-1)*Cmas1)>>Csas1;
  for (int i=0; ; i++) {
   if (count == bounds.length)
    break;
   if (i == d[0]) {
    if (valid) {
     int[] dd = Arrays.copyOf(d, d.length);
     int[] fc = crop(pixels, dd, bounds[count*4], 0, bounds[count*4+1]-bounds[count*4]+1, d[1]);
     int[] b = vBounds2(fc, dd, Cmc, Csc);
     bounds[count*4+2] = b[0];
     bounds[count*4+3] = b[1];
     if (b[1]-b[0]+1 > (dd[1]*Cmac>>Csac))
      count++;
    }
    break;
   }
   boolean c = px[i] <= t;
   if (up) {
    if (!c) {
     bounds[count*4] = i;
     bounds[count*4+1] = i;
     area = px[i];
     up = false;
    }
   }
   else {
    if (c) {
     up = true;
     if (valid) {
      valid = false;
      area = 0;
      int[] dd = Arrays.copyOf(d, d.length);
      int[] fc = crop(pixels, dd, bounds[count*4], 0, bounds[count*4+1]-bounds[count*4]+1, d[1]);
      int[] b = vBounds2(fc, dd, Cmc, Csc);
      bounds[count*4+2] = b[0];
      bounds[count*4+3] = b[1];
      if (b[1]-b[0]+1 > (dd[1]*Cmac>>Csac))
       count++;
     }
    }
    else {
     area += px[i];
     bounds[count*4+1] = i;
     valid = area > ta0 && area <= ta1;
    }
   }
  }
  return Arrays.copyOf(bounds, count*4);
 }

 private static int[] vBounds(int[] pixels, int[] d, int cm, int cs) {
  int[] dd = Arrays.copyOf(d, d.length);
  int[] f = simpleEdge(getBrightness(pixels, dd), dd, Ce, Csat0e, Csat1e);
  int[] py = getProjection(f, dd, false, Ce);
  int ym = maxIndex(py), pym = py[ym], y0, y1, t = (pym*cm)>>cs;
  for (y0=ym; y0>0; y0--) {
   if (py[y0-1] <= t)
    break;
  }
  for (y1=ym; y1<dd[1]-1; y1++) {
   if (py[y1+1] <= t)
    break;
  }
  return new int[]{y0, y1, ym};
 }

 private static int[] vBounds2(int[] pixels, int[] d, int cm, int cs) {
  int[] py = getProjection(getBrightness(pixels, d), d, false, Ct);
  int ym = maxIndex(py), pym = py[ym], y0, y1, t = ((pym*cm)>>cs);
  for (y0=ym; y0>0; y0--) {
   if (py[y0-1] <= t)
    break;
  }
  for (y1=ym; y1<d[1]-1; y1++) {
   if (py[y1+1] <= t)
    break;
  }
  return new int[]{y0, y1, ym};
 }

 private static int[] plateBounds(int[] pixels, int[] d, int cm, int cs) {
  int[] dd = Arrays.copyOf(d, d.length);
  int[] f = simpleEdge(getBrightness(pixels, dd), dd, Ce, Csat0e, Csat1e);
  int[] px = getProjection(f, dd, true, Ce);
  final int w = dd[1]*25/2;
  int xam = 0, am = 0, a = 0, xamw=0;
  for (int i=0; i < px.length; i++) {
   a += px[i];
   if (i >= w) {
    a -= px[i-w];
    if (a > am) {
     xam = i-w;
     xamw = i;
     am = a;
    }
   }
   else
    xamw = i;
  }
  int pxm = px[maxIndex(px)], x0, x1, t = ((pxm*cm)>>cs);
  boolean b1 = false, b2 = false, b3 = false;
  for (x0=xam, x1=xamw; x0<x1 && !(b2&&b3); ) {
   if (b1) {
    if (px[x0] >= t)
     b2=true;
    else
     x0++;
    if (!b3)
     b1 = !b1;
   }
   else {
    if (px[x1] >= t)
     b3=true;
    else
     x1--;
    if (!b2)
     b1 = !b1;
   }
  }
  return new int[]{x0, x1, xam, xamw};
 }

 private int[] computeKNN(BufferedImage image) {
  int[] d = new int[2], pixels = getPixels(image, d);
  return computeKNN(pixels, d);
 }

 private int[] computeKNN(int[] pixels, int[] d) {
  int[] fr = getBrightness(resizeTo(pixels, d, 16, 16), d);
  int[] dd = new int[2];
  int[] dist = new int[36];
  for (int i=0; i<36; i++) {
   int[] font = getBrightness(getPixels(fontImages[i], dd), dd);
   for(int y=0; y<16; y++) {
    for(int x=0; x<16; x++) {
     if (fr[y*16+x] < 128 != font[y*16+x] < 128)
      dist[i]++;
    }
   }
  }
  return dist;
 }

 private void updateGraphDefault() {
  int[] d = new int[2];
  xgraphs[0].curve = getProjection(getBrightness(getPixels(image, d), d), d, true, 256);
  ygraphs[0].curve = getProjection(getBrightness(getPixels(image, d), d), d, false, 256);
  xgraphs[0].points = null;
  ygraphs[0].points = null;
  xgraphs[0].uPoints = new int[]{maxIndex(xgraphs[0].curve)};
  ygraphs[0].uPoints = new int[]{maxIndex(ygraphs[0].curve)};
  xgraphs[0].boundOrigins = null;
  ygraphs[0].boundOrigins = null;
  xgraphs[0].boundLengths = null;
  ygraphs[0].boundLengths = null;
  xgraphs[0].uBoundOrigins = null;
  ygraphs[0].uBoundOrigins = null;
  xgraphs[0].uBoundLengths = null;
  ygraphs[0].uBoundLengths = null;
  rangeValueGraph = 256;
  updateGraph();
 }

 private void updateGraphCrop() {
  int[] d = new int[2], pixels = getPixels(testImages[index], d);
  pixels = (int[]) numberPlate(pixels, d, 1);
  int[] vb = vBounds(pixels, d, Cmb, Csb);
  int[] pb = plateBounds(pixels, d, Cmp, Csp);
  xgraphs[0].curve = getProjection(simpleEdge(getBrightness(pixels, d), d, Ce, Csat0e, Csat1e), d, true, Ce);
  ygraphs[0].curve = getProjection(simpleEdge(getBrightness(pixels, d), d, Ce, Csat0e, Csat1e), d, false, Ce);
  xgraphs[0].points = new int[]{pb[0], pb[1]};
  ygraphs[0].points = new int[]{vb[0], vb[1]};
  xgraphs[0].uPoints = null;
  ygraphs[0].uPoints = new int[]{vb[2]};
  xgraphs[0].boundOrigins = null;
  ygraphs[0].boundOrigins = null;
  xgraphs[0].boundLengths = null;
  ygraphs[0].boundLengths = null;
  xgraphs[0].uBoundOrigins = new int[]{pb[2]};
  ygraphs[0].uBoundOrigins = null;
  xgraphs[0].uBoundLengths = new int[]{pb[3]-pb[2]+1};
  ygraphs[0].uBoundLengths = null;
  rangeValueGraph = Ce;
  updateGraph();
 }

 private void updateGraphSegments() {
  int[] d = new int[2], pixels = getPixels(testImages[index], d);
  pixels = (int[]) numberPlate(pixels, d, 4);
  int[] b = segmentedImageBounds(pixels, d);
  xgraphs[0].curve = getProjection(getBrightness(pixels, d), d, true, 256);
  ygraphs[0].curve = getProjection(getBrightness(pixels, d), d, false, 256);
  int[] xp = new int[b.length/2];
  int[] yp = new int[b.length/2];
  int count = b.length/4;
  for (int i=0; i<count; i++) {
   xp[i*2] = b[i*4];
   xp[i*2+1] = b[i*4+1];
   yp[i*2] = b[i*4+2];
   yp[i*2+1] = b[i*4+3];
  }
  xgraphs[0].points = xp;
  ygraphs[0].points = yp;
  xgraphs[0].uPoints = null;
  ygraphs[0].uPoints = null;
  xgraphs[0].boundOrigins = null;
  ygraphs[0].boundOrigins = null;
  xgraphs[0].boundLengths = null;
  ygraphs[0].boundLengths = null;
  xgraphs[0].uBoundOrigins = null;
  ygraphs[0].uBoundOrigins = null;
  xgraphs[0].uBoundLengths = null;
  ygraphs[0].uBoundLengths = null;
  rangeValueGraph = Ce;
  updateGraph();
 }

 private Path2D createPath(int[] array, boolean h) {
  Path2D path = new Path2D.Double();
  path.moveTo(0.0, 0.0);
  for (int i=0; i<array.length; i++) {
   if (h)
    path.lineTo(i, array[i]);
   else
    path.lineTo(array[i], i);
  }
  if (h)
   path.lineTo(array.length-1.0, 0.0);
  else
   path.lineTo(0.0, array.length-1.0);
  path.closePath();
  return path;
 }

 private void updateGraph() {
  int[] d = new int[2];
  do {
   d[0] = image.getWidth(null);
   d[1] = image.getHeight(null);
  } while (d[0] <= 0 || d[1] <= 0);
  Graphics2D g;
  if (refreshCount==0 || !drawProj) {
   xProj = new BufferedImage(d[0], 100, BufferedImage.TYPE_INT_ARGB);
   g = xProj.createGraphics();
   g.setColor(Color.WHITE);
   g.fillRect(0,0,d[0],100);
  }
  else
   g = xProj.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        int in = comboBox.getSelectedIndex();
        int tx = 0;
        if (xgraphs != null) {
         for (Graph gr : xgraphs) {
          int temp = gr.curve[maxIndex(gr.curve)];
          tx = tx > temp ? tx : temp;
         }
        }
        switch (in) {
        case 1 :
         tx = (rangeValueGraph-1)*d[1];
         break;
        default :
         break;
        }
        g.scale(1.0, 100.0/tx);
        if (drawProj && xgraphs != null) {
         for (int i=0; i<xgraphs.length; i++) {
          int[] c = getColorSet(i+refreshCount, xgraphs.length+refreshCount);
          if (xgraphs[i].curve != null) {
              Path2D path = createPath(xgraphs[i].curve, true);
        g.setColor(new Color(0x0fffffff & c[0], true));
        g.fill(path);
        g.setColor(new Color(c[0]));
        g.draw(path);
          }
          if (xgraphs[i].boundOrigins != null && xgraphs[i].boundLengths != null) {
        g.setColor(new Color(0x3fffffff & c[1], true));
        for (int j=0; j<xgraphs[i].boundOrigins.length; j++) {
         g.fillRect(xgraphs[i].boundOrigins[j],0,xgraphs[i].boundLengths[j],tx);
        }
          }
          if (xgraphs[i].uBoundOrigins != null && xgraphs[i].uBoundLengths != null) {
        g.setColor(new Color(0x3fffffff & c[2], true));
        for (int j=0; j<xgraphs[i].uBoundOrigins.length; j++) {
         g.fillRect(xgraphs[i].uBoundOrigins[j],0,xgraphs[i].uBoundLengths[j],tx);
        }
          }
          if (xgraphs[i].points != null) {
        g.setColor(new Color(c[1]));
        for (int j=0; j<xgraphs[i].points.length; j++) {
         g.drawLine(xgraphs[i].points[j],0,xgraphs[i].points[j],tx);
        }
          }
          if (xgraphs[i].uPoints != null) {
        g.setColor(new Color(c[2]));
        for (int j=0; j<xgraphs[i].uPoints.length; j++) {
         g.drawLine(xgraphs[i].uPoints[j],0,xgraphs[i].uPoints[j],tx);
        }
          }
         }
  }
  g.dispose();
  if (refreshCount==0 || !drawProj) {
   yProj = new BufferedImage(100, d[1], BufferedImage.TYPE_INT_ARGB);
   g = yProj.createGraphics();
   g.setColor(Color.WHITE);
   g.fillRect(0,0,100,d[1]);
  }
  else
   g = yProj.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        int ty = 0;
        if (ygraphs != null) {
         for (Graph gr : ygraphs) {
          int temp = gr.curve[maxIndex(gr.curve)];
          ty = ty > temp ? ty : temp;
         }
        }
        switch (in) {
        case 1 :
         ty = (rangeValueGraph-1)*d[0];
         break;
        default :
         break;
        }
        g.scale(100.0/ty, 1.0);
  if (drawProj && ygraphs != null) {
   for (int i=0; i<ygraphs.length; i++) {
          int[] c = getColorSet(i+refreshCount, ygraphs.length+refreshCount);
          if (ygraphs[i].curve != null) {
              Path2D path = createPath(ygraphs[i].curve, false);
        g.setColor(new Color(0x0fffffff & c[0], true));
        g.fill(path);
        g.setColor(new Color(c[0]));
        g.draw(path);
          }
          if (ygraphs[i].boundOrigins != null && ygraphs[i].boundLengths != null) {
        g.setColor(new Color(0x3fffffff & c[1], true));
        for (int j=0; j<ygraphs[i].boundOrigins.length; j++) {
         g.fillRect(0,ygraphs[i].boundOrigins[j],ty,ygraphs[i].boundLengths[j]);
        }
          }
          if (ygraphs[i].uBoundOrigins != null && ygraphs[i].uBoundLengths != null) {
        g.setColor(new Color(0x3fffffff & c[2], true));
        for (int j=0; j<ygraphs[i].uBoundOrigins.length; j++) {
         g.fillRect(0,ygraphs[i].uBoundOrigins[j],ty,ygraphs[i].uBoundLengths[j]);
        }
          }
          if (ygraphs[i].points != null) {
        g.setColor(new Color(c[1]));
        for (int j=0; j<ygraphs[i].points.length; j++) {
         g.drawLine(0,ygraphs[i].points[j],ty,ygraphs[i].points[j]);
        }
          }
          if (ygraphs[i].uPoints != null) {
        g.setColor(new Color(c[2]));
        for (int j=0; j<ygraphs[i].uPoints.length; j++) {
         g.drawLine(0,ygraphs[i].uPoints[j],ty,ygraphs[i].uPoints[j]);
        }
          }
         }
  }
  g.dispose();
  refreshCount++;
 }

 private static int maxIndex(int[] array) {
  int mi = 0;
  for(int i=1; i<array.length; i++) {
   if (array[i] > array[mi]) {
    mi = i;
   }
  }
  return mi;
 }

 private static int minIndex(int[] array) {
  int mi = 0;
  for(int i=1; i<array.length; i++) {
   if (array[i] < array[mi]) {
    mi = i;
   }
  }
  return mi;
 }

 private static int[] getPixels(BufferedImage image, int[] d) {
  d[0] = image.getWidth();
  d[1] = image.getHeight();
  return image.getRGB(0, 0, image.getWidth(), image.getHeight(),
    null, 0, image.getWidth());
 }

 private static int[] getBrightness(int[] pixels, int[] d) {
  int[] pb = new int[d[0]*d[1]];
  for(int i=0; i<pixels.length; i++) {
   pb[i] = getBrightness(pixels[i]);
  }
  return pb;
 }

 private static int threshold(int px, int l, boolean b, int sat0, int sat1) {
  int temp = b ? getBrightness(px) : px;
  if (temp < sat0)
   return 0;
  else if (temp > sat1)
   return 255;
  temp = (temp-sat0)*l/(sat1-sat0+1);
  temp = (int)(temp*255/(l-1.0)+0.5);
  return temp;
 }

 private static int[] getAlpha(int[] pixels, int[] d) {
  int[] pb = new int[d[0]*d[1]];
  for(int i=0; i<pixels.length; i++) {
   pb[i] = (pixels[i]>>24) & 0xff;
  }
  return pb;
 }

 private static int[] getRed(int[] pixels, int[] d) {
  int[] pb = new int[d[0]*d[1]];
  for(int i=0; i<pixels.length; i++) {
   pb[i] = (pixels[i]>>16) & 0xff;
  }
  return pb;
 }

 private static int[] getGreen(int[] pixels, int[] d) {
  int[] pb = new int[d[0]*d[1]];
  for(int i=0; i<pixels.length; i++) {
   pb[i] = (pixels[i]>>8) & 0xff;
  }
  return pb;
 }

 private static int[] getBlue(int[] pixels, int[] d) {
  int[] pb = new int[d[0]*d[1]];
  for(int i=0; i<pixels.length; i++) {
   pb[i] = pixels[i] & 0xff;
  }
  return pb;
 }

 private static int[] mixRGB(int[] pa, int[] pr, int[] pg, int[] pb, int[] d) {
  int[] pm = new int[d[0]*d[1]];
  normalizeBrightness(pa);
  normalizeBrightness(pr);
  normalizeBrightness(pg);
  normalizeBrightness(pb);
  for(int i=0; i<pm.length; i++) {
   pm[i] = (pa[i]<<24 | pr[i]<<16 | pg[i]<<8 | pb[i]);
  }
  return pm;
 }

 private static int getBrightness(int rgb) {
  int r = (rgb>>16) & 0xff;
  int g = (rgb>>8) & 0xff;
  int b = rgb & 0xff;
  return (int) (Kr*r + Kg*g + Kb*b + 0.5);
 }

 private static void normalizeBrightness(int[] pixels) {
  for(int i=0; i<pixels.length; i++) {
   int px = pixels[i];
   if (px > 255)
    px = 255;
   else if (px < 0)
    px = 0;
   pixels[i] = px;
  }
 }

 private static void brightnessToRGB(int[] pixels) {
  normalizeBrightness(pixels);
  for(int i=0; i<pixels.length; i++) {
   int px = pixels[i];
   pixels[i] = (0xff000000 | px<<16 | px<<8 | px);
  }
 }

 private static int[] simpleEdge(int[] f, int[] d, int t, int sat0, int sat1) {
  int[] fe = new int[d[0]*d[1]];
  for (int y=0; y<d[1]; y++) {
   for (int x=0; x<d[0]; x++) {
    int temp = 0;
    if (x > 0) {
     temp = Math.abs(f[y*d[0]+x]-f[y*d[0]+x-1]);
    }
    if (x < d[0]-1) {
     int temp2 = Math.abs(f[y*d[0]+x]-f[y*d[0]+x+1]);
     if (temp2 > temp)
      temp = temp2;
    }
    fe[y*d[0]+x] = threshold(temp, t, false, sat0, sat1);
   }
  }
  return fe;
 }

 private static int[] resizeTo(int[] f, int[] d, int w, int h) {
  int[] fr, fra = new int[w*h], frr = new int[w*h], frg = new int[w*h], frb = new int[w*h],
    pa = getAlpha(f, d), pr = getRed(f, d), pg = getGreen(f, d), pb = getBlue(f, d);
  int cy = 0, ya = 0, yb = 0, ly = d[1];
  int[] pya = new int[w], pyr = new int[w], pyg = new int[w], pyb = new int[w];
  while (yb<h) {
   if (cy==0) {
    cy = h;
    for (int i=0; i<pyr.length; i++) {
     pya[i] = 0;
    }
    for (int i=0; i<pyr.length; i++) {
     pyr[i] = 0;
    }
    for (int i=0; i<pyg.length; i++) {
     pyg[i] = 0;
    }
    for (int i=0; i<pyb.length; i++) {
     pyb[i] = 0;
    }
    int cx = 0, xa = 0, xb = 0, pxa = 0, pxr = 0, pxg = 0, pxb = 0, lx = d[0];
    while (xb<w) {
     if (cx==0) {
      cx = w;
      pxa = pa[ya*d[0]+xa];
      pxr = pr[ya*d[0]+xa];
      pxg = pg[ya*d[0]+xa];
      pxb = pb[ya*d[0]+xa];
      xa++;
     }
     else {
      int dx = cx<lx ? cx : lx;
      cx -= dx;
      lx -= dx;
      pya[xb] += pxa*dx;
      pyr[xb] += pxr*dx;
      pyg[xb] += pxg*dx;
      pyb[xb] += pxb*dx;
      if (lx==0) {
       lx = d[0];
       xb++;
      }
     }
    }
    ya++;
   }
   else {
    int dy = cy<ly ? cy : ly;
    cy -= dy;
    ly -= dy;
    for (int xb=0;xb<w;xb++) {
     fra[yb*w+xb] += pya[xb]*dy;
    }
    for (int xb=0;xb<w;xb++) {
     frr[yb*w+xb] += pyr[xb]*dy;
    }
    for (int xb=0;xb<w;xb++) {
     frg[yb*w+xb] += pyg[xb]*dy;
    }
    for (int xb=0;xb<w;xb++) {
     frb[yb*w+xb] += pyb[xb]*dy;
    }
    if (ly==0) {
     ly = d[1];
     yb++;
    }
   }
  }

  int s = d[0]*d[1];
  for(int y=0; y<h; y++) {
   for(int x=0; x<w; x++) {
    int a = fra[y*w+x];
    int r = frr[y*w+x];
    int g = frg[y*w+x];
    int b = frb[y*w+x];
    fra[y*w+x] = (a+s/2)/s;
    frr[y*w+x] = (r+s/2)/s;
    frg[y*w+x] = (g+s/2)/s;
    frb[y*w+x] = (b+s/2)/s;
   }
  }

  d[0] = w;
  d[1] = h;
  fr = mixRGB(fra, frr, frg, frb, d);

  return fr;
 }

 private static int[] crop(int[] f, int[] d, int px, int py, int w, int h) {
  int[] fc = new int[w*h];
  for(int y=0; y<h; y++) {
   for(int x=0; x<w; x++) {
    int q = y+py, p = x+px;
    if (q >= 0 && q < d[1] && p >= 0 && p < d[0])
     fc[y*w+x] = f[q*d[0]+p];
   }
  }
  d[0] = w;
  d[1] = h;
  return fc;
 }

 private static int[] sort(int[] value) {
  int[] index = new int[value.length];
  for (int i=0; i<index.length; i++) {
   index[i] = i;
  }
  value = Arrays.copyOf(value, value.length);
  sort(index, value, 0, value.length);
  return index;
 }

 private static void sort(int[] index, int[] value, int start, int length) {
  if (length <= 1)
   return;
  sort(index, value, start, length/2);
  sort(index, value, start+length/2, length-length/2);
  int[] c1 = Arrays.copyOfRange(index, start, start+length/2);
  int[] c2 = Arrays.copyOfRange(index, start+length/2, start+length);
  int[] i1 = Arrays.copyOfRange(value, start, start+length/2);
  int[] i2 = Arrays.copyOfRange(value, start+length/2, start+length);
  for (int j=0,k=0; j+k<length;) {
   if (k == i2.length || (j < i1.length && i1[j] <= i2[k])) {
    value[start+j+k] = i1[j];
    index[start+j+k] = c1[j];
    j++;
   }
   else {
    value[start+j+k] = i2[k];
    index[start+j+k] = c2[k];
    k++;
   }
  }
 }

 @Override
 public void focusGained(FocusEvent evt) {
  repaint();
 }

 @Override
 public void focusLost(FocusEvent evt) {
  repaint();
 }

 @Override
 public void keyPressed(KeyEvent evt) {
  int key = evt.getKeyCode();
  if (key == KeyEvent.VK_LEFT) {
   previousImage();
  }
  else if (key == KeyEvent.VK_RIGHT) {
   nextImage();
  }
  int[] dist = computeKNN(image);
  summaryTextArea.setText(distanceText(dist));
  updateGraphDefault();
  if (segmentation)
   imgLabel.setText("segmen " + indexSegmented);
  else
   imgLabel.setText("citra " + index);
  repaint();
 }

 @Override
 public void keyReleased(KeyEvent evt) {
  repaint();
 }

 private String numberPlate() {
  int[] d = new int[2], pixels = getPixels(testImages[index], d);
  return (String) numberPlate(pixels, d, 0);
 }

 private Object numberPlate(int[] pixels, int[] d, int stage) {
  String s = "";
  double d0 = (double) Cw/d[0], d1 = (double) Ch/d[1];
  timeExecution = 0;
  timeCheck = System.currentTimeMillis();
  if (d0 < d1)
   pixels = resizeTo(pixels, d, Cw, d[1]*Cw/d[0]);
  else
   pixels = resizeTo(pixels, d, d[0]*Ch/d[1], Ch);
  pixels = crop(pixels, d, (d[0]-Cw)/2, (d[1]-Ch)/2, Cw, Ch);
  if (stage == 1) {
   timeExecution = System.currentTimeMillis()-timeCheck;
   return pixels;
  }
  int[] vb = vBounds(pixels, d, Cmb, Csb);
  pixels = crop(pixels, d, 0, vb[0], d[0], vb[1]-vb[0]+1);
  if (stage == 2) {
   timeExecution = System.currentTimeMillis()-timeCheck;
   return pixels;
  }
  int[] pb = plateBounds(pixels, d, Cmp, Csp);
  pixels = crop(pixels, d, pb[0], 0, pb[1]-pb[0]+1, d[1]);
  if (stage == 3) {
   timeExecution = System.currentTimeMillis()-timeCheck;
   return pixels;
  }
  for (int i=0; i<pixels.length; i++) {
   int k = threshold(pixels[i], Ct, true, Csat0t, Csat1t);
   pixels[i] = (0xff000000 | k<<16 | k<<8 | k);
  }
  if (stage == 4) {
   timeExecution = System.currentTimeMillis()-timeCheck;
   return pixels;
  }
  BufferedImage[] si = createSegmentedImages(pixels, d);
  if (stage == 5) {
   timeExecution = System.currentTimeMillis()-timeCheck;
   return si;
  }
  for (BufferedImage img : si) {
   int[] dist = computeKNN(img);
   s += NUMBERS_AND_LETTERS[minIndex(dist)];
  }
  timeExecution = System.currentTimeMillis()-timeCheck;
  timeExecutionTotal += timeExecution;
  executionCount++;
  return s;
 }

 @Override
 public void keyTyped(KeyEvent evt) {
  char key = evt.getKeyChar();
  if (key >= '0' && key <= '9') {
   int[] dist = computeKNN(fontImages[key-'0']);
   summaryTextArea.setText("distance relatif " + key + "\n" + distanceText(dist));
  }
  else if (key >= 'a' && key <= 'z') {
   int[] dist = computeKNN(fontImages[key-'a'+10]);
   key = (char) (key-'a'+'A');
   summaryTextArea.setText("distance relatif " + key + "\n" + distanceText(dist));
  }
  else if (key == ' ') {
   int[] a = new int[256];
   Arrays.fill(a, 0xffffffff);
   int[] dist = computeKNN(a, new int[]{16,16});
   summaryTextArea.setText("distance relatif '" + key + "'\n" + distanceText(dist));
  }
  else if (key == '\n') {
   summaryTextArea.setText(numberPlate());
   summaryTextArea.append("\nwaktu eksekusi " + timeExecution + " ms");
   summaryTextArea.append("\nwaktu eksekusi rata-rata " + (timeExecutionTotal/(double)executionCount) + " ms");
  }
  else if (key == '.') {
   int[] d = new int[2];
   int[][] fonts = new int[36][];
   for (int i=0; i<36; i++) {
    fonts[i] = getBrightness(getPixels(fontImages[i], d), d);
   }
   String s = "memory_initialization_radix=2;\nmemory_initialization_vector=\n";
   for (int i=0; i<576; i++) {
    for (int j=15; j>=0; j--) {
     s += fonts[i/16][(i%16)*16+j] < 128 ? "0" : "1";
    }
    if (i<575)
     s += ",\n";
    else
     s += ";";
   }
   System.out.println(s);
  }
  else if (key == ',') {
   int[] d = new int[2];
   int[][] fonts = new int[36][];
   for (int i=0; i<36; i++) {
    fonts[i] = getPixels(fontImages[i], d);
   }
   for (int i=0; i<36; i++) {
    if (i < 10)
     System.out.println(i);
    else
     System.out.println((char)('A'+(i-10)));
    for (int j=0; j<16; j++) {
     for (int k=0; k<16; k++) {
      System.out.printf("%8x ", fonts[i][j*16+k]);
     }
     System.out.println();
    }
    System.out.println();
   }
  }
  else if (key == '\\') {
   timeExecutionTotal = 0;
   executionCount = 0;
  }
  repaint();
 }

 @Override
 public void mouseClicked(MouseEvent evt) {
  if (!hasFocus())
   requestFocus();
  repaint();
 }

 @Override
 public void mouseEntered(MouseEvent evt) {
  if (!hasFocus())
   requestFocus();
  repaint();
 }

 @Override
 public void mouseExited(MouseEvent evt) {
  if (!hasFocus())
   requestFocus();
  repaint();
 }

 @Override
 public void mousePressed(MouseEvent evt) {
  if (!hasFocus())
   requestFocus();
  repaint();
 }

 @Override
 public void mouseReleased(MouseEvent evt) {
  if (!hasFocus())
   requestFocus();
  repaint();
 }

 @Override
 public void componentHidden(ComponentEvent evt) {

 }

 @Override
 public void componentMoved(ComponentEvent evt) {

 }

 @Override
 public void componentResized(ComponentEvent evt) {
  computeBounds();
 }

 private void computeBounds() {
  prevButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE, BUTTON_WIDTH, BUTTON_HEIGHT);
  nextButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE), BUTTON_WIDTH, BUTTON_HEIGHT);
  projButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*2, BUTTON_WIDTH, BUTTON_HEIGHT);
  resetButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*3, BUTTON_WIDTH, BUTTON_HEIGHT);
  segmentButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*(4+filters.length), BUTTON_WIDTH, BUTTON_HEIGHT);
  plateNumberButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*(5+filters.length), BUTTON_WIDTH, BUTTON_HEIGHT);
  comboBox.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*(6+filters.length), BUTTON_WIDTH, BUTTON_HEIGHT);
  saveImageButton.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*(7+filters.length), BUTTON_WIDTH, BUTTON_HEIGHT);
  for (int i=0; i<filters.length; i++) {
   filters[i].button.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*1, SPACE+(BUTTON_HEIGHT+SPACE)*(i+4), BUTTON_WIDTH, BUTTON_HEIGHT);
  }
  imgLabel.setBounds(0, getHeight()-40, getWidth(), 40);
  summaryTextArea.setBounds(getWidth()-(BUTTON_WIDTH+SPACE)*3, SPACE, BUTTON_WIDTH*2+SPACE, (BUTTON_HEIGHT+SPACE)*16-SPACE);
 }

 @Override
 public void componentShown(ComponentEvent evt) {

 }

 @Override
 public void itemStateChanged(ItemEvent evt) {
  refreshCount = 0;
  updateGraph();
 }
}