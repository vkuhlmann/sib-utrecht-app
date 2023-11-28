import 'dart:ui';

import 'package:sib_utrecht_app/model/entity.dart';

class Group extends Entity {
  final Map<String, dynamic> data;

  // int get eventId => data["event_id"];
  String get groupName => data["name"];
  String? get title => data["title"];
  String? get titleNL => data["titleNL"] ?? data["title"];
  // String get eventSlug => data["slug"];

  // String get signupType {
  //   var signupType = data["signup"]?["type"];
  //   if (signupType == null && data["signup"]?["url"] != null) {
  //     signupType = "url";
  //   }

  //   if (data["event_rsvp"] == 0) {
  //     signupType = "none";
  //   }

  //   signupType = signupType ?? "api";

  //   return signupType;
  // }
  
  Group({required this.data});

  String? getLocalTitle(Locale loc) {
    if (loc.languageCode == "nl") {
      return titleNL;
    }

    return title;
  }

  // String getLocalEventName(BuildContext context) {
  //   return getLocalEventNameFromLoc(Localizations.localeOf(context));
  // }

  static Group fromJson(Map<String, dynamic> json) {
    var vals = json;
    // vals["start"] = vals["start"] ?? vals["event_start"];
    // vals["end"] = vals["end"] ?? vals["event_end"];
    // vals["name"] = vals["name"] ?? vals["event_name"];
    // vals["slug"] = vals["slug"] ?? vals["event_slug"];
    // vals["publish_date"] = vals["publish_date"] ?? vals["post_date_gmt"];
    // vals["modified"] = vals["modified"] ?? vals["post_modified_gmt"];

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Group details mismatch");
        }
      }

      vals.addAll(
        (vals["details"] as Map).map((key, value)
        => MapEntry(key as String, value))
      );
    }
    // if (vals["start"] == null) {
    //   throw Exception("Event start is null for event ${vals["event_id"]}");
    // }

    return Group(data: json);
  }
}
