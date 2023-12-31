
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
  Future<Map> delete(url, {Map? body}) => base.delete(url, body: body);
  
  // @override
  // Future<FetchResult<Map>> get(String url) async {
  //   var ans = await base.get(url);
  //   await cache.setGetResult(url, ans);
  //   return ans;
  // }

  @override
  Future<FetchResult<Map>> get(String url) => base.get(url);
  
  @override
  Future<Map> post(url, {Map? body}) => base.post(url, body: body);
  
  @override
  Future<Map> put(url, {Map? body}) => base.put(url, body: body);
}

