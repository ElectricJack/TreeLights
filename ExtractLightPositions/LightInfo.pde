
public static class LightInfo implements Serializable
{
  private static final long serialVersionUID = 1L;

  public PVector pos = new PVector();
  public float   power;
  public int     frame;
}


class SolveLight {
  int         frame;
  int         nonNullCount = 0;
  LightInfo[] lightInViews = new LightInfo[4];
}

void saveValues()
{
    try {
      ObjectOutputStream objectOutputStream = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(fileDataPath)));
      objectOutputStream.writeObject(lights);
      objectOutputStream.close();
    } catch(IOException e) {
      println("Saving failed");
      println(e);
    }
}


ArrayList<LightInfo> loadValues(String fileDataPath)
{
  ArrayList<LightInfo> info = null;
  if (!new File(fileDataPath).exists())
    return info;
    
  try {
    ObjectInputStream objectInputStream = new ObjectInputStream(new BufferedInputStream(new FileInputStream(fileDataPath)));
    info = (ArrayList<LightInfo>)objectInputStream.readObject();
    objectInputStream.close();
  } catch( Exception e ) {
    println(e);
  }
  
  return info;
}
