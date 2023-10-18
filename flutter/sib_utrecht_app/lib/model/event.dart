import 'package:flutter/material.dart';

class Event {
  final Map<String, dynamic> data;
  final DateTime start;
  final DateTime? end;
  final String? location;

  int get eventId => data["event_id"];
  String get eventName => data["name"];
  String get eventNameNL => data["nameNL"] ?? data["name"];
  String get eventSlug => data["slug"];

  String get signupType {
    var signupType = data["signup"]?["type"];
    if (signupType == null && data["signup"]?["url"] != null) {
      signupType = "url";
    }

    if (data["event_rsvp"] == 0) {
      signupType = "none";
    }

    signupType = signupType ?? "api";

    return signupType;
  }
  
  Event({required this.data})
  : start = DateTime.parse('${data["start"]}Z').toLocal(),
    end = data["end"] != null ? DateTime.parse('${data["end"]}Z').toLocal() : null,
    location = data["location"];

  String getLocalEventNameFromLoc(Locale loc) {
    if (loc.languageCode == "nl") {
      return eventNameNL;
    }

    return eventName;
  }

  String getLocalEventName(BuildContext context) {
    return getLocalEventNameFromLoc(Localizations.localeOf(context));
  }

  static Event fromJson(Map<String, dynamic> json) {
    var vals = json;
    vals["start"] = vals["start"] ?? vals["event_start"];
    vals["end"] = vals["end"] ?? vals["event_end"];
    vals["name"] = vals["name"] ?? vals["event_name"];
    vals["slug"] = vals["slug"] ?? vals["event_slug"];
    vals["publish_date"] = vals["publish_date"] ?? vals["post_date_gmt"];
    vals["modified"] = vals["modified"] ?? vals["post_modified_gmt"];

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Event details mismatch");
        }
      }

      vals.addAll(
        (vals["details"] as Map).map((key, value)
        => MapEntry(key as String, value))
      );
    }
    if (vals["start"] == null) {
      throw Exception("Event start is null for event ${vals["event_id"]}");
    }

    return Event(data: json);
  }
}
