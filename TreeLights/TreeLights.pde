// To run at startup
// sudo nano ~/.config/lxsession/LXDE-pi/autostart
// add: /home/pi/processing-3.5.3/processing-java --sketch=/home/pi/TreeLights/TreeLights --present


import netP5.*;
import oscP5.*;


import java.util.*;
import com.heroicrobot.dropbit.registry.*;
import com.heroicrobot.dropbit.devices.pixelpusher.*;

import processing.serial.*;

import java.io.Serializable;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

// Audio playback
Minim       minim;
AudioPlayer player;
Serial      dmxSerial;


// TrackModel instance (Active track data)
TrackModel     trackModel;

// Pixel pusher -----------
DeviceRegistry registry;
LEDObserver    ledObserver;

class LEDObserver implements Observer {
  public boolean hasStrips = false;
  public void update(Observable registry, Object updatedDevice) {
    this.hasStrips = true;
  }
}

boolean  ledInitialized = false;
OscP5    oscP5          = null;
String   treeDataPath;
String   stripDataPath;



void setup()
{
  size(100,100,P3D);

  minim            = new Minim(this);  
  oscP5            = new OscP5(this,12000);
  registry         = new DeviceRegistry();

  ledObserver      = new LEDObserver();
  registry.addObserver(ledObserver);
  
  
  treeDataPath  = sketchPath("values.dat");
  stripDataPath = sketchPath("strips.dat");
  
  loadTreeData();


  // Initialize TrackModel
  trackModel = new TrackModel();

  // Set default active audio track
  trackModel.activeAudioTrack = "music/Christmas-is-coming-Long-Version.mp3";

  // Load the default audio track
  loadAudioTrack(trackModel.activeAudioTrack);


  // List all the available serial ports
  println(Serial.list());

  // Find the serial port connected to the USB interface
  String portName = findDMXSerialPort();

  if (portName != null) {
    // Open the serial port with DMX-specific settings
    dmxSerial = new Serial(this, portName, 250000, 'N', 8, 2.0);
    println("DMX serial port opened on " + portName);
  } else {
    println("DMX serial port not found.");
    //exit();
  }

  
  frameRate(60);
}

String findDMXSerialPort() {
  String[] portNames = Serial.list();
  for (String port : portNames) {
    if (port.contains("ttyUSB") || port.contains("ttyACM")) {
      return port;
    }
  }
  return null;
}

void loadAudioTrack(String trackFile) {
  if (player != null) {
    player.close();
  }
  player = minim.loadFile(sketchPath(trackFile), 2048);
  player.setGain(0.25);
  player.play();
  //player.pause();
}


float time        = 0;
int   pixelId     = 0;
int   selectedIdx = 0;

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
    List<PixelPusher> pushers = registry.getPushers();
    println("Number pushers found: "+pushers.size());
    
    List<Strip> strips = registry.getStrips();
    println("Number strips found: "+strips.size());
    
    if(strips.size() > 0) {
      println("Strip(0) length: "+strips.get(0).getLength());
    }

  }
  
  updateStrips(registry.getStrips());
  
  // Test DMX
  float panAngle = sin(time)*0.5 + 0.5;
  float tiltAngle = cos(time)*0.5 + 0.5;
  setPanTiltWashData(0, panAngle, tiltAngle, color(1,0,0));
  sendDMX();
}




void updateStrips(List<Strip> strips)
{
  time += 0.05f;
  

  int totalCount = 0;
  int stripCount = strips.size();

  
  for(int stripIdx = 0; stripIdx < stripCount; ++stripIdx) {
    Strip strip = strips.get(stripIdx);      
    for (int i=0; i<strip.getLength() && i < 50; ++i) {
      
      //calibrationBehavior(strip, i, totalCount);
      //defaultBehavior(strip, i);
      //highlightSelected(strip, i, totalCount);
      testBehavior(strip, i);

      ++totalCount;
    }
  }

  // Once started only switch pixels every 4 frames.
  if (frameCount >= startFrame && frameCount % 4 == 0)
    ++pixelId;
}

void highlightSelected(Strip strip, int i, int globalIdx)
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


void testBehavior(Strip strip, int i)
{  
  float hue = (sin(time + i / 20.0f) + 1) / 2.0;
  colorMode(HSB,1);
  color c = color(hue, 1, 1);  
  strip.setPixel(c, i);
}





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
  
  saveTreeData();
}




void oscEvent(OscMessage msg) {
  String msgPattern = msg.addrPattern();
  println(msgPattern);
  if      (msgPattern.equals("/master/red"))   { masterR = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/green")) { masterG = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/blue"))  { masterB = msg.get(0).floatValue(); updateCol(); }
  else if (msgPattern.equals("/master/level")) { treeData.brightness = msg.get(0).floatValue(); saveTreeData(); }
  else if (msgPattern.equals("/fx/a/fx"))  {
    int index = (int)msg.get(0).floatValue();
    if (index <= 4) activeColorIndex = index;
    else if (index == 17) {
      treeData.treeOn = !treeData.treeOn;
      saveTreeData();
    }
  }
  else if (msgPattern.equals("/select"))  {
    selectedIdx = (int)msg.get(0).intValue();
  }
}


void setPanTiltWashData(int startAddress, float panAngle, float tiltAngle, color lightColor) {
    // This is a very basic output of our parameters to
    //  an LIXDA pan/tilt wash in 14 channel mode.
    
    int pan = (int)(constrain(panAngle, 0,1) * 0xFFFF);
    int panHigh = (pan >> 8) & 0xFF;
    int panLow =  pan & 0xFF;
    
    int tilt = (int)(constrain(tiltAngle, 0,1) * 0xFFFF);
    int tiltHigh = (tilt >> 8) & 0xFF;
    int tiltLow =  tilt & 0xFF;

    dmxData[startAddress+0] = panHigh;
    dmxData[startAddress+1] = panLow;
    dmxData[startAddress+2] = tiltHigh;
    dmxData[startAddress+3] = tiltLow;
    
    int panTiltSpeed = 0; // 0 is the fastest, 255 the slowest
    //dmxOutput.set(startAddress+4, );
    dmxData[startAddress+4] = panTiltSpeed;
    
    
    //@TODO
    // off 0-7
    // dim 8-134
    // strobe 135-239;
    int dimStrobe = 240; 
    dmxData[startAddress+5] = dimStrobe;
    
    
    int red   = (int)red(lightColor);
    int green = (int)green(lightColor);
    int blue  = (int)blue(lightColor);
    int white = (int)((255.0f-saturation(lightColor)) * (brightness(lightColor) / 255.0));
    
    dmxData[startAddress+6] = red;
    dmxData[startAddress+7] = green; 
    dmxData[startAddress+8] = blue;
    dmxData[startAddress+9] = white;
   
    dmxData[startAddress+10] = 0; 
    dmxData[startAddress+11] = 0;
    dmxData[startAddress+12] = 0;
    dmxData[startAddress+13] = 0;
}
   

int[] dmxData = new int[512];

void sendDMX() {
  if (dmxSerial != null) {
    // Build DMX packet
    byte[] packet = new byte[dmxData.length + 1];
    packet[0] = 0; // Start code (0 for DMX)
    for (int i = 0; i < dmxData.length; i++) {
      packet[i + 1] = (byte) (dmxData[i] & 0xFF);
    }

    // Send DMX packet
    dmxSerial.write(packet);
  }
}
