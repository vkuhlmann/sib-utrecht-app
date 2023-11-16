import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:hive/hive.dart';

class CacheMissException implements Exception {
  final String message;

  CacheMissException(this.message);

  @override
  String toString() {
    return message;
  }
}

class CacheApiConnector extends APIConnector {
  late Future<Box<dynamic>> boxFuture;
  String? channelName;

  CacheApiConnector({this.channelName}) {
    Hive.init(null);
    boxFuture = Hive.openBox("api_cache");
  }

  @override
  Future<Map> delete(url, {Map? body}) {
    throw CacheMissException("No caching available for DELETE operations");
  }

  @override
  Future<Map> get(String url) async {
    var box = await boxFuture;
    Map? res = box.get(url)?["response"];

    if (res == null) {
      throw CacheMissException("Cache miss for $url");
    }

    return res;
  }

  String getKeyName(String url) {
    if (channelName == null) {
      return url;
    }

    return "$channelName:$url";
  }

  Future<void> setGetResult(String url, Map ans) async {
    var box = await boxFuture;
    box.put(url, {
      "response": ans,
      "time": DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<Map> post(url, {Map? body}) {
    throw CacheMissException("No caching available for POST operations");
  }

  @override
  Future<Map> put(url, {Map? body}) {
    throw CacheMissException("No caching available for PUT operations");
  }
}
