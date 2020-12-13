
//import netP5.*;
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


void setup()
{
  size(100,100,P3D);
  
  registry         = new DeviceRegistry();
  ledObserver      = new LEDObserver();
  registry.addObserver(ledObserver);
  
  frameRate(30);
}

int pixelId = 0;
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
    
    color white = color(#7E4800);

    ++pixelId;
    int totalCount = 0;
    int stripCount = min(strips.size(), 2);
    for(int stripIdx = 0; stripIdx < stripCount; ++stripIdx) {
      Strip strip = strips.get(stripIdx);      
      for (int i=0; i<strip.getLength(); ++i) {
        if(pixelId == totalCount) 
          strip.setPixel(white, i);
        else
          strip.setPixel(color(0,0,0), i);
          
        ++totalCount;
      }
    }
    
    if (pixelId >= totalCount)
      pixelId = -1;
  }
}
