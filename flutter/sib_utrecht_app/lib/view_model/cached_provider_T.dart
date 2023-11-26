import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../log.dart';

class CachedProviderT<T, U, V> extends ChangeNotifier {
  Future<V>? connector;

  final Future<U> Function(V) getFresh;
  final Future<U?> Function(Future<V?>) getCached;

  final T Function(U) postProcess;

  int _firstValidId = 0;
  int _loadTargetId = 0;
  (int, T)? _cached;
  late Future<T> _loading;

  T? get cached => _cached?.$2;
  int get cachedId => _cached?.$1 ?? -2;

  int get firstValidId => _firstValidId;
  int get loadTargetId => _loadTargetId;

  bool get isValid => _cached?.$1 == _firstValidId;
  Future<T> get loading => _loading;


  CachedProviderT({
    // required this.connector, 
    required this.getFresh, required this.getCached,
    required this.postProcess
  }) {
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

  Future<T?> _fetchCachedResult() {
    return getCached(Future.value(connector)).then(
      (value) {
        if (value == null) {
          return Future.value(null);
        }
        return postProcess(value);
      }
    );
  }

  Future<T> _fetchFreshResult() {
    return connector!.then((st) => getFresh(st)).then(
      (value) => postProcess(value)
    );
  }

  Future<T> loadFresh() async {
    if (connector == null) {
      throw Exception("Cannot load fresh data: no API connector");
    }

    // int thisLoad = ++_lastValidId;
    int thisLoad = firstValidId;

    var fut = _fetchFreshResult();
    _loading = fut;//.then((value) => (thisLoad, value),);
    _loadTargetId = max(_loadTargetId, thisLoad);
    notifyListeners();

    var res = await fut;
    setCache(thisLoad, res);

    return res;
  }

  void setCache(int a, T val) {
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
      try{
        var attemptCache = await _fetchCachedResult();
          if (attemptCache != null) {
            setCache(-1, attemptCache);
        }
      }catch(e){
        log.warning("Failed to load cached result: $e");
        _loading = Future.error(e);
      }
    }

    // var _ = loadFresh();
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
