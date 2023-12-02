import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/group.dart';

class Groups {
  final APIConnector apiConnector;

  Groups(this.apiConnector);

  Future<Group> getGroup({required String groupName}) async {
    var raw = await apiConnector.get("/groups/@$groupName");

    return Group.fromJson((raw["data"]["group"] as Map)
        .map<String, dynamic>((key, value) => MapEntry(key, value)));
  }

  Future<List<Map>> listMembers({required String groupName}) async {
    var raw = await apiConnector.get("/groups/@$groupName/members");

    return (raw["data"]["memberships"] as Iterable<dynamic>)
        .map((e) => (e as Map<dynamic, dynamic>))
        .toList();
  }

  Future<List<Group>> list() async {
    var raw = await apiConnector.get("/groups");

    return (raw["data"]["groups"] as Iterable<dynamic>)
        .map((e) => (e as Map<dynamic, dynamic>)
            .map((key, value) => MapEntry(key as String, value)))
        .map((e) => Group.fromJson(e))
        .toList();
  }
}
