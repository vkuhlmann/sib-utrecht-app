import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/membership.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Groups {
  final APIConnector apiConnector;

  Groups(this.apiConnector);

  // Group parseGroup(Map data) {
  //   var val = Group.fromJson(data);
  //   var conn = apiConnector;
  //   if (conn is CacheApiConnectorMonitor) {
  //     conn.collectGroup(val);
  //   }
  //   return val;
  // }

  // void collectMembers(Members members) {
  //   var conn = apiConnector;
  //   if (conn is CacheApiConnectorMonitor) {
  //     bool isOnlyCache = conn.base is CacheApiConnector;

  //     if (!isOnlyCache) {
  //       conn.collectMembers(members);
  //     }
  //   }
  // }

  // Members parseMembers(Map data) {
  //   var val = Members.fromJson(data, Users(apiConnector).abstractEntity);
  //   collectMembers(val);
  //   return val;
  // }

  Future<FetchResult<Group>> getGroup({required String groupName}) => retrieve(
        conn: apiConnector,
        fromCached: (pool) => pool.groups[groupName],
        url: "/groups/@$groupName",
        parse: (res, unpacker) => unpacker.parse<Group>(res["data"]["group"]),
      );

  //  async {
  //   var raw = await apiConnector.getSimple("/groups/@$groupName");

  //   return parseGroup(raw["data"]["group"] as Map);
  // }

  Future<FetchResult<Members>> getMembers({required String groupName}) =>
      retrieve(
        conn: apiConnector,
        fromCached: (pool) => pool.members[groupName],
        url: "/groups/@$groupName/members",
        parse: (res, unpacker) => unpacker.parse<Members>({
          "group_name": groupName,
          "memberships": res["data"]["memberships"]
        }),
      );

  // Future<List<Map>> listMembers({required String groupName}) async {
  //   var raw = await apiConnector.getSimple("/groups/@$groupName/members");

  //   return (raw["data"]["memberships"] as Iterable<dynamic>)
  //       .map((e) => e as Map)
  //       .toList();
  // }

  Future<FetchResult<List<Group>>> getGroups() => retrieve(
      conn: apiConnector,
      fromCached: null,
      url: "/groups",
      parse: (res, unpacker) => (res["data"]["groups"] as Iterable)
          .map((e) => unpacker.parse<Group>(e))
          .toList());

  // Future<List<Group>> list() async {
  //   var raw = await apiConnector.getSimple("/groups");

  //   return (raw["data"]["groups"] as Iterable<dynamic>)
  //       .map((e) => parseGroup(e))
  //       .toList();
  // }

  Future<void> addMember(
      {required String groupName,
      required String userId,
      required String role}) async {
    await apiConnector.post("/groups/@$groupName/members/@$userId:$role");
  }

  Future<void> removeMember(
      {required String groupName,
      required String userId,
      required String role}) async {
    await apiConnector.delete("/groups/@$groupName/members/@$userId:$role");
  }
}
