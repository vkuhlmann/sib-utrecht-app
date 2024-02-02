import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';

class CacherApiConnector extends APIConnector {
  final APIConnector base;
  // final CacheApiConnector cache;
  final ResourcePool pool;

  CacherApiConnector({required this.base, required this.pool});

  // CacherApiConnector.fromHTTP(HTTPApiConnector this.base)
  // : pool = CacheApiConnector(channelName: base.channelName);

  @override
  Future<Map> delete(url, {body, version}) =>
      base.delete(url, version: version, body: body);

  // @override
  // Future<FetchResult<Map>> get(String url) async {
  //   var ans = await base.get(url);
  //   await cache.setGetResult(url, ans);
  //   return ans;
  // }

  @override
  Future<FetchResult<Map>> get(String url, {required version})
  => base.get(url, version: version);

  @override
  Future<Map> post(url, {Map? body, version}) =>
      base.post(url, body: body, version: version);

  @override
  Future<Map> put(url, {Map? body, version}) =>
      base.put(url, body: body, version: version);
}
