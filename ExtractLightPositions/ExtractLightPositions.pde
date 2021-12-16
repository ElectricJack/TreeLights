import java.io.Serializable;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.TreeMap;


import peasy.PeasyCam;


PeasyCam cam;


String viewName           = "view0";
int    basisFrame         = 26;
int    firstLightFrame    = 28;
int    frameSequenceCount = 1414;
float  thresholdValue     = 350.0;


//String viewName           = "view1";
//int    basisFrame         = 26;
//int    firstLightFrame    = 28;
//int    frameSequenceCount = 1433;
//float  thresholdValue     = 350.0;


//String viewName           = "view2";
//int    basisFrame         = 50;
//int    firstLightFrame    = 52;
//int    frameSequenceCount = 1437;
//float  thresholdValue     = 350.0;


//String viewName           = "view3";
//int    basisFrame         = 50;
//int    firstLightFrame    = 52;
//int    frameSequenceCount = 1504;
//float  thresholdValue     = 350.0;



PImage basis;
PImage current;
int    currentIndex;
String fileDataPath;



ArrayList<LightInfo>                   lights      = new ArrayList<LightInfo>();
ArrayList<ArrayList<LightInfo>>        views       = new ArrayList<ArrayList<LightInfo>>();
ArrayList<TreeMap<Integer, LightInfo>> viewByFrame = new ArrayList<TreeMap<Integer, LightInfo>>();
PVector[]                              viewPos     = new PVector[4];


int[] frameOffsets = new int[] {12,0,16,4};
ArrayList<SolveLight> toSolve = new ArrayList<SolveLight>();

void setup()
{
  size(1600,800, P3D);
  
  cam = new PeasyCam(this, 100);
    
  // Load and init all values
  for(int i=0; i<4; ++i) {
    var view = loadValues(sketchPath("../ViewData/view"+i+".data"));
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
  
  
  /*
  for(int i=0; i<toSolve.size(); ++i) {
    var frame = toSolve.get(i);
    if (frame.nonNullCount <= 1)
      continue;
     
    println("=====================================\nFrame: " + frame.frame);
    printDiff(frame, 0, 1);
    printDiff(frame, 0, 2);
    printDiff(frame, 0, 3);
    printDiff(frame, 1, 2);
    printDiff(frame, 1, 3);
    printDiff(frame, 2, 3);
  }*/
 
  
  // Tree base at 0,0,0
  // Camera height 60"
  // Camera 21 degree h-fov. 37.3 v-fov
  // View 0 distance 150"
  // View 1 distance 156" + angle 19
  // View 2 distance 162" + angle 19+13.5
  // View 3 distance 180" + angle 19+13.5+9.7

  
  float a0 = 19*PI/180.0f;
  float a1 = (19+13.5)*PI/180.0f;
  float a2 = (19+13.5+9.7)*PI/180.0f;
  
  viewPos[0] = new PVector(150,60,0);
  viewPos[1] = new PVector(156*cos(a0),60,156*sin(a0));
  viewPos[2] = new PVector(162*cos(a1),60,162*sin(a1));
  viewPos[3] = new PVector(180*cos(a2),60,180*sin(a2));
  
  solveLightPositions();
}


/*
PVector cameraRay(PVector cameraPos, PVector lightPos)
{
  var from = cameraPos.get();
  from.mult(-1);
  
  var rotMatrix = new PMatrix3D();
  rotMatrix.rotateX(21 / 2.0f);
}*/

class SolvedLight
{
  int     index;
  PVector position;
}
ArrayList<SolvedLight> solvedLights = new ArrayList<SolvedLight>();

void solveLightPositions()
{
  var points     = new ArrayList<PVector>();
  var directions = new ArrayList<PVector>();

  for(int j=0; j<toSolve.size(); ++j) {
    var activeSolve = toSolve.get(j);
    if (activeSolve.nonNullCount < 2) continue;
    
    points.clear();
    directions.clear();
    
    for (int i=0; i<4; ++i) {
            
      if (activeSolve.lightInViews[i] == null)
        continue;
        
      
      var from  = viewPos[i].copy();
      from.y = 0;
      
      var to    = from.mult(-1).normalize();
      var up    = new PVector(0,1,0);
      var right = to.cross(up).normalize();
      
      up = to.cross(right).normalize();
      
      pushMatrix();
        applyMatrix(
          right.x, right.y, right.z, viewPos[i].x,
          up.x,    up.y,    up.z,    viewPos[i].y,
          to.x,    to.y,    to.z,    viewPos[i].z,
          0,       0,       0,       1
        );
        
        var x = 54/2 - activeSolve.lightInViews[i].pos.x/10.0f;
        var y = -98/2 + activeSolve.lightInViews[i].pos.y/10.0f;
        
        var r = new PVector(x, y, 140);
        r.normalize();
        r.mult(200);
              
        var wTo = new PVector(
          modelX(r.x,r.y,r.z),
          modelY(r.x,r.y,r.z),
          modelZ(r.x,r.y,r.z)
        );
      popMatrix();
          
      points.add(viewPos[i].copy());
      var dir = new PVector(wTo.x - viewPos[i].x, wTo.y - viewPos[i].y, wTo.z - viewPos[i].z);
      dir.normalize();
      directions.add(dir);
    }
    
    var newLight = new SolvedLight();
    newLight.index = (int)(activeSolve.frame / 4);
    newLight.position = findNearestPoint(
      points.toArray(new PVector[points.size()]), 
      directions.toArray(new PVector[directions.size()])
    );
    solvedLights.add(newLight);
    
  }
  
  println("Total found lights: " + solvedLights.size());
}

void draw()
{
  background(0);
  
  noStroke();
  fill(255);
  pushMatrix();
    translate(0,12*7/2,0);
    scale(4,12*7,4);
    box(1);
  popMatrix();
  
  
  stroke(128);
  for (int i=1; i<solvedLights.size(); ++i) {
    var s0 = solvedLights.get(i-1);
    var s1 = solvedLights.get(i);
    line(
      s0.position.x, s0.position.y, s0.position.z,
      s1.position.x, s1.position.y, s1.position.z
    );
  }
  
  
  
  fill(0,255,0);
  for (int i=0; i<solvedLights.size(); ++i) {
    var light = solvedLights.get(i);
    pushMatrix();
      translate(light.position.x,light.position.y,light.position.z);
      box(1);
    popMatrix();
  }
}


/*
SolveLight activeSolve;

void draw()
{
  int n = (int)map(mouseX,0,width,0,100);
  for(int i=0; i<toSolve.size(); ++i) {
    activeSolve = toSolve.get(i);
    if (activeSolve.nonNullCount == 4) {
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
  
  for (int i=0; i<4; ++i) {
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
*/


//void printDiff(SolveLight s, int i0, int i1) {
//  var v0 = s.lightInViews[i0];
//  var v1 = s.lightInViews[i1];
//  if(v0 == null || v1 == null)
//    return;
  
//  var dx = v1.pos.x - v0.pos.x;
//  var dy = v1.pos.y - v0.pos.y;
  
//  println("["+i0+" -> "+i1+"] dx: " + dx + " dy: " + dy);
//}


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





/*

void setup()
{
  size(540, 960);
  
  fileDataPath = sketchPath(viewName + ".data");
  basis = loadFrame(viewName, basisFrame);
  
  currentIndex = firstLightFrame;
  loadCurrentFrame();
  compareFrames();
}

void draw()
{
  background(0);
  image(current,0,0);
  
  for(int i=0; i<lights.size(); ++i) {
    var lightPos = lights.get(i);
    noStroke();
    fill(255);
    ellipse(lightPos.pos.x, lightPos.pos.y, 5,5);
  }
  
  // Process the current frame
  if(currentIndex < frameSequenceCount) { 
    ++currentIndex;
    loadCurrentFrame();
    compareFrames();
  } else if(currentIndex == frameSequenceCount) { // Done, save out the data
    saveValues();
    ++currentIndex;
  }
}
*/




void loadCurrentFrame()
{
  current = loadFrame(viewName, currentIndex);
}

PImage loadFrame(String folder, int frame)
{
  String inputFilename = sketchPath("../ViewData/" + folder + "/" + "frame" + nf(frame, 6) + ".png");
  var img = loadImage(inputFilename);
  img.loadPixels();
  return img; 
}
