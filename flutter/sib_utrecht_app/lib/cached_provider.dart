part of 'main.dart';

class CachedProvider<T, U> extends ChangeNotifier {
  final FutureOr<LoginState> state;

  final Future<U> Function(LoginState) getFresh;
  final Future<U> Function(Future<LoginState>) getCached;

  // final T Function(Map<String, dynamic>) func;
  final T Function(U) postProcess;

  int _validId = 0;
  (int, T)? _cached;
  late Future<T> _loading;
  // Future<T> _loading

  T? get cached => _cached?.$2;
  int get lastValidId => _validId;
  bool get isValid => _cached?.$1 == _validId;
  Future<T> get loading => _loading;


  CachedProvider({
    required this.state, required this.getFresh, required this.getCached,
    required this.postProcess
  }) {
    reset();
  }

  void reset() {
    _cached = null;
    _validId++;
    _loading = Future.value();

    notifyListeners();
  }

  Future<T> _fetchCachedResult() {
    return getCached(Future.value(state)).then(
      (value) => postProcess(value)
    );
  }

  Future<T> _fetchFreshResult() {
    return Future.value(state).then((st) => getFresh(st)).then(
      (value) => postProcess(value)
    );
  }

  Future<T> loadFresh() async {
    // int thisLoad = ++_lastValidId;
    int thisLoad = lastValidId;

    var fut = _fetchFreshResult();
    _loading = fut;//.then((value) => (thisLoad, value),);
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

  Future<void> _init() async {
    setCache(-1, await _fetchCachedResult());

    var _ = loadFresh();
  }

  void clear() {
    if (_cached == null) {
      return;
    }
    _cached = null;

    notifyListeners();
  }

  void invalidate({doRefresh = true}) {
    _validId++;

    if (doRefresh) {
      var _ = loadFresh();
    }

    notifyListeners();
  }
}
