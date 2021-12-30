
class StateViewSolver extends BaseState
{
  protected ArrayList<ArrayList<LightInfo>>        views       = new ArrayList<ArrayList<LightInfo>>();
  protected ArrayList<TreeMap<Integer, LightInfo>> viewByFrame = new ArrayList<TreeMap<Integer, LightInfo>>();
  protected PVector[]                              viewPos     = new PVector[frameOffsets.length];
 
  class SolveLight {
    int         frame;
    int         nonNullCount = 0;
    LightInfo[] lightInViews = new LightInfo[4];
  }
  
  ArrayList<SolveLight> toSolve = new ArrayList<SolveLight>();
  
  public StateViewSolver(String name) { super(name); }
  
  public void enter()  {
    // Load and init all values
    for(int i=0; i<4; ++i) {
      var view = (ArrayList<LightInfo>)loadValues(sketchPath("../ViewData/view"+i+".data"));
      views.add(view);
      var lookup = new TreeMap<Integer, LightInfo>();
      viewByFrame.add(lookup);
      for(int j=0; j<view.size(); ++j ) {
        var viewInfo = view.get(j);
        lookup.put(viewInfo.frame, viewInfo);
      }
    }
    
    
    var v = new LightInfo[4];
    for (int i=0; i<1600; i+=4) {
      
      int nonNullCount = 0;
      for (int j=0; j<4; ++j) {
        v[j] = getConsolodatedLightInfo(j, i - frameOffsets[j]);
        if (v[j] != null) {
          ++nonNullCount;
        }
      }
      
      if (nonNullCount > 0) {
        var s = new SolveLight();
        s.nonNullCount = nonNullCount;
        s.frame = i;
        for(int j=0; j<4; ++j) {
          s.lightInViews[j] = v[j];
        }
        toSolve.add(s);
      }
    }
     
    // @TODO - build an interface to calculate these
    float a0 = 19*PI/180.0f;
    float a1 = (19+13.5)*PI/180.0f;
    float a2 = (19+13.5+9.7)*PI/180.0f;
    viewPos[0] = new PVector(150,60,0);
    viewPos[1] = new PVector(156*cos(a0),60,156*sin(a0));
    viewPos[2] = new PVector(162*cos(a1),60,162*sin(a1));
    viewPos[3] = new PVector(180*cos(a2),60,180*sin(a2));
  }
  
  
  LightInfo getConsolodatedLightInfo(int viewIndex, int frameIndex) {
     float totalPower = 0;
     
     var v = new LightInfo[4];
     for(int i=0; i<4; ++i) {
       v[i] = getViewInfoAtFrame(viewIndex, frameIndex + i);
       if (v[i] != null) {
         totalPower += v[i].power;
       }
     }
     
     if (totalPower == 0)
       return null;
       
     var result = new LightInfo();
     result.power = totalPower;
     result.frame = frameIndex;
     for(int i=0; i<4; ++i) {
       if (v[i] == null)
         continue;
        
        result.pos.add( v[i].pos.copy().mult(v[i].power / totalPower) );
     }
     
     return result;
  }
  
  LightInfo getViewInfoAtFrame(int viewIndex, int frameIndex) {
    var lookup = viewByFrame.get(viewIndex);
    if (!lookup.containsKey(frameIndex))
      return null;
      
    return lookup.get(frameIndex);
  }
}


class StateDataAnalysis extends StateViewSolver {
  public StateDataAnalysis(String name) {
    super(name);
  }
  
  
  
  


  
  SolveLight activeSolve;
  
  
  
  public void update() {
    int n = (int)map(mouseX,0,width,0,100);
    for(int i=0; i<toSolve.size(); ++i) {
      activeSolve = toSolve.get(i);
      if (activeSolve.nonNullCount == frameOffsets.length) {
        if (n == 0) break;
        --n;
      }
    }
    
    background(0);
    
    cam.beginHUD();
    drawProcessedData();
    cam.endHUD();
    
    
    //scale(10);
    lights();
    
    noStroke();
    fill(255);
    pushMatrix();
      translate(0,12*7/2,0);
      scale(4,12*7,4);
      box(1);
    popMatrix();
    
  
    PVector[] points = new PVector[] {
      new PVector(), new PVector(), new PVector(), new PVector()
    };
    PVector[] directions = new PVector[] {
      new PVector(), new PVector(), new PVector(), new PVector()
    };
    
    for (int i=0; i<frameOffsets.length; ++i) {
      stroke(64);
      line(0,0,0, viewPos[i].x, 0, viewPos[i].z);
      line(viewPos[i].x, 0, viewPos[i].z, viewPos[i].x, viewPos[i].y, viewPos[i].z);
      
      var from  = viewPos[i].copy();
      from.y = 0;
      var to    = from.mult(-1).normalize();
      var up    = new PVector(0,1,0);
      var right = to.cross(up).normalize();
      
      up = to.cross(right).normalize();
      
      pushMatrix();
        //translate(viewPos[i].x,viewPos[i].y,viewPos[i].y);
        applyMatrix(
          right.x, right.y, right.z, viewPos[i].x,
          up.x,    up.y,    up.z,    viewPos[i].y,
          to.x,    to.y,    to.z,    viewPos[i].z,
          0,       0,       0,       1
        );
        
        strokeWeight(2);
        
        
        //var a = 0.5f * 21.0f * PI / 180.0f;
        //var b = 0.5f * 37.3f * PI / 180.0f;
        //var d = 180;
        //pushMatrix();
        //  rotateX(b);
        //  line(0,0,0, d*sin(a), 0, d*cos(a));
        //  line(0,0,0, d*sin(-a), 0, d*cos(-a));
        //popMatrix();
        //pushMatrix();
        //  rotateX(-b);
        //  line(0,0,0, d*sin(a), 0, d*cos(a));
        //  line(0,0,0, d*sin(-a), 0, d*cos(-a));
        //popMatrix();
        
        noStroke();
        box(2);
        
        var x = 54/2 - activeSolve.lightInViews[i].pos.x/10.0f;
        var y = -98/2 + activeSolve.lightInViews[i].pos.y/10.0f;
        
        var r = new PVector(x, y, 140);
        r.normalize();
        r.mult(200);
        stroke(255);
        line(0,0,0, r.x,r.y,r.z);
        
        //var pgl = (PGraphics3D)g;
        //var model = pgl.getMatrix(new PMatrix3D());
        //var wFrom = model.mult(new PVector(), new PVector()); // Get worldspace vector
        //var wTo   = model.mult(r, new PVector()); // Get worldspace vector
              
        var wTo = new PVector(
          modelX(r.x,r.y,r.z),
          modelY(r.x,r.y,r.z),
          modelZ(r.x,r.y,r.z)
        );
        
      popMatrix();
      
      noStroke();
      fill(255);
      pushMatrix(); translate(viewPos[i].x,viewPos[i].y,viewPos[i].z); box(3); popMatrix();
      pushMatrix(); translate(wTo.x, wTo.y, wTo.z); box(3); popMatrix();
      
      points[i].set(viewPos[i].x,viewPos[i].y,viewPos[i].z);
      directions[i].set(wTo.x - viewPos[i].x, wTo.y - viewPos[i].y, wTo.z - viewPos[i].z);
      directions[i].normalize();
    }
  
    var closePt = findNearestPoint(points,directions);
    fill(0,255,0);
    pushMatrix(); translate(closePt.x,closePt.y,closePt.z); box(3); popMatrix();
  }
  public void       exit()   {}
  
  
  
  void drawProcessedData()
  { 
   
    //@TODO - update this to follow active solve
    //translate(-map(mouseX, 0,width, -1000, 10000-width),0);
    
    stroke(32);
    for(int i=0; i<1600; i+=4) {
      float x = map(i, 0,1600, 0,10000);
      line(x,0,x,height);
    }
    
    var rowWidth = 10000;
    var rowHeight = 200;
    
    for (int i=0; i<4; ++i) {
      drawData(views.get(i), rowHeight*i, rowHeight, rowWidth, frameOffsets[i]);
    }
    
    for(int i=0; i<toSolve.size(); ++i) {
      var s = toSolve.get(i);
      
      pushMatrix();
      
      for(int j=0; j<4; ++j)
      {
        var info = s.lightInViews[j];
        if (info == null) { 
          translate(0,200);
          continue;
        }
        
        float x = map(info.frame + frameOffsets[j], 0,1600, 0,rowWidth);
        
        //if (activeSolve.frame == s.frame) {
        //  stroke(255);
        //  strokeWeight(2);
        //} else {
          noStroke();
        //} 
        
        
        fill(0,255,0);
        rect(x-3,map(info.pos.x, 0, 540, 0, rowHeight),6,6);
        
        fill(0,0,255);
        rect(x-3,map(info.pos.y, 0, 960, 0, rowHeight),6,6);
        
        translate(0,200);
      }
      popMatrix();
    }
  }
  
  
  
  void drawData(ArrayList<LightInfo> view, float ypos, float rowHeight, float rowWidth, int frameOffset)
  {
    pushMatrix();
    translate(0,ypos);
    stroke(255);
    line(0,rowHeight,width,rowHeight);
    
    for (int i=0; i<view.size(); ++i) {
      var   info = view.get(i);
      float x = map(info.frame + frameOffset, 0,1600, 0,rowWidth);
      
      //if(info.power < 1000) continue;
      
      stroke(255,0,0);
      //strokeWeight(2);
      line(x,rowHeight,x,rowHeight-map(info.power, 0, 100000, 0, rowHeight));
  
      noStroke();
      fill(0,255,0);
      rect(x-1,map(info.pos.x, 0, 540, 0, rowHeight),2,2);
      
      fill(0,0,255);
      rect(x-1,map(info.pos.y, 0, 960, 0, rowHeight),2,2);
    }
    popMatrix();
  }
  

}
