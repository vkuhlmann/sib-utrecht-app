import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/utils.dart';

import '../log.dart';

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
    log.info("Created CachedProvider ($T, $U, $V) with allowAutoRefresh $allowAutoRefresh");
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
      log.finest("Doing auto-refresh reload for $this");
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
      rethrow;
      // _loading = Future.error(e);
    }

    var c = cached;
    // bool needsRefresh = c?.invalidated == true
    //     || c?.timestamp?.isBefore(DateTime.now().subtract(autoRefreshThreshold)) != false;
    // log.info(
    //     "[Cache] Cached timestamp is ${c?.timestamp} (needs refresh: ${c?.isObsolete(expireTime: autoRefreshThreshold)})");

    bool needsRefresh =
      c == null || (allowAutoRefresh && c.isObsolete(expireTime: autoRefreshThreshold));
    log.info("[Cache] Needs refresh: $needsRefresh, obsolete: ${c?.isObsolete(expireTime: autoRefreshThreshold)}, "
    "c: $c, allowAutoRefresh: $allowAutoRefresh ($this)");
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
    log.info("[Cache] Reloading $this (forceRefresh: $forceRefresh)...");

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