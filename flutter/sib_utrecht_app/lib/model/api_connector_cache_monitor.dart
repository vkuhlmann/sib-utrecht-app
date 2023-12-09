import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';

class CacheApiConnectorMonitor extends APIConnector {
  final APIConnector base;
  final ResourcePoolBase? pool;

  bool hasEncounteredNullTimestamp = false;
  DateTime? oldestTimestamp;
  DateTime? get freshnessTimestamp => oldestTimestamp;

  FetchResult<T> wrapResult<T>(T val) {
    return FetchResult(val, freshnessTimestamp);
  }

  CacheApiConnectorMonitor(this.base, {required this.pool});

  void _impactTimestamp(DateTime? ts) {
if (ts == null) {
      hasEncounteredNullTimestamp = true;
    }
    if (ts != null && oldestTimestamp?.isAfter(ts) != false) {
      oldestTimestamp = ts;
    }
  }

  @override
  Future<Map> delete(url, {Map? body}) => base.delete(url, body: body);

  @override
  Future<FetchResult<Map>> get(String url) async {
    var res = await base.get(url);
    _impactTimestamp(res.timestamp);
    log.info("CacheApiConnectorMonitor: timestamp for $url is ${res.timestamp}");
    return res;
  }

  @override
  Future<Map> post(url, {Map? body}) => base.post(url, body: body);

  @override
  Future<Map> put(url, {Map? body}) => base.put(url, body: body);

  FetchResult<T>? attemptPoolRetrieve<T>(
      FetchResult<T>? Function(ResourcePoolBase pool) obtain) {
    var p = pool;
    if (p == null) {
      return null;
    }

    if (base is! CacheApiConnector) {
      return null;
    }

    var result = obtain(p);
    if (result == null) {
      return null;
    }

    _impactTimestamp(result.timestamp);
    return result;
  }

  void collectEvent(Event data) {
    pool?.events.collect(data.id, wrapResult(data));
  }

  void collectGroup(Group data) {
    pool?.groups.collect(data.id, wrapResult(data));
  }

  void collectUser(User data) {
    pool?.users.collect(data.id, wrapResult(data));
  }
}
