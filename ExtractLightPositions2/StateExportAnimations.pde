
class StateExportAnimations extends BaseState
{
  ArrayList<SolvedLightPos> solvedLights = new ArrayList<SolvedLightPos>();
  
  StateExportAnimations(String name) { super(name); }
  
  void enter()  {
    solvedLights = (ArrayList<SolvedLightPos>)loadValues(lightPositionDataPath);
  }
  void update() {
    background(0);
    for (int i=0; i<solvedLights.size(); ++i) {
      var light = solvedLights.get(i);
      
      float s = 2;
      fill(255,255,255);
      
      pushMatrix();
        translate(light.position.x,light.position.y,light.position.z);
        box(s);
      popMatrix();
    }
  }
  //void exit()   {}
}
