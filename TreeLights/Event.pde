class Event {
  int startTick;
  int endTick;
  String type;

  Event(String type) {
    startTick = 0;
    endTick = 1; // By default, a single tick
    this.type = type;
  }

  void loadFromJSONObject(JSONObject obj) {
    startTick = obj.getInt("startTick");
    endTick = obj.getInt("endTick");
    type = obj.getString("type", "default"); // default type if not provided
  }

  JSONObject toJSONObject() {
    JSONObject obj = new JSONObject();
    obj.setInt("startTick", startTick);
    obj.setInt("endTick", endTick);
    obj.setString("type", type);
    return obj;
  }
}
