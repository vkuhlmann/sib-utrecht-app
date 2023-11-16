
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';

class CachedProvider<T> extends CachedProviderT<T, T, CacherApiConnector> {
  final Future<T> Function(APIConnector) obtain;

  CachedProvider({
    required this.obtain
  }) : super(
    getFresh: (c) => obtain(c),
    getCached: (c) async {
      var conn = await c;
      if (conn == null) {
        return null;
      }

      try {
      return obtain(conn.cache);
      } on CacheMissException catch (_) {
        return null;
      }
    },
    postProcess: (v) => v
  );
}