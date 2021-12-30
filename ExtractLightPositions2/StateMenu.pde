


class StateMenu extends BaseState
{
  
  boolean[] viewDataExists;
  
  
  public StateMenu(String name) { super(name); }
  
  public void enter() {
    
    viewDataExists = new boolean[frameOffsets.length];
    for (int i=0; i<frameOffsets.length; ++i) {
      viewDataExists[i] = new File(sketchPath("../ViewData/view"+i+".data")).exists();
    }
  }
  
  public void update() {
    background(0);
    cam.beginHUD();
    
    translate(10,10); 
    
    pushMatrix();
    boolean allDataExists = true;
    for(int i=0; i<viewDataExists.length; ++i) {
      allDataExists &= viewDataExists[i];
      String caption = viewDataExists[i]? "Recompute View"+i : "Compute View"+i;
      if (button(caption, 120, true)) {
        trigger("compute"+i);
      }
      translate(130,0);
    }
    popMatrix();
    
    translate(0,40);
    if (button("Analyze Frames", 120, allDataExists)) {
      trigger("analyze");
    }
    
    translate(0,40);
    if (button("Solve Light Positions", 120, allDataExists)) {
      trigger("compute");
    }
    
    translate(0,40);
    var lightPosDataExists = new File(lightPositionDataPath).exists();
    if (button("Export Light Animation", 120, lightPosDataExists)) {
      trigger("animate");
    }    
    
    cam.endHUD();
  }
  
  public void exit() {
  }
  


}
