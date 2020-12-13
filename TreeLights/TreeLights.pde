
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

void draw()
{
  if (ledObserver.hasStrips)
  {
    if (!ledInitialized) {
      registry.startPushing();
      registry.setExtraDelay(0);
      registry.setAutoThrottle(true);
      registry.setAntiLog(true);
      ledInitialized = true;
    }

    List<Strip> strips = registry.getStrips();
    
    color white = color(#FFDFAA);

    for(int stripIdx = 0; stripIdx < strips.size(); ++stripIdx) {
      Strip strip = strips.get(stripIdx);      
      for (int i=0; i<strip.getLength(); ++i) {
        strip.setPixel(white, i);
      }
    }
  }
}
