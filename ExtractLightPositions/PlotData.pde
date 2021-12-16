
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
