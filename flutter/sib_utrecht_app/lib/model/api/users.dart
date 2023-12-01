import 'dart:async';

import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/user.dart';

class Users {
  final FutureOr<APIConnector> apiConnector;

  Users(this.apiConnector);

  Future<User> getUser({required String entityName}) async {
    var raw = await (await apiConnector).get("/users/@$entityName");

    return User.fromJson(raw["data"]["user"] as Map);
        // .map<String, dynamic>((key, value) => MapEntry(key, value)));
  }

  // Future<List<Map>> listMembers({required String groupName}) async {
  //   var raw = await apiConnector.get("/groups/@$groupName/members");

  //   return (raw["data"]["memberships"] as Iterable<dynamic>)
  //       .map((e) => (e as Map<dynamic, dynamic>))
  //       // .map((e) => e["name"] as String)
  //       .toList();
  // }

  Future<List<User>> list() async {
    var raw = await (await apiConnector).get("/users");

    return (raw["data"]["groups"] as Iterable<dynamic>)
        .map((e) => (e as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key as String, value)))
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<List<Map>> listWP() async {
    var raw = await (await apiConnector).get("/wp-users");

    return (raw["data"]["wp-users"] as Iterable<dynamic>)
        .map((e) => (e as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key as String, value)))
        // .map((e) => User.fromJson(e))
        .toList();
  }

  Future<String> getOrCreateUser({required String wpId}) async {
    if (int.tryParse(wpId) == null) {
      throw Exception("Invalid WP ID");
    }

    var raw = await (await apiConnector).post("/users?wp_id=$wpId");
    return raw["data"]["entity_name"] as String;
  }
}
