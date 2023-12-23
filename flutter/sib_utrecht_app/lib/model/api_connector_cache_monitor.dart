import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class CacheApiConnectorMonitor extends APIConnector {
  final APIConnector base;
  // final ResourcePool? pool;

  bool isInvalidated = false;
  bool hasEncounteredNullTimestamp = false;
  DateTime? oldestTimestamp;
  DateTime? get freshnessTimestamp => oldestTimestamp;

  FetchResult<T> wrapResult<T>(T val) {
    // log.info("[Cache] monitor, wrapping result $val, "
    // "freshness: $freshnessTimestamp, invalidated: $isInvalidated");
    return FetchResult(val, freshnessTimestamp, invalidated: isInvalidated);
  }

  CacheApiConnectorMonitor(this.base);
  //, {required this.pool});

  void _impactTimestamp(DateTime? ts, bool invalidated) {
    if (ts == null) {
      hasEncounteredNullTimestamp = true;
    }
    if (ts != null && oldestTimestamp?.isAfter(ts) != false) {
      oldestTimestamp = ts;
    }

    if (invalidated) {
      isInvalidated = true;
    }
  }

  @override
  Future<Map> delete(url, {Map? body}) => base.delete(url, body: body);

  @override
  Future<FetchResult<Map>> get(String url) async {
    var res = await base.get(url);
    _impactTimestamp(res.timestamp, res.invalidated);
    log.info(
        "CacheApiConnectorMonitor: timestamp for $url is ${res.timestamp}");
    return res;
  }

  @override
  Future<Map> post(url, {Map? body}) => base.post(url, body: body);

  @override
  Future<Map> put(url, {Map? body}) => base.put(url, body: body);

  FetchResult<T>? attemptPoolRetrieve<T>(
      FetchResult<T>? Function(ResourcePool pool) obtain) {
    // var p = pool;
    // if (p == null) {
    //   return null;
    // }

    final base = this.base;

    if (base is! CacherApiConnector) {
      return null;
    }

    var result = obtain(base.pool);
    if (result == null) {
      return null;
    }

    _impactTimestamp(result.timestamp, result.invalidated);
    return result;
  }

  // void collectEvent(Event data) {
  //   pool?.events.collect(data.id, wrapResult(data));
  // }

  // void collectGroup(Group data) {
  //   pool?.groups.collect(data.id, wrapResult(data));
  // }

  // void collectUser(User data) {
  //   pool?.users.collect(data.id, wrapResult(data));
  // }

  // void collectMembers(Members data) {
  //   pool?.members.collect(data.id, wrapResult(data));
  // }
}
