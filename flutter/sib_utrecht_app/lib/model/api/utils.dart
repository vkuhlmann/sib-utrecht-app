import 'dart:async';

import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/collecting_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class RetrievalRoute<T> {
  FetchResult<T>? Function(ResourcePool)? fromCached;
  String url;
  ApiVersion version;
  // Future<FetchResult<T>> Function(APIConnector) fresh;
  T Function(Map, AnchoredUnpacker) parse;

  RetrievalRoute({this.fromCached, required this.url, required this.parse,
  required this.version
  });

  Future<FetchResult<T>> getFresh(APIConnector conn) async {
    if (url.isEmpty) {
        throw Exception("Empty url");
      }

      final res = await conn.get(url, version: version);
      final unpacker = CollectingUnpacker(
          anchor: res, pool: getCollectingPoolForConnector(conn));

      return res.mapValue((p0) => parse(p0, unpacker));
  } 
}

// Future<FetchResult<T>> _retrieve<T>(
//     APIConnector conn,
//     FetchResult<T>? Function(ResourcePool)? fromCached,
//     Future<FetchResult<T>> Function(APIConnector) fresh) async {
//   // var conn = apiConnector;
//   if (conn is CacheApiConnectorMonitor && fromCached != null) {
//     bool isOnlyCache = conn.base is CacheApiConnector;

//     FetchResult<T>? val = conn.attemptPoolRetrieve((pool) => fromCached(pool));
//     if (val != null && (isOnlyCache || !val.isObsolete())) {
//       return val;
//     }

//     if (isOnlyCache) {
//       throw CacheMissException("Cache miss in retrieve");
//     }
//   }
//   return fresh(conn);
// }


RetrievalRoute<T> retrieve<T>(
  {required FetchResult<T>? Function(ResourcePool)? fromCached,
  required String url,
  required T Function(Map, AnchoredUnpacker) parse,
  ApiVersion version = ApiVersion.v1
  }) => RetrievalRoute(
    version: version,
    fromCached: fromCached,
    url: url,
    parse: parse
  );

// Future<FetchResult<T>> retrieve<T>(
    //     {required APIConnector conn,
    //     required FetchResult<T>? Function(ResourcePool)? fromCached,
    //     required String url,
    //     required T Function(Map, AnchoredUnpacker) parse}) =>
    // _retrieve(conn, fromCached, (conn) async {
    //   if (url.isEmpty) {
    //     throw Exception("Empty url");
    //   }

    //   final res = await conn.get(url);
    //   final unpacker = CollectingUnpacker(
    //       anchor: res, pool: getCollectingPoolForConnector(conn));

    //   return res.mapValue((p0) => parse(p0, unpacker));
    // }
    //     // Future.value(parse(await conn.get(url)))
    //     );

ResourcePool? getCollectingPoolForConnector(APIConnector conn) {
  if (conn is CacherApiConnector) {
    return conn.pool;
  }
  // if (conn is CacheApiConnectorMonitor) {
  //   bool isOnlyCache = conn.base is CacheApiConnector;

  //   if (!isOnlyCache) {
  //     return conn.pool;
  //   }
  // }
  // return DirectUnpacker();
  return null;
}
