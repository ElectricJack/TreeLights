


abstract class BaseState
{
  protected StateMachine parent;
  private   String                 name;
  private   String                 nextState;
  private   String                 defaultNextState;
  private   boolean                completed = false;
  private   TreeMap<String,String> transitions = new TreeMap<String,String>();
  
  public BaseState(String name) {
    this.name = name;
  }
  
  public void       setParent(StateMachine parent) { this.parent = parent; }
  public String     getName()                      { return name; }
  public boolean    isCompleted()                  { return completed; }
  protected void    complete()                     { completed = true; }
  public String     getNext()                      { return nextState; }
  public void       reset()                        { completed = false; nextState = defaultNextState; }
  public BaseState  then(String defaultNextState)  { nextState = this.defaultNextState = defaultNextState; return this; }
  
  public BaseState  addTransition(String transitionName, String nextStateName) { 
    transitions.put(transitionName, nextStateName);
    return this;
  }
  
  public void       trigger(String transitionName) {
    if (!transitions.containsKey(transitionName))
      return;
    
    nextState = transitions.get(transitionName);
    complete();
  }
  
  
  public void       enter()  {}
  public void       update() {}
  public void       exit()   {}
  
  
  protected boolean button(String caption, int buttonWidth, boolean enabled) {
    
    float buttonHeight = 24;
    float buttonX = screenX(0,0,0);
    float buttonY = screenY(0,0,0);
    
    boolean contained = mouseX >= buttonX && mouseX <= buttonX + buttonWidth && mouseY > buttonY && mouseY <= buttonY+buttonHeight; 
    
    if (contained && enabled) {
      if (mousePressed) fill(255);
      else fill(128);
    } else {
      fill(32);
    }
    rect(0,0,buttonWidth,buttonHeight);
    
    if (enabled) fill(255);
    else fill(64);
    
    textFont(uiFont);
    textSize(12);
    textAlign(CENTER);
    text(caption, buttonWidth/2, buttonHeight - 6);
     //<>//
    return contained && mousePressed && enabled;
  }
}


class StateMachine
{
  private TreeMap<String, BaseState> statesByName    = new TreeMap<String, BaseState>();
  private String                     nextStateName   = null;
  private BaseState                  activeState     = null;
  
  public void add(BaseState state) {
    if (statesByName.containsKey(state.getName())) {
      println("Can't add state "+state.getName()+". State name already exists.");
      return;
    }
    
    statesByName.put(state.getName(), state);
  }
  
  public void setNextState(String nextStateName) {
    this.nextStateName = nextStateName;
  }
  
  public void update() {
    if (activeState == null || nextStateName != activeState.getName()) {
      
      if (activeState != null) {
        
        nextStateName = activeState.getNext();
        println("NextStateName: "+nextStateName);
        if (nextStateName == null || !statesByName.containsKey(nextStateName)) {
          println("State '"+activeState.getName()+"' Cannot progress to next state: "+nextStateName+" does not exist!");
          return;
        }

        activeState.exit();
        activeState.reset();
      }
      
      println(nextStateName);
      println(statesByName);
      activeState = statesByName.get(nextStateName); //<>//
      activeState.enter();
    }
    
    activeState.update();
    
    if (activeState.isCompleted()) {
      nextStateName = activeState.getNext(); //<>//
    }
  }
}
