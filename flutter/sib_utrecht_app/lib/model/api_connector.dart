import 'dart:async';

import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';

abstract class APIConnector {
  Future<Map> getSimple(String url) =>
      get(url).then((res) => res.value);
  Future<Map> post(url, {Map? body});
  Future<Map> put(url, {Map? body});
  Future<Map> delete(url, {Map? body});

  Future<FetchResult<Map>> get(String url);
}
