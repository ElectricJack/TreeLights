import processing.core.*;
import java.io.Serializable;

public class LightInfo implements Serializable
{
  private static final long serialVersionUID = 1L;

  public PVector pos = new PVector();
  public float   power;
  public int     frame;
}
