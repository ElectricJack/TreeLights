import java.io.Serializable;
import java.util.ArrayList;

//todo:
// - test external .java class serialization
// - Implement pattern playback file format



public class LightStripAnimData implements Serializable
{
	private static final long serialVersionUID = 1L;

	public ArrayList<PixelAnimKey> keys = new ArrayList<PixelAnimKey>();
}
