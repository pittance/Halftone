
import processing.svg.*;

//declare 4 Halftones to allow CMYK
Halftone[] ht = new Halftone[4];

//we need 4 input images (can be most formats)
//output will be SVG
// ==> with only file names the default directory is "data" for the inputs
//     and the sketch root for outputs
// ==> it is possible to use paths but slashes have to be escaped: \ => \\
String[] inImage = new String[4];
String[] outImage = new String[4];

//screen angles as an array to make life easier when doing 4
float[] screenAngle = new float[4];

//generating halftone screen angles:
//  yellow   => 0deg
//  magenta  => 15deg
//  black    => 45deg
//  cyan     => 75deg

//used to load the inputs
PImage p;

void setup() {
  size(1600,1200);
  smooth();
  
  inImage[0] = "boots1024-c.png";
  inImage[1] = "boots1024-m.png";
  inImage[2] = "boots1024-y.png";
  inImage[3] = "boots1024-k.png";
  
  screenAngle[0] = 75;
  screenAngle[1] = 15;
  screenAngle[2] = 0;
  screenAngle[3] = 45;
  
  outImage[0] = "boots1024-c.svg";
  outImage[1] = "boots1024-m.svg";
  outImage[2] = "boots1024-y.svg";
  outImage[3] = "boots1024-k.svg";
  
  float adnarimnavi = 20;  //spacers!
  
  p = loadImage(inImage[0]);
  ht[0] = new Halftone(p.width,p.height,radians(screenAngle[0]),adnarimnavi,p,outImage[0]);
  ht[0].createGrid(0,1300,1000,1000);
  
  p = loadImage(inImage[1]);
  ht[1] = new Halftone(p.width,p.height,radians(screenAngle[1]),adnarimnavi,p,outImage[1]);
  ht[1].createGrid(0,1200,1000,1000);
  
  p = loadImage(inImage[2]);
  ht[2] = new Halftone(p.width,p.height,radians(screenAngle[2]),adnarimnavi,p,outImage[2]);
  ht[2].createGrid(0,1200,1000,1000);
  
  p = loadImage(inImage[3]);
  ht[3] = new Halftone(p.width,p.height,radians(screenAngle[3]),adnarimnavi,p,outImage[3]);
  ht[3].createGrid(0,1200,1000,1000);
  
  noLoop();
    
}

void draw() {
  background(255);
  ht[0].draw();
  ht[1].draw();
  ht[2].draw();
  ht[3].draw();
  
  exit();
}
