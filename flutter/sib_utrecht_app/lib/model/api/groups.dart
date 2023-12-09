import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/group.dart';

class Groups {
  final APIConnector apiConnector;

  Groups(this.apiConnector);

  Group parseGroup(Map data) {
    var val = Group.fromJson(data);
    var conn = apiConnector;
    if (conn is CacheApiConnectorMonitor) {
      conn.collectGroup(val);
    }
    return val;
  }

  Future<Group> getGroup({required String groupName}) async {
    var raw = await apiConnector.getSimple("/groups/@$groupName");

    return parseGroup(raw["data"]["group"] as Map);
  }

  Future<List<Map>> listMembers({required String groupName}) async {
    var raw = await apiConnector.getSimple("/groups/@$groupName/members");

    return (raw["data"]["memberships"] as Iterable<dynamic>)
        .map((e) => e as Map)
        .toList();
  }

  Future<List<Group>> list() async {
    var raw = await apiConnector.getSimple("/groups");

    return (raw["data"]["groups"] as Iterable<dynamic>)
        .map((e) => parseGroup(e))
        .toList();
  }
}
