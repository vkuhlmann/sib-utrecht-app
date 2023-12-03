import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache.dart';

class CacheApiConnectorMonitor extends APIConnector {
  final CacheApiConnector base;
  bool hasEncounteredNullTimestamp = false;

  DateTime? oldestTimestamp;

  CacheApiConnectorMonitor(this.base);

  @override
  Future<Map> delete(url, {Map? body}) => base.delete(url, body: body);

  @override
  Future<Map> get(String url) async {
    var res = await base.getWithFetchResult(url);
    var ts = res.timestamp;
    log.info("CacheApiConnectorMonitor: timestamp for $url is $ts");

    if (ts == null) {
      hasEncounteredNullTimestamp = true;
    }
    if (ts != null && oldestTimestamp?.isAfter(ts) != false) {
      oldestTimestamp = ts;
    }

    return res.value;
  }

  @override
  Future<Map> post(url, {Map? body}) => base.post(url, body: body);

  @override
  Future<Map> put(url, {Map? body}) => base.put(url, body: body);
}
