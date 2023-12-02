import 'dart:async';

abstract class APIConnector {
  Future<Map> get(String url);
  Future<Map> post(url, {Map? body});
  Future<Map> put(url, {Map? body});
  Future<Map> delete(url, {Map? body});
}
