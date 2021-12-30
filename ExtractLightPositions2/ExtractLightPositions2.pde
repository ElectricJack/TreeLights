import netP5.*;
import oscP5.*;

import java.util.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

import java.io.Serializable;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.TreeMap;

import oscP5.*;
import netP5.*;

import peasy.PeasyCam;


int[]                 frameOffsets = new int[] {12,0,16,4};

OscP5         oscP5;
NetAddress    treeAddress;
PeasyCam      cam;
PFont         uiFont;
StateMachine  mainStateMachine;


void setup() {
  size(1600,800, P3D);
  
  cam     = new PeasyCam(this, 100); 
  oscP5       = new OscP5(this,12000);
  treeAddress = new NetAddress("192.168.1.122",12000);
  uiFont      = loadFont("SansSerif-48.vlw");


  mainStateMachine = new StateMachine();
  
  
  mainStateMachine.setNextState("Menu");
  mainStateMachine.add(
    new StateMenu("Menu")
    .addTransition("compute0", "FrameAnalysis0")
    .addTransition("compute1", "FrameAnalysis1")
    .addTransition("compute2", "FrameAnalysis2")
    .addTransition("compute3", "FrameAnalysis3")
    .addTransition("analyze",  "DataAnalysis")
    .addTransition("compute",  "ComputeLights")
  );
  
  mainStateMachine.add(
    new StateFrameAnalysis(
      "FrameAnalysis0",
      new PassData("view0", 26, 28, 1414, 350.0f)
    ).then("Menu")
  );
  mainStateMachine.add(
    new StateFrameAnalysis(
      "FrameAnalysis1",
      new PassData("view1", 26, 28, 1433, 350.0f)
    ).then("Menu")
  );
  mainStateMachine.add(
    new StateFrameAnalysis(
      "FrameAnalysis2",
      new PassData("view2", 50, 52, 1437, 350.0f)
    ).then("Menu")
  );
  mainStateMachine.add(
    new StateFrameAnalysis(
      "FrameAnalysis3",
      new PassData("view3", 50, 52, 1504, 350.0f)
    ).then("Menu")
  );
  
  mainStateMachine.add(
    new StateDataAnalysis("DataAnalysis").then("Menu")
  );
  
  mainStateMachine.add(
    new StateComputeLights("ComputeLights").then("Menu")
  );
  
}

void draw() {
  mainStateMachine.update();
}
