part of '../../main.dart';

class Event {
  final Map<String, dynamic> data;
  final DateTime start;
  final DateTime? end;

  int get eventId => data["event_id"];
  String get eventName => data["name"];
  String get eventSlug => data["slug"];

  Event({required this.data})
  : start = DateTime.parse('${data["start"]}Z').toLocal(),
    end = data["end"] != null ? DateTime.parse('${data["end"]}Z').toLocal() : null;

  static Event fromJson(Map<String, dynamic> json) {
    var vals = json;
    vals["start"] = vals["start"] ?? vals["event_start"];
    vals["end"] = vals["end"] ?? vals["event_end"];
    vals["name"] = vals["name"] ?? vals["event_name"];
    vals["slug"] = vals["slug"] ?? vals["event_slug"];
    vals["publish_date"] = vals["publish_date"] ?? vals["post_date_gmt"];
    vals["modified"] = vals["modified"] ?? vals["post_modified_gmt"];

    // if (vals["details"] is String) {
    //   vals["details"] = jsonDecode(vals["details"]);
    // }

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Event details mismatch");
        }
        // vals[entry.key] = entry.value;
      }

      vals.addAll(vals["details"]);
    }
    // if (vals["event_id"] is String) {
    //   vals["event_id"] = int.parse(vals["event_id"]);
    // }

    if (vals["start"] == null) {
      throw Exception("Event start is null for ${vals["event_id"]}");
    }

    // log.finer("Event is $vals");

    return Event(data: json);
  }
}
