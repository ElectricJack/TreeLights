

void loadTreeData() { treeData = (TreeData)loadValues(treeDataPath); }
void saveTreeData() { saveValues(treeDataPath, treeData); }


void saveStripConfig() {
  List<Strip> strips = registry.getStrips();

  var stripData = new LightStripData();
  for(int i=0; i<strips.size(); ++i) {
    var strip = strips.get(i);
    stripData.stripLengths.add(strip.getLength());
  }

  saveValues(stripDataPath, stripData);
}


Object loadValues(String path)
{
  if (!new File(path).exists())
    return null;
  
  Object obj = null;
  try {
    ObjectInputStream objectInputStream = new ObjectInputStream(new BufferedInputStream(new FileInputStream(path)));
    obj = objectInputStream.readObject();
    objectInputStream.close();
  } catch( Exception e ) {}

  return obj;
}

void saveValues(String path, Object obj)
{
    try {
      ObjectOutputStream objectOutputStream = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(path)));
      objectOutputStream.writeObject(obj);
      objectOutputStream.close();
    } catch(IOException e) {
      println("Saving failed");
      println(e);
    }
}
