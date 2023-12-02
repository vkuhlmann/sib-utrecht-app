import 'dart:ui';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/entity.dart';

class Group extends Entity {
  final Map<String, dynamic> data;

  String get groupName => data["name"];
  String? get title => data["title"];
  String? get titleNL => data["titleNL"] ?? data["title"];

  Group({required this.data});

  String getLocalTitle(Locale loc) {
    if (loc.languageCode == "nl") {
      return titleNL ?? groupName;
    }

    return title ?? groupName;
  }

  @override
  String getLocalShortName(Locale loc) {
    return getLocalTitle(loc);
  }

  @override
  String getLocalLongName(Locale loc) {
    return getLocalTitle(loc);
  }

  static Group fromJson(Map<String, dynamic> json) {
    var vals = json;

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Group details mismatch");
        }
      }

      vals.addAll((vals["details"] as Map)
          .map((key, value) => MapEntry(key as String, value)));
    }

    return Group(data: json);
  }
  
  @override
  String? get profilePage => router
      .namedLocation("group", pathParameters: {"group_name": groupName});
}
