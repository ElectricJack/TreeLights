// To run at startup
// sudo nano ~/.config/lxsession/LXDE-pi/autostart
// add: /home/pi/processing-3.5.3/processing-java --sketch=/home/pi/TreeLights/TreeLights --present


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


// Pixel pusher -----------
DeviceRegistry registry;
LEDObserver    ledObserver;

class LEDObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    this.hasStrips = true;
  }
}

boolean ledInitialized = false;
OscP5   oscP5 = null;

void setup()
{
  size(100,100,P3D);
  
  oscP5            = new OscP5(this,12000);
  registry         = new DeviceRegistry();
  ledObserver      = new LEDObserver();
  registry.addObserver(ledObserver);
  
  fileDataPath = sketchPath("values.dat");
  println(fileDataPath);
  loadValues();
  
  frameRate(30);
}



void draw()
{
  if (!ledObserver.hasStrips)
    return;
  
  if (!ledInitialized) {
    registry.startPushing();
    registry.setExtraDelay(0);
    registry.setAutoThrottle(true);
    registry.setAntiLog(true);
    ledInitialized = true;
  }

  updateStrips(registry.getStrips());
}


float time        = 0;
int   pixelId     = 0;
int   selectedIdx = 0;

void updateStrips(List<Strip> strips)
{
  time += 0.05f;
  

  int totalCount = 0;
  int stripCount = min(strips.size(), 2);

  
  for(int stripIdx = 0; stripIdx < stripCount; ++stripIdx) {
    Strip strip = strips.get(stripIdx);      
    for (int i=0; i<strip.getLength(); ++i) {
      
      //calibrationBehavior(strip, i, totalCount);
      //defaultBehavior(strip, i);
      highlightSelected(strip, i, totalIdx);

      ++totalCount;
    }
  }

  // Once started only switch pixels every 4 frames.
  if (frameCount >= startFrame && frameCount % 4 == 0)
    ++pixelId;
}

void highlightSelected(Strip strip, int i, globalIdx)
{
  color col = globalIdx == selectedIdx? color(255,255,255) : color(0,0,0);
  strip.setPixel(col, i);
}


int startFrame = -1;
void calibrationBehavior(Strip strip, int i, int globalIdx)
{
  
  if (frameCount % 1800 == 0) {            // Every 60 seconds (30fps * 60 = 1800)
    startFrame = frameCount + 60;          // Delay 2 seconds
    strip.setPixel(color(255,255,255), i); // Set all pixels to white
    pixelId = 0;                           // Reset the pixel ID
  }

  if (frameCount >= startFrame)
  {
    boolean clearBetween = frameCount % 4 == 0;
    if (pixelId == globalIdx && !clearBetween)
      strip.setPixel(color(255,255,255), i);
    else
      strip.setPixel(color(0,0,0), i);
  }
}

void defaultBehavior(Strip strip, int i)
{
  if (treeData.treeOn)
  {
    if (random(0,1) < 0.001f) {
      strip.setPixel(treeData.treeSparkleColor, i);
    } else {
      float b = treeData.brightness;
      color c = color(red  (treeData.treeBaseColor) * b,
                      green(treeData.treeBaseColor) * b,
                      blue (treeData.treeBaseColor) * b);
      
      strip.setPixel(c, i);
    }
  }
  else
  {
    strip.setPixel(color(0,0,0), i);
  }
}


public static class TreeData implements Serializable
{
  private static final long serialVersionUID = 1L;
  
  public int     treeBaseColor;
  public int     treeSparkleColor;
  public int     treeColorA;
  public int     treeColorB;
  public int     treeColorC;
  public float   brightness = 1.0f;
  public boolean treeOn;
}

String   fileDataPath;
TreeData treeData = new TreeData();
float    masterR, masterG, masterB;
int      activeColorIndex = 0;

void updateCol() {
  color col = color(masterR*255, masterG*255, masterB*255);
  
  if      (activeColorIndex == 0) treeData.treeBaseColor    = col;
  else if (activeColorIndex == 1) treeData.treeSparkleColor = col;
  else if (activeColorIndex == 2) treeData.treeColorA       = col;
  else if (activeColorIndex == 3) treeData.treeColorB       = col;
  else if (activeColorIndex == 4) treeData.treeColorC       = col;
  
  saveValues();
}

// Turn tree off, turn tree on
// Turn off at time, turn on at time
// Sparkle



void loadValues()
{
  if (!new File(fileDataPath).exists())
    return;
    
  try {
    ObjectInputStream objectInputStream = new ObjectInputStream(new BufferedInputStream(new FileInputStream(fileDataPath)));
    treeData = (TreeData)objectInputStream.readObject();
    objectInputStream.close();
  } catch( Exception e ) {}
}
void saveValues()
{
    try {
      ObjectOutputStream objectOutputStream = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(fileDataPath)));
      objectOutputStream.writeObject(treeData);
      objectOutputStream.close();
    } catch(IOException e) {
      println("Saving failed");
      println(e);
    }
}

void oscEvent(OscMessage msg) {
  String msgPattern = msg.addrPattern();
  println(msgPattern);
  if      (msgPattern.equals("/master/red"))   { masterR = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/green")) { masterG = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/blue"))  { masterB = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/level")) { treeData.brightness = msg.get(0).floatValue(); saveValues(); }
  else if (msgPattern.equals("/fx/a/fx"))  {
    int index = (int)msg.get(0).floatValue();
    if (index <= 4) activeColorIndex = index;
    else if (index == 17) {
      treeData.treeOn = !treeData.treeOn;
      saveValues();
    }
  }
  else if (msgPattern.equals("/select"))  {
    selectedIdx = (int)msg.get(0).intValue();
  }
}
