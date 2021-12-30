

class StateComputeLights extends StateViewSolver
{
  
  
  class SolvedLight
  {
    int     index;
    PVector position;
  }
  ArrayList<SolvedLight> solvedLights = new ArrayList<SolvedLight>();

  StateComputeLights(String name) {
    super(name);
  }
  
  void enter()  {
     super.enter(); 
     solveLightPositions();
  }
  
  void update() {
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
    
    
    int selectedLight = -1;///(int)map(mouseX, 0, width, 0, 512);
    float closestDist = 999999.0f;
    
    for (int i=0; i<solvedLights.size(); ++i) {
      var light = solvedLights.get(i);
      var x = screenX(light.position.x,light.position.y,light.position.z);
      var y = screenY(light.position.x,light.position.y,light.position.z);
      
      var diff = new PVector(mouseX-x,mouseY-y);
      var dist = diff.mag();
      if (dist < closestDist) {
        closestDist = dist;
        selectedLight = light.index;
      }
    }
    
    
    
    for (int i=0; i<solvedLights.size(); ++i) {
      var light = solvedLights.get(i);
      
      float s = 1;
      if (selectedLight == light.index ) {
        fill(255,255,255);
        s = 3;
      } else {
        fill(0,64,0);
      }
      
      pushMatrix();
        translate(light.position.x,light.position.y,light.position.z);
        box(s);
      popMatrix();
    }
    
    /* in the following different ways of creating osc messages are shown by example */
    OscMessage myMessage = new OscMessage("/select");
    
    //map(mouseX, 0, 512);
    myMessage.add(selectedLight); 
  
    /* send the message */
    oscP5.send(myMessage, treeAddress); 
  }
  
  void exit()   {}
    
  
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
}
