
class PassData 
{
  String viewName;
  int    basisFrame;
  int    firstLightFrame;
  int    frameSequenceCount;
  float  thresholdValue;
  
  public PassData(String viewName, int basisFrame, int firstLightFrame, int frameSequenceCount, float thresholdValue) {
    this.viewName           = viewName;
    this.basisFrame         = basisFrame;
    this.firstLightFrame    = firstLightFrame;
    this.frameSequenceCount = frameSequenceCount;
    this.thresholdValue     = thresholdValue;
  }
}

class StateFrameAnalysis extends BaseState
{
  ArrayList<LightInfo>  lights = new ArrayList<LightInfo>();
  
  PassData  info;
  PImage    basis;
  PImage    current;
  int       currentIndex;
  String    fileDataPath;
  
  
  public StateFrameAnalysis(String name, PassData info) {
    super(name);
    this.info = info;
  }
  
  public void enter() {
    println("enter");
    fileDataPath = sketchPath("../ViewData/" + info.viewName + ".data");
    basis = loadFrame(info.viewName, info.basisFrame);
    
    currentIndex = info.firstLightFrame;
    loadCurrentFrame();
    compareFrames();
  }
  
  public void update() {
    println("update " + currentIndex);
    background(0);
    
    cam.beginHUD();
    
    scale((float)height / basis.height);
    image(basis,0,0);
    translate(basis.width,0);
    image(current,0,0);
    
    for(int i=0; i<lights.size(); ++i) {
      var lightPos = lights.get(i);
      noStroke();
      fill(255);
      ellipse(lightPos.pos.x, lightPos.pos.y, 5,5);
    }
    
    // Process the current frame
    if(currentIndex < info.frameSequenceCount) { 
      ++currentIndex;
      loadCurrentFrame();
      compareFrames();
    } else if(currentIndex == info.frameSequenceCount) { 
      // Done, save out the data
      ++currentIndex;
      complete();
    }
    
    cam.endHUD();
  }
  
  public void exit() {
    saveValues(fileDataPath, lights);
  }
  
    
  class ThreshPoint {
    int   x, y;
    float power;
  }
  
  void compareFrames() {
    
    var foundPoints = new ArrayList<ThreshPoint>();
    
    for(int y=0; y<basis.height; ++y) {
      for(int x=0; x<basis.width; ++x) {
        int   index = y * basis.width + x;
        color b     = basis.pixels[index];
        color c     = current.pixels[index];
        
        float dr = red(c)   - red(b);
        float dg = green(c) - green(b);
        float db = blue(c)  - blue(b);
        
        var power = sqrt(dr*dr + dg*dg + db*db);
        if (power > info.thresholdValue) {
          stroke(255,0,0);
          point(x,y);
          
          ThreshPoint p = new ThreshPoint();
          p.x     = x;
          p.y     = y;
          p.power = power;
          foundPoints.add(p);
        }
      }
    }
    
    
    if (foundPoints.size() < 1) {
      println("Frame ["+currentIndex+"] No lights found."); 
      return;
    }
    
    float totalPower = 0.0f;
    for(int i=0; i<foundPoints.size(); ++i) {
      totalPower += foundPoints.get(i).power;
    }
    
    var minPt = new PVector();
    var maxPt = new PVector();
    
    maxPt.x = minPt.x = foundPoints.get(0).x;
    maxPt.y = minPt.y = foundPoints.get(0).y;
    
    var weightedPos = new PVector();
    for(int i=0; i<foundPoints.size(); ++i) {
      var pt = foundPoints.get(i);
      minPt.x = min(minPt.x, pt.x);
      minPt.y = min(minPt.y, pt.y);
      maxPt.x = max(maxPt.x, pt.x);
      maxPt.y = max(maxPt.y, pt.y);
      
      weightedPos.x += pt.x * pt.power / totalPower; 
      weightedPos.y += pt.y * pt.power / totalPower;
    }
    
    stroke(255);
    noFill();
    rect(minPt.x, minPt.y, maxPt.x-minPt.x, maxPt.y-minPt.y);
    
    stroke(0,255,0);
    rect(weightedPos.x - 2.5, weightedPos.y - 2.5, 5,5);
    
    println("Frame ["+currentIndex+"] Light at ("+weightedPos.x+","+weightedPos.y+")");
    
    var lightInfo   = new LightInfo();
    lightInfo.pos   = weightedPos;
    lightInfo.power = totalPower;
    lightInfo.frame = currentIndex - info.firstLightFrame;
    lights.add(lightInfo);
  }
  
  
  void loadCurrentFrame()
  {
    current = loadFrame(info.viewName, currentIndex);
  }
  
  PImage loadFrame(String folder, int frame)
  {
    String inputFilename = sketchPath("../ViewData/" + folder + "/" + "frame" + nf(frame, 6) + ".png");
    var img = loadImage(inputFilename);
    img.loadPixels();
    return img; 
  }
}
