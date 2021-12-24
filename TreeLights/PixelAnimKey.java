import java.io.Serializable;
import java.util.ArrayList;

public class PixelAnimKey implements Serializable
{
	private static final long serialVersionUID = 1L;

	public int                      frame;
	public ArrayList<PixelColorKey> colors = new ArrayList<PixelColorKey>();
}