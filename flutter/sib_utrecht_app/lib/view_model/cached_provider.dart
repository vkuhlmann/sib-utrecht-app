import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class CachedProvider<T> extends CachedProviderT<T, T, CacherApiConnector> {
  final Future<T> Function(APIConnector) obtain;

  CachedProvider(
      {required this.obtain,
      FetchResult<T>? cache,
      required ResourcePoolBase? pool})
      : super(
            getFresh: (c) => obtain(CacheApiConnectorMonitor(c, pool: pool)),
            getCached: cache != null
                ? (_) => Future.value(cache)
                : (c) async {
                    var conn = await c;
                    if (conn == null) {
                      return null;
                    }

                    try {
                      var monitor =
                          CacheApiConnectorMonitor(conn.cache, pool: pool);
                      return monitor.wrapResult(await obtain(monitor));
                    } on CacheMissException catch (_) {
                      return null;
                    }
                  },
            postProcess: (v) => v);
}
