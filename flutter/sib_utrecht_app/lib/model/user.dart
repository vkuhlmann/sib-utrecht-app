import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/entity.dart';

class User extends Entity {
  final Map data;

  String? get entityName => data["entity_name"];
  String get shortName => (data["short_name"] ??
      data["short_name_unique"] ??
      truncateUserName(data["long_name"]) ??
      entityName);
  String get shortNameUnique => (data["short_name_unique"] ??
      data["short_name"] ??
      truncateUserName(data["long_name"]) ??
      entityName);
  String get longName => (data["long_name"] ??
      data["short_name_unique"] ??
      data["short_name"] ??
      entityName);
  User({required this.data});

  static String? truncateUserName(String? n) {
    if (n == null) {
      return null;
    }
    if (n.length > 15) {
      return "${n.substring(0, 13)}…";
    }
    return n;
  }

  static User fromJson(Map json) {
    Map vals = json;

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Group details mismatch");
        }
      }

      vals.addAll(vals["details"] as Map);
    }

    return User(data: json);
  }

  @override
  String getLocalLongName(Locale loc) {
    return longName;
  }

  @override
  String getLocalShortName(Locale loc) {
    return shortName;
  }

  @override
  String? get profilePage {
    String? name = entityName;
    if (name == null) {
      return null;
    }
    return router
        .namedLocation("user_page", pathParameters: {"entity_name": name});
  }
}
