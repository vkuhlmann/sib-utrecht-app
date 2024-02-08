import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/resource_pool_access.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/load_stability.dart';

// class MultiplexedProvider<T, U> extends StatelessWidget {
//   final List<T> query;
//   final Future<U> Function(T, APIConnector) obtain;
//   final Listenable Function(ResourcePoolBase)? changeListener;

//   final Widget Function(BuildContext context, List<U> data) builder;
//   final String Function(AppLocalizations) errorTitle;

//   const MultiplexedProvider(
//       {Key? key,
//       required this.query,
//       required this.obtain,
//       required this.builder,
//       required this.errorTitle,
//       this.changeListener})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     var pool = ResourcePoolAccess.maybeOf(context)?.pool;

//     Listenable? listenable;
//     final changeListener = this.changeListener;

//     if (pool != null && changeListener != null) {
//       listenable = changeListener(pool);
//     }

//     if (listenable != null) {
//       return ListenableBuilder(
//           listenable: listenable,
//           builder: (context, _) => MultiplexedProviderInt(
//               // key: UniqueKey(),
//               query: query,
//               obtain: obtain,
//               builder: builder,
//               errorTitle: errorTitle));
//     }

//     return MultiplexedProviderInt(
//         query: query, obtain: obtain, builder: builder, errorTitle: errorTitle);
//   }
// }

class MultiplexedProvider<T, U> extends StatefulWidget {
  final List<T> query;
  // final CachedProvider<U> Function(T)? obtainProvider;
  // final FutureOr<FetchResult<U>> Function(T, APIConnector) obtain;
  final RetrievalRoute<U> Function(T, APIConnector) obtain;

  // final Listenable Function(ResourcePoolBase)? changeListener;

  final Widget Function(BuildContext context, List<FetchResult<U>> data)
      builder;
  final String Function(AppLocalizations) errorTitle;
  // final Widget Function(BuildContext context, Future<U> data)? loadingBuilder;

  // final Listenable Function(ResourcePool)? changeListener;

  const MultiplexedProvider(
      {Key? key,
      required this.query,
      required this.obtain,
      required this.builder,
      required this.errorTitle
      })
      : super(key: key);

  @override
  State<MultiplexedProvider<T, U>> createState() =>
      _MultiplexedProviderState<T, U>();
}

class _MultiplexedProviderState<T, U> extends State<MultiplexedProvider<T, U>> {
  // Future<CacherApiConnector>? apiConnector;
  // Future<ResourcePoolBase>? pool;

  late List<CachedProvider<U>> data;
  List<CachedProvider<U>>? loadingData;

  Listenable? activeListener;
  DateTime? lastUpdateInitiation;
  bool needsUpdate = false;

  // ResourcePool? pool;
  Future<CacherApiConnector>? apiConnector;

  @override
  void dispose() {
    var oldList = activeListener;
    if (oldList != null) {
      oldList.removeListener(onPoolUpdate);
    }
    activeListener = null;

    for (var element in [...data]) {
      element.dispose();
      // data.remove(element);
      loadingData?.remove(element);
    }
    data.clear();

    for (CachedProvider<U> element in [...(loadingData ?? [])]) {
      element.dispose();
    }
    loadingData?.clear();

    loadingData = null;

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    log.fine("[Provider] didChangeDependencies for $widget with query ${widget.query}");

    var oldList = activeListener;
    if (oldList != null) {
      oldList.removeListener(onPoolUpdate);
    }
    activeListener = null;

    final access = APIAccess.maybeOf(context);

    // var newPool = ResourcePoolAccess.maybeOf(context)?.pool;
    var newConnector = access?.connector;

    if (
      // newPool != this.pool || 
      newConnector != apiConnector) {
      // this.pool = newPool;
      apiConnector = newConnector;

      data = initData();
    }

    // var changeList = widget.changeListener;

    final pool = access?.pool;
    // if (pool != null && changeList != null) {
    //   var listener = changeList(pool);
    //   listener.addListener(updateData);
    //   activeListener = listener;
    // }

    if (pool != null) {
      final listener = pool;
      listener.addListener(onPoolUpdate);
      activeListener = listener;
    }

    updateAllowAutoRefresh();

    log.fine("[Provider] needsUpdate: $needsUpdate");

    if (needsUpdate) {
      updateData();
    }

    // var conn = APIAccess.of(context).connector;
    // apiConnector = conn;
    // setState(() {
    //   for (var element in data) {
    //     element.setConnector(conn);
    //   }
    // });
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

  void onPoolUpdate() {
    log.info("[Provider] onPoolUpdate for $widget with query ${widget.query}");

    needsUpdate = true;
    var prevStability = LoadStability.maybeOf(context);
    if (prevStability == null || !prevStability.isRoot || prevStability.isLoading) {
      return;
    }

    updateData();
  }

  void updateData() {
    log.info("[Provider] updateData for $widget with query ${widget.query}");

    if (!mounted) {
      log.fine("[Provider] updateData: not mounted");
      return;
    }

    var loadingData = this.loadingData;
    for (CachedProvider<U> element in loadingData ?? []) {
      element.reload();
    }

    for (var element in data) {
      element.reload();
    }

    if (!mounted) {
      return;
    }
      
    setState(() {
      lastUpdateInitiation = DateTime.now();
      needsUpdate = false;
    });
  }

  void updateAllowAutoRefresh() {
    var allowAutoRefresh = getAllowAutoRefresh();
    for (CachedProvider<U> element in loadingData ?? []) {
      element.setAllowAutoRefresh(allowAutoRefresh);
    }

    for (var element in data) {
      element.setAllowAutoRefresh(allowAutoRefresh);
    }
  }

  bool getAllowAutoRefresh() {
    if (!mounted) {
      log.info("[Provider] LoadStability: autorefresh disallowed: not mounted");
      return false;
    }

    final state = LoadStability.maybeOf(context);
    if (state == null) {
      log.info("[Provider] LoadStability: autorefresh disallowed: parent not found");
      return false;
    }

    if (state.isLoading) {
      log.info("[Provider] LoadStability: autorefresh disallowed: parent is loading");
      return false;
    }

    log.info("[Provider] LoadStability: autorefresh allowed");
    return true;
  }

  List<CachedProvider<U>> initData() {
    if (!mounted) {
      return [];
    }

    log.info("[Provider] initData for $widget with query ${widget.query}");

    var pool = APIAccess.of(context).pool;
    var conn = APIAccess.of(context).connector;

    bool allowAutoRefresh = getAllowAutoRefresh();

    var newData = widget.query
        .map((v) => CachedProvider(
              allowAutoRefresh: allowAutoRefresh,
              obtain: (c) => widget.obtain(v, c),
              pool: pool,
              connector: conn,
            ))
        .toList();

    // for (var element in newData) {
    //   element.setConnector(conn);
    // }

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

  Widget buildError(BuildContext context, Object? error) => Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                child: ListTile(
                    title: Row(children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                              widget.errorTitle(AppLocalizations.of(context)!),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis))
                    ]),
                    subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 8, 8, 8),
                        child: formatError(error))),
              ))));

  static Widget buildLoginPrompt(BuildContext context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        FilledButton(
            onPressed: () {
              GoRouter.of(context).go("/login?immediate=true");
            },
            style: (Theme.of(context).filledButtonTheme.style ??
                    FilledButton.styleFrom())
                .copyWith(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)))),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Log in",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ))))
      ]));

  Widget buildInProgress(BuildContext context, AsyncSnapshot<void> snapshot) =>
      Center(
          child: FutureBuilderPatched(
              future: APIAccess.of(context).connector,
              builder: (context, connectorSnapshot) {
                var data = connectorSnapshot.data;
                if (data != null &&
                    data.base is HTTPApiConnector &&
                    (data.base as HTTPApiConnector).user == null) {
                  return buildLoginPrompt(context);
                }

                if (snapshot.hasError) {
                  return buildError(context, snapshot.error);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()));
                }

                return const Text('Data missing');
              }));

  @override
  Widget build(BuildContext context) {
    var prevStability = LoadStability.maybeOf(context);

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
            triggerRefresh: (DateTime invalidationTime) async {
              DateTime dt = DateTime.now();

              for (var element in data) {
                // await element.reload();

                DateTime? ct;
                try {
                  ct = (await element.loading).timestamp;
                } catch (e) {
                  ct = null;
                }

                if (!(ct?.isBefore(invalidationTime) ?? true)) {
                  continue;
                }

                dt = [dt, (await element.refresh()).timestamp]
                    .whereNotNull()
                    .min;
              }

              return dt;
            },
            child: FutureBuilderPatched(
              future: Future.wait(data.map((e) => e.loading)),
              builder: (context, snapshot) {
                var cachedVals = data.map((e) => e.cached).toList();
                // log.info("[Provider] cachedVals.length: ${cachedVals.length}");

                if (cachedVals.contains(null)) {
                  // log.info("[Provider] cached contains null");

                  return buildInProgress(context, snapshot);
                }

                if (snapshot.hasError) {
                  return buildError(context, snapshot.error);
                }

                log.info("[Provider] building child for $widget with query ${widget.query}");

                final isLoading =
                    snapshot.connectionState == ConnectionState.active ||
                        snapshot.connectionState == ConnectionState.waiting;

                return LoadStability.combine(
                    prev: prevStability,
                    isThisLoading: isLoading,
                    lastUpdateInitiation: lastUpdateInitiation,
                    anchors: snapshot.data ?? [],
                    isRoot: false,
                    child: widget.builder(
                        context, cachedVals.whereNotNull().toList()));
              },
            )));
  }
}
