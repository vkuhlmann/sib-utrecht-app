import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/utils.dart';

import '../log.dart';

@immutable
class FetchResult<T> {
  final T value;
  final DateTime? timestamp;
  final bool invalidated;

  const FetchResult(this.value, this.timestamp, {this.invalidated = false});

  FetchResult<U> mapValue<U>(U Function(T) f) {
    return FetchResult(f(value), timestamp, invalidated: invalidated);
  }

  FetchResult<U> withValue<U>(U value) {
    return mapValue((_) => value);
  }

  Future<FetchResult<U>> mapValueAsync<U>(FutureOr<U> Function(T) f) async {
    return FetchResult(await f(value), timestamp, invalidated: invalidated);
  }

  FetchResult<T> asInvalidated() {
    return FetchResult(value, timestamp, invalidated: true);
  }

  static FetchResult<void> merge(FetchResult<void> one, FetchResult<void> two) {
    DateTime? timestamp = one.timestamp;
    if (timestamp == null || two.timestamp?.isAfter(timestamp) == true) {
      timestamp = two.timestamp;
    }

    return FetchResult<void>(null, timestamp,
        invalidated: one.invalidated || two.invalidated);
  }

  static FetchResult<void> mergeMany(Iterable<FetchResult<void>> vals) {
    return vals.fold(const FetchResult<void>(null, null), (previousValue, element) => FetchResult.merge(previousValue, element));
  }

  // Future<FetchResult<T>> wait()

  bool isObsolete({Duration expireTime = const Duration(minutes: 5)}) {
    return invalidated ||
        timestamp?.isBefore(DateTime.now().subtract(expireTime)) != false;
  }

  Map toJson(dynamic Function(T) serialize) => {
        "value": serialize(value),
        "timestamp": timestamp?.toIso8601String(),
        "invalidated": invalidated
      };

  static FetchResult<T> fromJson<T>(Map json, T Function(dynamic) parse) {
    DateTime? timestamp;

    String? ts = json["timestamp"] as String?;
    if (ts != null) {
      timestamp = DateTime.parse(ts);
    }

    return FetchResult(parse(json["value"]), timestamp,
        invalidated: json["invalidated"] as bool? ?? false);
  }

  @override
  String toString() {
    return "FetchResult($value, $timestamp, $invalidated)";
  }
}

class CachedProviderT<T, U, V> extends ChangeNotifier {
  FutureOr<V> connector;

  final Future<FetchResult<U>> Function(V) getFresh;
  final FutureOr<FetchResult<U>?> Function(FutureOr<V>) getCached;

  final T Function(U) postProcess;

  int _firstValidId = 0;
  int _loadTargetId = 0;
  (int, FetchResult<T>)? _cached;
  late Future<FetchResult<T>> _loading;
  Object? _error;
  bool _isDisposed = false;

  Object? get error => _error;

  FetchResult<T>? get cached => _cached?.$2;
  int get cachedId => _cached?.$1 ?? -2;

  int get firstValidId => _firstValidId;
  int get loadTargetId => _loadTargetId;

  bool get isValid => _cached?.$1 == _firstValidId;
  Future<FetchResult<T>> get loading => _loading;

  final Duration autoRefreshThreshold;
  bool allowAutoRefresh;

  CachedProviderT(
      {required this.getFresh,
      required this.getCached,
      required this.postProcess,
      required this.connector,
      required this.allowAutoRefresh,
      this.autoRefreshThreshold = const Duration(minutes: 5)}) {
    _silentReset();
    // _loading = Future.value(reload());
    reload();
  }

  @override
  void dispose() {
    _isDisposed = true;

    _silentReset();

    super.dispose();
  }

  void _silentReset() {
    _cached = null;
    _firstValidId++;
    // _loading = Future.error(Exception("No load initiated"));
  }

  void reset() {
    _silentReset();
    notifyListeners();
  }

  void setAllowAutoRefresh(bool val) {
    if (allowAutoRefresh == val) {
      return;
    }

    allowAutoRefresh = val;
    if (allowAutoRefresh) {
      reload();
    }
  }

  FutureOr<FetchResult<T>?> _fetchCachedResult() {
    return foThen(
        connector,
        (c) => foThen(getCached(c), (v) {
              if (v == null) {
                return null;
              }
              // log.info("[Cache] mapping value $v");
              return v.mapValue(postProcess);
            }));
  }

  Future<FetchResult<T>> _fetchFreshResult() {
    return Future.value(connector)
        .then((st) => getFresh(st))
        .then((value) => value.mapValue(postProcess));
  }

  Future<FetchResult<T>> _loadFresh() async {
    // if (connector == null) {
    //   throw Exception("Cannot load fresh data: no API connector");
    // }

    // int thisLoad = ++_lastValidId;
    int thisLoad = firstValidId;

    var fut = _fetchFreshResult();
    var fut2 = fut.then((v) async {
      _error = null;
      // DateTime timestamp = DateTime.now();

      setCache(thisLoad, v);
      return v;
    }).onError<Object>((error, stackTrace) {
      // log.warning("Failed to load fresh data: $error");
      // _loading = Future.error(error, stackTrace);
      if (thisLoad != firstValidId) {
        throw e;
      }
      _error = error;
      notifyListeners();
      throw error;
    });
    _loading = fut2;

    //.then((value) => (thisLoad, value),);
    _loadTargetId = max(_loadTargetId, thisLoad);

    // var res = await fut;
    return await fut2;
  }

  void setCache(int a, FetchResult<T> val) {
    // log.info("[Cache] setCache invoked with $a, $val");

    // if (a != lastValidId) {
    //   return;
    // }
    var curCache = _cached;
    var curCacheTimestamp = curCache?.$2.timestamp;
    final isMoreRecent = curCacheTimestamp != null &&
        (val.timestamp?.isAfter(curCacheTimestamp) == true ||
            (val.timestamp == curCacheTimestamp && val.invalidated));

    if (curCache != null && !isMoreRecent && a < curCache.$1) {
      return;
    }

    var prevCached = cached;
    _cached = (a, val);

    if (_isDisposed) {
      return;
    }

    if (prevCached != cached) {
      notifyListeners();
    }
  }

  Future<void> setConnector(Future<V> conn) async {
    log.info("Setting connector on CachedProvider");
    connector = conn;

    // if (_cached == null) {
    //   await reloadCache();
    // }

    // // var _ = loadFresh();
    // var c = cached;
    // log.info("Cached timestamp is ${c?.timestamp}");

    // if (c != null &&
    //     c.timestamp?.isAfter(DateTime.now().subtract(autoRefreshThreshold)) ==
    //         true) {
    //   _loading = Future.value(c);
    //   return;
    // }

    // refresh();

    await reload();
  }

  FutureOr<FetchResult<T>> _doLoading({bool forceRefresh = false}) async {
    if (forceRefresh) {
      log.info("[Cache] Forcing refresh");
      return _loadFresh();
    }

    try {
      var attemptCache = await _fetchCachedResult();
      if (attemptCache == null) {
        log.info("[Cache] No cached result");
      }

      if (attemptCache != null) {
        setCache(-1, attemptCache);
      }
    } catch (e) {
      log.warning("[Cache] Failed to load cached result: $e");
      // _loading = Future.error(e);
    }

    var c = cached;
    // bool needsRefresh = c?.invalidated == true
    //     || c?.timestamp?.isBefore(DateTime.now().subtract(autoRefreshThreshold)) != false;
    log.info(
        "[Cache] Cached timestamp is ${c?.timestamp} (needs refresh: ${c?.isObsolete(expireTime: autoRefreshThreshold)})");

    bool needsRefresh =
        c == null || (allowAutoRefresh && c.isObsolete(expireTime: autoRefreshThreshold));
    if (needsRefresh) {
      return _loadFresh();
    }

    if (c.isObsolete(expireTime: autoRefreshThreshold)) {
      log.info("[Cache] Skipped refresh because allowAutoRefresh is false");
    }

    // _loading = Future.value(c);
    return c;
  }

  FutureOr<FetchResult<T>> reload({bool forceRefresh = false}) {
    var l = _doLoading(forceRefresh: forceRefresh);
    _loading = Future.value(l);

    notifyListeners();
    return l;
  }

  void clear() {
    if (_cached == null) {
      return;
    }
    _cached = null;

    if (_isDisposed) {
      return;
    }

    notifyListeners();
  }

  Future<FetchResult<T>> refresh() {
    _firstValidId++;
    if (_isDisposed) {
      throw Exception("Cannot refresh: provider is disposed");
    }
    return Future.value(reload(forceRefresh: true));
  }
}
