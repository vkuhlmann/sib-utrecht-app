import 'dart:async';

import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class CachedProvider<T> extends CachedProviderT<T, T, CacherApiConnector> {
  final FutureOr<T> Function(APIConnector) obtain;

  CachedProvider(
      {required this.obtain,
      FetchResult<T>? cache,
      required ResourcePoolBase? pool,
      required FutureOr<CacherApiConnector> connector})
      : super(
            getFresh: (c) {
              var monitor = CacheApiConnectorMonitor(c, pool: pool);

              return Future.value(obtain(monitor))
                  .then((value) => monitor.wrapResult(value));
            },
            getCached: (c) {
              if (cache != null) {
                return cache;
              }

              return foThen(c, (conn) {
                try {
                  var monitor =
                      CacheApiConnectorMonitor(conn.cache, pool: pool);

                  return foCatch(
                      foThen(obtain(monitor), (res) => monitor.wrapResult(res)),
                      (e) {
                    if (e is CacheMissException) {
                      return null;
                    }
                    throw e;
                  });

                  // Future.value().catchError(onError)
                  //  monitor.wrapResult(await obtain(monitor));
                } on CacheMissException catch (_) {
                  return null;
                }
              });
            },
            //  cache != null
            //     ? (_) => cache as FutureOr<FetchResult<T>?>
            //     : (c) async {
            //         var conn = await c;
            //         if (conn == null) {
            //           return null;
            //         }

            //         try {
            //           var monitor =
            //               CacheApiConnectorMonitor(conn.cache, pool: pool);
            //           return monitor.wrapResult(await obtain(monitor));
            //         } on CacheMissException catch (_) {
            //           return null;
            //         }
            //       },
            postProcess: (v) => v,
            connector: connector);
}
