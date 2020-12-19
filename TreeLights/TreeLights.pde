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

int pixelId = 0;
float time = 0;
void draw()
{
  if (ledObserver.hasStrips)
  {
    if (!ledInitialized) {
      registry.startPushing();
      registry.setExtraDelay(0);
      registry.setAutoThrottle(true);
      registry.setAntiLog(false);
      ledInitialized = true;
    }

    List<Strip> strips = registry.getStrips();
    

    time += 0.05f;
    ++pixelId;
    int totalCount = 0;
    int stripCount = min(strips.size(), 2);
    for(int stripIdx = 0; stripIdx < stripCount; ++stripIdx) {
      Strip strip = strips.get(stripIdx);      
      for (int i=0; i<strip.getLength(); ++i) {
        //if(pixelId == totalCount)
        
        if (random(0,1) < 0.001f)
          strip.setPixel(treeData.treeSparkleColor, i);
        else
          strip.setPixel(treeData.treeBaseColor, i);
        //else
        //  strip.setPixel(color(0,0,0), i);
        //float ang = totalCount * 0.01 + time;
        //int r = (int)(sin(ang) * 128+128);
        //int g = (int)(sin(ang*2) * 128+128);
        //int b = (int)(sin(ang*3) * 128+128);
        
        //strip.setPixel(color(r,g,b), i);
          
        ++totalCount;
      }
    }
    
    if (pixelId >= totalCount)
      pixelId = -1;
  }
}

public static class TreeData implements Serializable
{
  private static final long serialVersionUID = 1L;
  
  public int treeBaseColor;
  public int treeSparkleColor;
  public int treeColorA;
  public int treeColorB;
  public int treeColorC;
}

TreeData treeData = new TreeData();
float masterR, masterG, masterB;
int activeColorIndex = 0;

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

String fileDataPath;

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
  else if (msgPattern.equals("/fx/a/fx"))  {
    int index = (int)msg.get(0).floatValue();
    if (index <= 4) activeColorIndex = index;
  } 

}
