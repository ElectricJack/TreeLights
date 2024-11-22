class Channel {
  String type;
  ArrayList<Event> events;

  Channel(String type) {
    this.type = type;
    events = new ArrayList<Event>();
  }

  void loadFromJSONObject(JSONObject obj) {
    this.type = obj.getString("type");
    // Load events
    JSONArray eventsArray = obj.getJSONArray("events");
    events.clear();
    if (eventsArray != null) {
      for (int i = 0; i < eventsArray.size(); i++) {
        JSONObject eventObj = eventsArray.getJSONObject(i);
        Event e = new Event(eventObj.getString("type", "default")); // Initialize event with type
        e.loadFromJSONObject(eventObj);
        events.add(e);
      }
    }
  }

  JSONObject toJSONObject() {
    JSONObject obj = new JSONObject();
    obj.setString("type", type);
    JSONArray eventsArray = new JSONArray();
    for (Event e : events) {
      JSONObject eventObj = e.toJSONObject();
      eventsArray.append(eventObj);
    }
    obj.setJSONArray("events", eventsArray);
    return obj;
  }
}
