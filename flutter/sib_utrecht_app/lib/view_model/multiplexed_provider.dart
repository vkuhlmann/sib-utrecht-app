import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';

class MultiplexedProvider<T, U> extends StatefulWidget {
  final List<T> query;
  final CachedProvider<U> Function(T) obtainProvider;
  final Widget Function(BuildContext context, List<U> data) builder;
  // final Widget Function(BuildContext context, Future<U> data)? loadingBuilder;

  const MultiplexedProvider(
      {Key? key,
      required this.query,
      required this.obtainProvider,
      required this.builder})
      : super(key: key);

  @override
  State<MultiplexedProvider<T, U>> createState() =>
      _MultiplexedProviderState<T, U>();
}

class _MultiplexedProviderState<T, U> extends State<MultiplexedProvider<T, U>> {
  Future<CacherApiConnector>? apiConnector;
  late List<CachedProvider<U>> data;
  List<CachedProvider<U>>? loadingData;

  @override
  void initState() {
    super.initState();

    data = initData();
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in data) {
      element.dispose();
    }

    for (var element in loadingData ?? []) {
      element.dispose();
    }

    loadingData = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var conn = APIAccess.of(context).connector;
    apiConnector = conn;
    setState(() {
      for (var element in data) {
        element.setConnector(conn);
      }
    });
  }

  @override
  void didUpdateWidget(MultiplexedProvider<T, U> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // var conn = apiConnector;

    // if (conn != null) {
    //   for (var element in users) {
    //     element.setConnector(conn);
    //   }
    // }

    if (!listEquals(widget.query, oldWidget.query)) {
      log.info(
          "[Provider] query changed from ${oldWidget.query} to ${widget.query}");
      initData();
    }
  }

  List<CachedProvider<U>> initData() {
    var newData = widget.query.map(widget.obtainProvider).toList();

    var conn = apiConnector;
    if (conn != null) {
      for (var element in newData) {
        element.setConnector(conn);
      }
    }

    loadingData = newData;
    Future.wait(newData.map((e) => e.loading)).whenComplete(() {
      if (mounted && loadingData == newData) {
        setState(() {
          data = newData;
          loadingData = null;
        });
      }
    });

    return newData;
    // setState(() {
    //   // apiConnector = ResourcePoolAccess.of(context).pool.connector;
    //   users = newUsers;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge(data),
        builder: (context, _) => ActionEmitter(
            refreshFuture: Future.wait(data.map((e) => e.loading)).then(
                (value) =>
                    value
                        .map((a) => a.timestamp)
                        .toList()
                        .whereNotNull()
                        .minOrNull ??
                    DateTime.now()),
            triggerRefresh: () {
              for (var element in data) {
                element.invalidate();
              }
            },
            child: FutureBuilderPatched(
              future: Future.wait(data.map((e) => e.loading)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return formatError(snapshot.error);
                }

                var cachedVals = data.map((e) => e.cached).toList();
                log.info("[Provider] cachedVals.length: ${cachedVals.length}");

                if (cachedVals.contains(null)) {
                  log.info("[Provider] cached contains null");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const Center(child: Text('Data missing'));
                }

                return widget.builder(context,
                    cachedVals.whereNotNull().map((v) => v.value).toList());
              },
            )));
  }
}
