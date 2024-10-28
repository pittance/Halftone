
class Halftone{
  //defines a grid of halftone dots
  
  //halftone parameters
  float angle;      //this is the angle of the halftone grid, can be any but some angles are suggested for CMYK
  float spacing;    //dot spacing (centres)
  float wide;       
  float high;
  
  //subclasses
  Dot[] dots;       //array of Dots (Dot is a subclass of Halftone)
  Picinterp pi;     //interpolation class to manage getting brightnesses
  
  //NOTE: Dot defaults to a setting for the spiral spacing that works for the images I tried it with
  //      This probably needs to be accessible in Halftone since this is not a good idea to keep
  //      hidden
  
  //defaults - only dWht is used as dBlk is set in constructor to be the same as the spacing
  float dWht = 1;   //diameter for "white" dots
  float dBlk = 20;  //diameter for "black" dots
  
  //output file path
  String outfile;
  
  Halftone(float wide, float high, float angle, float spacing, PImage p, String outfile) {
    this.wide = wide;
    this.high = high;
    this.angle = angle;
    this.spacing = spacing;
    this.outfile = outfile;
    dBlk = spacing;      //set the max diameter of the dots to the spacing
    dots = new Dot[0];   //this is a 1D array so we can loop along it but dots are arranged in 2D
    pi = new Picinterp(p);
  }
  
  void createGrid(int extraLeft, int extraTop, int across, int down) {
    //dots created by estimating the number across and down then adding more to the left and right, top and bottom
    //when this is done the dots outside of the frame will be removed
    
    int numAcross = extraLeft+across;
    int numDown = extraTop+down;
    println("total across/down: " + numAcross + "/" + numDown);
    
    //find the vertical and horizontal spacing between dots
    float cSpc = spacing*cos(angle);
    float sSpc = spacing*sin(angle);
    
    //arrays to store the coords
    float[][] xs = new float[numAcross][numDown];
    float[][] ys = new float[numAcross][numDown];
    boolean[][] ins = new boolean[numAcross][numDown];
    
    //count the number of dots to use
    int dotCount = 0;
    
    //fill the arrays
    for(int j=0;j<numDown;j++) {
      for (int i=0;i<numAcross;i++) {
        xs[i][j] = - j*sSpc + i*cSpc - cSpc*extraLeft;
        ys[i][j] = j*cSpc + i*sSpc - cSpc*extraTop;
        ins[i][j] = (((xs[i][j] > 0) && (xs[i][j] < wide)) && ((ys[i][j] > 0) && (ys[i][j] < high)));
        if(ins[i][j]) dotCount++;
      }
    }
    
    println("we made " + dotCount + " dots that fit in the frame");
    
    //declare the array of Dots
    dots = new Dot[dotCount];
    
    dotCount = 0;  //re use this counter, why not (I'm sure I won't regret this)
    
    for(int j=0;j<numDown;j++) {
      for (int i=0;i<numAcross;i++) {
        if(ins[i][j]) {
          dots[dotCount] = new Dot(xs[i][j],ys[i][j]);
          dots[dotCount].setDiam(map(pi.bright(dots[dotCount].x,dots[dotCount].y),0,255,dBlk,dWht));
          dotCount++;
        }
      }
    }
    
  }
  
  void draw() {
    beginRecord(SVG, outfile);
    for (int i=0;i<dots.length;i++) {
      dots[i].draw();
    }
    endRecord();
  }
  
  class Dot {
    //basic settings
    float x;
    float y;
    float diam = 5;
    
    //spiral settings
    float minRad = 0.5;  //point to start from
    float step = 0.5;  //step along the spiral
    
    float pxPerLoop = 5;
    
    Dot(float x, float y) {
      this.x = x;
      this.y = y;
    }
    
    void setDiam(float diam) {
      this.diam = diam;
    }
    
    void draw() {
      //start from the min radius
      float currRad = minRad;
      float currAng = 0;
      //start draw
      noFill();
      beginShape();
      //spiral part
      println();
      while (currRad<=(diam/2)) {
        vertex(x+(currRad*cos(currAng)),y+(currRad*sin(currAng)));
        currAng += step/currRad;
        currRad = pxPerLoop*(currAng/TWO_PI);
      }
      //circle around
      int circSteps = int((PI * 2 * currRad) / step);
      for (int i=0;i<circSteps;i++) {
        vertex(x+(currRad*cos(currAng)),y+(currRad*sin(currAng)));
        currAng += step/currRad;
      }
      endShape();
    }
  }
  
  class Picinterp {
    float[][] b; //stores brightness values of image
    float[] w, h;
    int wide,high;
    
    Picinterp(PImage p) {
      //setup array and load brightness values into array
      wide = p.width;
      high = p.height;
      b = new float[wide][high];
      w = new float[wide];
      h = new float[high];
      for (int i=0;i<wide;i++) {
        w[i] = i;
        for (int j=0;j<high;j++) {
          if (i==0) h[j] = j;
          b[i][j] = brightness(p.get(i,j));
        } 
      }
    }
    
    float bright(float x, float y) {
      //return interpLin2d(w,h,b,x*wide,y*high);
      return brightness(p.get(int(x),int(y)));
    }
    
    
    //not used, nearest neighbor interpolation is OK for these low res things
    //averaging over an area would probably be better
    private float interpLin(float[] XXs, float[] YYs, float x) {
      int count = XXs.length;
      if (x >= XXs[count-1]) {
        int i = count-1;
        return YYs[i-1] + (YYs[i]-YYs[i-1])*((x-XXs[i-1])/(XXs[i]-XXs[i-1]));
      } else if (x < XXs[0]) {
        int i = 0;
        return YYs[i] + (YYs[i+1]-YYs[i])*((x-XXs[i])/(XXs[i+1]-XXs[i]));
      } else {
        for (int i=0;i<count-1;i++) {
          if ((x >= XXs[i]) && (x < XXs[i+1])) {
            return YYs[i] + (YYs[i+1]-YYs[i])*((x-XXs[i])/(XXs[i+1]-XXs[i]));
          }
        }
      }
      return 0.0;
    }
    
    private float interpLin2d(float[] XXs, float[] YYs, float[][] ZZs, float x, float y) {
      int xLen = XXs.length;
      float[] tempZ = new float[xLen];
      //interpolate across the ZZ array using the YY array (for each XX)
      for (int i=0;i<xLen;i++) {
        tempZ[i] = interpLin(YYs,ZZs[i],y);
      }
      return interpLin(XXs,tempZ,x);
    }
    
  }
  
  
}
