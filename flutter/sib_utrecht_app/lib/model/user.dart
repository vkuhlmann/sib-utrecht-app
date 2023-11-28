import 'package:sib_utrecht_app/model/entity.dart';

class User extends Entity {
  final Map<String, dynamic> data;

  String get entityName => data["entity_name"];
  String get shortName => (
    data["short_name"]
    ?? data["short_name_unique"]
    ?? data["long_name"]
    ?? entityName
  );
  String get shortNameUnique => (
    data["short_name_unique"]
    ?? data["short_name"]
    ?? data["long_name"]
    ?? entityName
  );
  String get longName => (
    data["long_name"]
    ?? data["short_name_unique"]
    ?? data["short_name"]
    ?? entityName
  );
  // String? get titleNL => data["titleNL"] ?? data["title"];
  User({required this.data});

  // String? getLocalTitle(Locale loc) {
  //   if (loc.languageCode == "nl") {
  //     return titleNL;
  //   }

  //   return title;
  // }

  // String getLocalEventName(BuildContext context) {
  //   return getLocalEventNameFromLoc(Localizations.localeOf(context));
  // }

  static User fromJson(Map<String, dynamic> json) {
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

    return User(data: json);
  }
}
