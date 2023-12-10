import 'dart:async';

import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Users {
  final FutureOr<APIConnector> apiConnector;

  Users(this.apiConnector);

  Future<User> parseUser(Map data) async {
    var val = User.fromJson(data);
    var conn = await apiConnector;
    if (conn is CacheApiConnectorMonitor) {
      bool isOnlyCache = conn.base is CacheApiConnector;

      if (!isOnlyCache) {
        conn.collectUser(val);
      }
    }
    return val;
  }

  Future<User> readUser(dynamic data) async {
    var conn = await apiConnector;
    if (conn is CacheApiConnectorMonitor) {
      bool isOnlyCache = conn.base is CacheApiConnector;

      if (isOnlyCache) {
        data = (await parseUser(data)).id ?? data;
      }
    }

    if (data is String) {
      return (await getUser(entityName: data)).value;
    }
    return parseUser(data);
  }

  Future<String?> abstractUser(dynamic data) async {
    if (data is String) {
      return data;
    }
    User user = await parseUser(data);
    return user.entityName;
  }

  Future<FetchResult<T>> retrieve<T>(
      FetchResult<T>? Function(ResourcePoolBase)? fromCached,
      Future<FetchResult<T>> Function(APIConnector) fresh) async {
    var conn = await apiConnector;
    if (conn is CacheApiConnectorMonitor && fromCached != null) {
      bool isOnlyCache = conn.base is CacheApiConnector;

      FetchResult<T>? val =
          conn.attemptPoolRetrieve((pool) => fromCached(pool));
      if (val != null && (isOnlyCache || !val.isObsolete())) {
        return val;
      }

      if (isOnlyCache) {
        throw CacheMissException("Cache miss in retrieve");
      }
    }
    return fresh(conn);
  }

  Future<FetchResult<T>> retrieveSingle<T>(
          {required FetchResult<T>? Function(ResourcePoolBase)? fromCached,
          required String url,
          required FutureOr<T> Function(Map) parse}) =>
      retrieve(fromCached,
          (conn) async => (await conn.get(url)).mapValueAsync(parse));

  Future<FetchResult<User>> getUser({required String entityName}) =>
      retrieveSingle(
          fromCached: (pool) => pool.users[entityName],
          url: "/users/@$entityName",
          parse: (raw) => parseUser(raw["data"]["user"] as Map));
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

  Future<List<User>> list() async {
    var raw = await (await apiConnector).getSimple("/users");

    return Future.wait(
        (raw["data"]["groups"] as Iterable).map((v) => parseUser(v)));
  }

  Future<List<User>> listWP() async {
    var raw = await (await apiConnector).getSimple("/wp-users");

    return Future.wait((raw["data"]["wp-users"] as Iterable<dynamic>)
        .map((e) => parseUser(e)));
  }

  Future<String> getOrCreateUser({required String wpId}) async {
    if (int.tryParse(wpId) == null) {
      throw Exception("Invalid WP ID");
    }

    var raw = await (await apiConnector).post("/users?wp_id=$wpId");
    return raw["data"]["entity_name"] as String;
  }
}
