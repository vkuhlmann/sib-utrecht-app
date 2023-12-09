import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../log.dart';

class FetchResult<T> {
  final T value;
  final DateTime? timestamp;

  FetchResult(this.value, this.timestamp);

  FetchResult<U> mapValue<U>(U Function(T) f) {
    return FetchResult(f(value), timestamp);
  }
}

class CachedProviderT<T, U, V> extends ChangeNotifier {
  Future<V>? connector;

  final Future<U> Function(V) getFresh;
  final Future<FetchResult<U>?> Function(Future<V?>) getCached;

  final T Function(U) postProcess;

  int _firstValidId = 0;
  int _loadTargetId = 0;
  (int, FetchResult<T>)? _cached;
  late Future<FetchResult<T>> _loading;
  Object? _error;

  Object? get error => _error;

  FetchResult<T>? get cached => _cached?.$2;
  int get cachedId => _cached?.$1 ?? -2;

  int get firstValidId => _firstValidId;
  int get loadTargetId => _loadTargetId;

  bool get isValid => _cached?.$1 == _firstValidId;
  Future<FetchResult<T>> get loading => _loading;

  final Duration autoRefreshThreshold;

  CachedProviderT(
      {required this.getFresh,
      required this.getCached,
      required this.postProcess,
      this.autoRefreshThreshold = const Duration(minutes: 5)}) {
    _silentReset();
  }

  void _silentReset() {
    _cached = null;
    _firstValidId++;
    _loading = Future.error(Exception("No load initiated"));
  }

  void reset() {
    _silentReset();
    notifyListeners();
  }

  Future<FetchResult<T>?> _fetchCachedResult() {
    return getCached(Future.value(connector)).then((value) {
      if (value == null) {
        return Future.value(null);
      }
      return value.mapValue(postProcess);
    });
  }

  Future<T> _fetchFreshResult() {
    return connector!
        .then((st) => getFresh(st))
        .then((value) => postProcess(value));
  }

  Future<T> loadFresh() async {
    if (connector == null) {
      throw Exception("Cannot load fresh data: no API connector");
    }

    // int thisLoad = ++_lastValidId;
    int thisLoad = firstValidId;

    var fut = _fetchFreshResult();
    _loading = fut.then((v) async {
      _error = null;
      DateTime timestamp = DateTime.now();

      setCache(thisLoad, FetchResult(v, timestamp));
      return FetchResult(v, timestamp);
    }).onError<Object>((error, stackTrace) {
      // log.warning("Failed to load fresh data: $error");
      // _loading = Future.error(error, stackTrace);
      _error = error;
      notifyListeners();
      throw error;
    });

    //.then((value) => (thisLoad, value),);
    _loadTargetId = max(_loadTargetId, thisLoad);
    notifyListeners();

    var res = await fut;
    return res;
  }

  void setCache(int a, FetchResult<T> val) {
    // if (a != lastValidId) {
    //   return;
    // }

    var curCache = _cached;

    if (curCache != null && a < curCache.$1) {
      return;
    }

    var prevCached = cached;
    _cached = (a, val);

    if (prevCached != cached) {
      notifyListeners();
    }
  }

  Future<void> setConnector(Future<V> conn) async {
    log.info("Setting connector on CachedProvider");
    connector = conn;

    if (_cached == null) {
      try {
        var attemptCache = await _fetchCachedResult();
        if (attemptCache != null) {
          setCache(-1, attemptCache);
        }
      } catch (e) {
        log.warning("Failed to load cached result: $e");
        _loading = Future.error(e);
      }
    }

    // var _ = loadFresh();
    var c = cached;
    log.info("Cached timestamp is ${c?.timestamp}");

    if (c != null &&
        c.timestamp?.isAfter(DateTime.now().subtract(autoRefreshThreshold)) ==
            true) {
      _loading = Future.value(c);
      return;
    }

    invalidate();
  }

  void clear() {
    if (_cached == null) {
      return;
    }
    _cached = null;

    notifyListeners();
  }

  void invalidate({doRefresh = true}) {
    _firstValidId++;

    if (doRefresh) {
      var _ = loadFresh();
    }

    notifyListeners();
  }
}
