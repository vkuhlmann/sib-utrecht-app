import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';

class CachedProvider<T> extends CachedProviderT<T, T, CacherApiConnector> {
  final Future<T> Function(APIConnector) obtain;

  CachedProvider({required this.obtain, FetchResult<T>? cache})
      : super(
            getFresh: (c) => obtain(c),
            getCached: cache != null
                ? (_) => Future.value(cache)
                : (c) async {
                    var conn = await c;
                    if (conn == null) {
                      return null;
                    }

                    try {
                      var monitor = CacheApiConnectorMonitor(conn.cache);
                      var res = await obtain(monitor);
                      DateTime? timestamp = monitor.oldestTimestamp;
                      // if (monitor.hasEncounteredNullTimestamp) {
                      //   timestamp = null;
                      // }
                      log.info("CachedProvider: timestamp is $timestamp");

                      return FetchResult<T>(res, timestamp);
                    } on CacheMissException catch (_) {
                      return null;
                    }
                  },
            postProcess: (v) => v);
}
