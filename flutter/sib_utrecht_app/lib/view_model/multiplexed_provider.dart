import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MultiplexedProvider<T, U> extends StatelessWidget {
  final List<T> query;
  final Future<U> Function(T, APIConnector) obtain;
  final Listenable Function(ResourcePoolBase)? changeListener;

  final Widget Function(BuildContext context, List<U> data) builder;
  final String Function(AppLocalizations) errorTitle;

  const MultiplexedProvider(
      {Key? key,
      required this.query,
      required this.obtain,
      required this.builder,
      required this.errorTitle,
      this.changeListener
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pool = ResourcePoolAccess.maybeOf(context)?.pool;

    Listenable? listenable;
    final changeListener = this.changeListener;

    if (pool != null && changeListener != null) {
      listenable = changeListener(pool);
    }

    if (listenable != null) {
      return ListenableBuilder(listenable: listenable, builder: (context, _) 
        => MultiplexedProviderInt(
          key: UniqueKey(),
          query: query, obtain: obtain, builder: builder, errorTitle: errorTitle)
      );
    }

    return MultiplexedProviderInt(query: query, obtain: obtain, builder: builder, errorTitle: errorTitle);
  }
}


class MultiplexedProviderInt<T, U> extends StatefulWidget {
  final List<T> query;
  // final CachedProvider<U> Function(T)? obtainProvider;
  final Future<U> Function(T, APIConnector) obtain;
  // final Listenable Function(ResourcePoolBase)? changeListener;

  final Widget Function(BuildContext context, List<U> data) builder;
  final String Function(AppLocalizations) errorTitle;
  // final Widget Function(BuildContext context, Future<U> data)? loadingBuilder;

  const MultiplexedProviderInt(
      {Key? key,
      required this.query,
      // this.obtainProvider,
      required this.obtain,
      required this.builder,
      required this.errorTitle,
      // this.changeListener
      })
      : super(key: key);

  @override
  State<MultiplexedProviderInt<T, U>> createState() =>
      _MultiplexedProviderIntState<T, U>();
}

class _MultiplexedProviderIntState<T, U> extends State<MultiplexedProviderInt<T, U>> {
  // Future<CacherApiConnector>? apiConnector;
  // Future<ResourcePoolBase>? pool;

  late List<CachedProvider<U>> data;
  List<CachedProvider<U>>? loadingData;

  // Listenable? activeListener;

  @override
  void dispose() {
    super.dispose();

    // var oldList = activeListener;
    // if (oldList != null) {
    //   oldList.removeListener(initData);
    // }
    // activeListener = null;

    for (var element in data) {
      element.dispose();
    }

    for (CachedProvider<U> element in loadingData ?? []) {
      element.dispose();
    }

    loadingData = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // var oldList = activeListener;
    // if (oldList != null) {
    //   oldList.removeListener(initData);
    // }
    // activeListener = null;
    
    // var pool = ResourcePoolAccess.maybeOf(context)?.pool;
    // var changeList = widget.changeListener;
    // if (pool != null && changeList != null) {
    //   var listener = changeList(pool);
    //   listener.addListener(initData);
    //   activeListener = listener;
    // }

    data = initData();

    // var conn = APIAccess.of(context).connector;
    // apiConnector = conn;
    // setState(() {
    //   for (var element in data) {
    //     element.setConnector(conn);
    //   }
    // });
  }

  @override
  void didUpdateWidget(MultiplexedProviderInt<T, U> oldWidget) {
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
    if (!mounted) {
      return [];
    }

    var pool = ResourcePoolAccess.maybeOf(context)?.pool;
    var conn = APIAccess.of(context).connector;

    var newData = widget.query.map((v) => 
    CachedProvider(
      obtain: (c) => widget.obtain(v, c),
      pool: pool,
    )).toList();

    for (var element in newData) {
      element.setConnector(conn);
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
                  return Center(
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Card(
                                child: ListTile(
                                    title: Row(
                                        children: [
                                          const Icon(Icons.error,
                                              color: Colors.red),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  widget.errorTitle(
                                                      AppLocalizations.of(
                                                          context)!),
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis))
                                        ]),
                                    subtitle: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            32, 8, 8, 8),
                                        child: formatError(snapshot.error))),
                              ))));
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
