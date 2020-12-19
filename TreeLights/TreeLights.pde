import netP5.*;
import oscP5.*;

import java.util.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

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
    
    //color white = color(#C17542);

    time += 0.05f;
    ++pixelId;
    int totalCount = 0;
    int stripCount = min(strips.size(), 2);
    for(int stripIdx = 0; stripIdx < stripCount; ++stripIdx) {
      Strip strip = strips.get(stripIdx);      
      for (int i=0; i<strip.getLength(); ++i) {
        //if(pixelId == totalCount) 
        strip.setPixel(treeBaseColor, i);
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

float masterR, masterG, masterB;
color treeBaseColor = color(255,255,255);

void updateCol() {
  treeBaseColor = color(masterR*255, masterG*255, masterB*255);
}

void oscEvent(OscMessage msg) {
  String msgPattern = msg.addrPattern();
  println(msgPattern);
  if      (msgPattern.equals("/master/red"))   { masterR = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/green")) { masterG = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/blue"))  { masterB = msg.get(0).floatValue(); updateCol(); }
}
