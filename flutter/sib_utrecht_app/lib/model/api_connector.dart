import 'dart:async';

import 'package:sib_utrecht_app/model/fetch_result.dart';

enum ApiVersion {
  // static const String v1 = "v1";
  // static const String v2 = "v2";
  v1, v2
}

abstract class APIConnector {
  Future<Map> getSimple(String url, {required ApiVersion version}) =>
      get(url, version: version).then((res) => res.value);
  Future<Map> post(String url, {ApiVersion? version, Map? body});
  Future<Map> put(String url, {ApiVersion? version, Map? body});
  Future<Map> delete(String url, {ApiVersion? version, Map? body});

  Future<FetchResult<Map>> get(String url, {required ApiVersion version});
}
