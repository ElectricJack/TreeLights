

class ThreshPoint
{
  int   x, y;
  float power;
}

void compareFrames() {
  
  var foundPoints = new ArrayList<ThreshPoint>();
  
  for(int y=0; y<height; ++y) {
    for(int x=0; x<width; ++x) {
      int   index = y * width + x;
      color b     = basis.pixels[index];
      color c     = current.pixels[index];
      
      float dr = red(c)   - red(b);
      float dg = green(c) - green(b);
      float db = blue(c)  - blue(b);
      
      var power = sqrt(dr*dr + dg*dg + db*db);
      if (power > thresholdValue) {
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
  
  var info   = new LightInfo();
  info.pos   = weightedPos;
  info.power = totalPower;
  info.frame = currentIndex - firstLightFrame;
  lights.add(info);
}
