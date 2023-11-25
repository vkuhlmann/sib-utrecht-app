import 'dart:async';

abstract class APIConnector {
  // APIConnector() {
  //   Hive.init(null);
  //   boxFuture = Hive.openBox("api_cache");
  // }


  // Future<Map?> getCached(url) async {
  //   var box = await boxFuture;
  //   return box.get(url)?["response"];
  // }

  Future<Map> get(String url);
  Future<Map> post(url, {Map? body});
  Future<Map> put(url, {Map? body});
  Future<Map> delete(url, {Map? body});
}
