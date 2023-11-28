import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/user.dart';

class Users {
  final APIConnector apiConnector;

  Users(this.apiConnector);

  Future<User> getUser({required String entityName}) async {
    var raw = await apiConnector.get("/users/@$entityName");

    return User.fromJson((raw["data"]["user"] as Map)
        .map<String, dynamic>((key, value) => MapEntry(key, value)));
  }

  // Future<List<Map>> listMembers({required String groupName}) async {
  //   var raw = await apiConnector.get("/groups/@$groupName/members");

  //   return (raw["data"]["memberships"] as Iterable<dynamic>)
  //       .map((e) => (e as Map<dynamic, dynamic>))
  //       // .map((e) => e["name"] as String)
  //       .toList();
  // }

  Future<List<User>> list() async {
    var raw = await apiConnector.get("/users");

    return (raw["data"]["groups"] as Iterable<dynamic>)
        .map((e) => (e as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key as String, value)))
        .map((e) => User.fromJson(e))
        .toList();
  }
}
