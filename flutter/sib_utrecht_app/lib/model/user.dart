import 'dart:ui';

import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/entity.dart';

class User extends Entity {
  final Map data;

  String get id => entityName ?? "wp-user-$wpId";
  
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
  String? get email => data["email"] ?? data["wp_user"]?["user_email"];
  String? get pronouns => data["pronouns"];

  String? get legalFirstName => data["legal_name"]?["first_name"];
  String? get legalLastName => data["legal_name"]?["last_name"];

  String get wpId => data["wp_id"] ?? data["wordpress_user_id"];

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
      Map details = vals["details"];
      details.remove("wp_user");

      for (var entry in details.entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          log.warning("User details mismatch: ${entry.key} != ${entry.value} on key ${entry.key}");
          log.warning("Map is $vals");

          throw Exception("User details mismatch");
        }
      }

      vals.addAll(details);
    }
    vals.remove("details");

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
