// TrackModel class (Model)
class TrackModel {
  // Data structures
  ArrayList<Channel> channels;
  String             activeAudioTrack;
  JSONObject         trackData;

  // Variables for measure window (in seconds)
  float measureStartTimeSec;
  float measureEndTimeSec;

  // Constructor
  TrackModel() {
    channels = new ArrayList<Channel>();
    measureStartTimeSec = 0;
    measureEndTimeSec = 10;
  }

  void loadTrackData(String trackName) {
    // Load track data from disk
    String path = dataPath(trackName + ".json");
    trackData = loadJSONObject(path);

    // Load measure window positions
    if (trackData != null) {
      measureStartTimeSec = trackData.getFloat("measureStartTimeSec", 0);
      measureEndTimeSec = trackData.getFloat("measureEndTimeSec", 10);

      // Load channels
      JSONArray channelsArray = trackData.getJSONArray("channels");
      channels.clear();
      if (channelsArray != null) {
        for (int i = 0; i < channelsArray.size(); i++) {
          JSONObject channelObj = channelsArray.getJSONObject(i);
          String type = channelObj.getString("type");
          Channel channel = new Channel(type);
          channel.loadFromJSONObject(channelObj);
          channels.add(channel);
        }
      }
    } else {
      // No data, set defaults
      measureStartTimeSec = 0;
      measureEndTimeSec = 10;
      channels.clear();
    }
  }

  void saveTrackData() {
    if (trackData == null) {
      trackData = new JSONObject();
    }

    // Save measure window positions
    trackData.setFloat("measureStartTimeSec", measureStartTimeSec);
    trackData.setFloat("measureEndTimeSec", measureEndTimeSec);

    // Save channels
    JSONArray channelsArray = new JSONArray();
    for (Channel channel : channels) {
      JSONObject channelObj = channel.toJSONObject();
      channelsArray.append(channelObj);
    }
    trackData.setJSONArray("channels", channelsArray);

    // Save to disk
    String path = dataPath(activeAudioTrack + ".json");
    saveJSONObject(trackData, path);
  }
}
