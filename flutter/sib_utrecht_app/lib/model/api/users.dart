import 'dart:async';

import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/cacheable_list.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';

class Users {
  final APIConnector apiConnector;

  // Unpacker get unpacker => getUnpackerForConnector(apiConnector);

  Users(this.apiConnector);

  ResourcePool? get pool => getCollectingPoolForConnector(apiConnector);

  // FetchResult<User> parseUser(FetchResult<Map> data) =>
  //     unpacker.parseUser(data);
  // return unpacker.parseUser(data);
  // var val = User.fromJson(data);
  // var conn = apiConnector;
  // if (conn is CacheApiConnectorMonitor) {
  //   bool isOnlyCache = conn.base is CacheApiConnector;

  //   if (!isOnlyCache) {
  //     conn.collectUser(val);
  //   }
  // }
  // return val;
  // }

  // Future<User> readUser(dynamic data, AnchoredUnpacker unpacker) async {
  //   var conn = apiConnector;
  //   if (conn is CacheApiConnectorMonitor) {
  //     bool isOnlyCache = conn.base is CacheApiConnector;

  //     if (isOnlyCache) {
  //       data = unpacker.abstract<User>(data);
  //     }
  //   }

  //   if (data is String) {
  //     return (await getUser(entityName: data)).value;
  //   }
  //   return unpacker.parse<User>(data);
  // }


  // String abstractUser(dynamic data) {
  //   if (data is String) {
  //     return data;
  //   }
  //   User user = unpacker.parseUser(data);
  //   return user.id;
  // }

  // String abstractEntity(dynamic data) => abstractUser(data);

  RetrievalRoute<User> getUser({required String entityName}) => retrieve(
      // conn: apiConnector,
      fromCached: (pool) => pool.get<User>(entityName),
      url: "/users/@$entityName",
      parse: (res, unpacker) => unpacker.parse<User>(res["data"]["user"]));

  //  {
  //   var conn = await apiConnector;
  //   log.info("Doing getUser for $entityName");

  //   if (conn is CacheApiConnectorMonitor) {
  //     FetchResult<User>? user = conn.attemptPoolRetrieve(
  //       (pool) => pool.users[entityName]);

  //     var ts = user?.timestamp;
  //     if (user != null && ts != null && ts.isAfter(DateTime.now().subtract(const Duration(minutes: 5)))) {
  //       log.info("CacheApiConnectorMonitor: using cached user $entityName (${user.value.longName})");

  //       return user.value;
  //     }
  //   }

  //   var raw = await conn.getSimple("/users/@$entityName");

  //   return parseUser(raw["data"]["user"] as Map);
  // }

  // Future<List<User>> list() async {
  //   var raw = await apiConnector.get("/users");

  //   final unpacker = AnchoredUnpacker(anchor: raw, base: this.unpacker);

  //   return (raw.value["data"]["users"] as Iterable)
  //       .map((v) => unpacker.parse<User>(v))
  //       .toList();

  RetrievalRoute<List<User>> list() => retrieve(
      // conn: apiConnector,
      fromCached: null,
      url: "/users",
      parse: (res, unpacker) => (res["data"]["users"] as Iterable)
          .map((e) => unpacker.parse<User>(e))
          .toList());

  // final items =
  //     raw.mapValue((p0) => (p0["data"]["users"] as Iterable).toList());

  // return items.value
  //     .mapIndexed(
  //         (index, element) => items.mapValue((p0) => p0[index] as Map))
  //     .map((e) => unpacker.parse<User>(e).value)
  //     .toList();
  // (unpacker.parseUser(p0[index] as Map)).value));
  // .mapIndexed((index, element) => )
  //     .map((v) => unpacker.parseUser(v))
  //     .toList();
  // }

  RetrievalRoute<List<String>> listWP() => retrieve(
      // conn: apiConnector,
      fromCached: (p) => p.get<CacheableList<User>>("wp-users"),
      url: "/wp-users",
      parse: (res, unpacker) => 
      unpacker.parse<CacheableList<User>>({
        "id": "wp-users",
        "data": res["data"]["wp-users"],
      }));
      // (res["data"]["wp-users"] as Iterable)
      //     .map((e) => unpacker.parse<User>(e))
      //     .toList());

  // Future<List<User>> listWP() async {
  //   var raw = await apiConnector.get("/wp-users");

  //   final unpacker = AnchoredUnpacker(anchor: raw, base: this.unpacker);

  //   return (raw.value["data"]["wp-users"] as Iterable)
  //       .map((v) => unpacker.parse<User>(v))
  //       .toList();

  //   // final items =
  //   //     raw.mapValue((p0) => (p0["data"]["wp-users"] as Iterable).toList());

  //   // return items.value
  //   //     .mapIndexed(
  //   //         (index, element) => items.mapValue((p0) => p0[index] as Map))
  //   //     .map((e) => unpacker.parse<User>(e).value)
  //   //     .toList();

  //   // return (raw["data"]["wp-users"] as Iterable<dynamic>)
  //   //     .map((e) => parseUser(e))
  //   //     .toList();
  // }

  Future<String> getOrCreateUser({required String wpId}) async {
    if (int.tryParse(wpId) == null) {
      throw Exception("Invalid WP ID");
    }

    var raw = await apiConnector.post("/users?wp_id=$wpId");

    pool?.invalidateId<CacheableList<User>>("wp-users");
    return raw["data"]["entity_name"] as String;
  }

  Future<Map> updateUser({required String id, required Map data}) async {
      final ans = await apiConnector.put("/users/@$id", body: data);

      pool?.invalidateId<User>(id);
      return ans;
  }
}
