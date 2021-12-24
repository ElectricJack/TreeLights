import java.io.Serializable;

public class TreeData implements Serializable
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