import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/log.dart';
// import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/api/entities.dart';
import 'package:sib_utrecht_app/model/entity.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';

// import '../constants.dart';

class EntityProvider extends StatefulWidget {
  final List<String> entityNames;
  final Widget Function(BuildContext context, List<Entity> entities) builder;

  const EntityProvider(
      {Key? key, required this.entityNames, required this.builder})
      : super(key: key);

  @override
  State<EntityProvider> createState() => _EntityProviderState();
}

class _EntityProviderState extends State<EntityProvider> {
  Future<CacherApiConnector>? apiConnector;
  late List<CachedProvider<Entity>> entities;
  List<CachedProvider<Entity>>? loadingEntities;

  @override
  void initState() {
    super.initState();

    entities = initEntities();
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in entities) {
      element.dispose();
    }

    if (loadingEntities != null) {
      for (var element in loadingEntities!) {
        element.dispose();
      }
    }

    loadingEntities = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var conn = APIAccess.of(context).connector;
    apiConnector = conn;
    setState(() {
      for (var element in entities) {
        element.setConnector(conn);
      }
    });
  }

  @override
  void didUpdateWidget(EntityProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // var conn = apiConnector;

    // if (conn != null) {
    //   for (var element in entities) {
    //     element.setConnector(conn);
    //   }
    // }

    if (!listEquals(widget.entityNames, oldWidget.entityNames)) {
      log.info("[EntityProvider] entityNames changed from ${oldWidget.entityNames} to ${widget.entityNames}");
      initEntities();
    }
  }

  List<CachedProvider<Entity>> initEntities() {
    var newEntities = widget.entityNames
        .map((e) => CachedProvider<Entity>(
              obtain: (c) => Entities(c).getEntity(entityName: e),
            ))
        .toList();

    var conn = apiConnector;
    if (conn != null) {
      for (var element in newEntities) {
        element.setConnector(conn);
      }
    }

    loadingEntities = newEntities;
    Future.wait(newEntities.map((e) => e.loading)).whenComplete(() {
      if (mounted && loadingEntities == newEntities) {
        setState(() {
          entities = newEntities;
          loadingEntities = null;
        });
      }
    });

    return newEntities;
    // setState(() {
    //   // apiConnector = ResourcePoolAccess.of(context).pool.connector;
    //   entities = newEntities;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // return Text("Test");

    return ListenableBuilder(
        listenable: Listenable.merge(entities),
        builder: (context, _) => FutureBuilderPatched(
              future: Future.wait(entities.map((e) => e.loading)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return formatError(snapshot.error);
                }

                var cachedVals = entities.map((e) => e.cached).toList();
                log.info("[EntityProvider] cachedVals.length: ${cachedVals.length}");

                if (cachedVals.contains(null)) {
                  log.info("[EntityProvider] cached contains null");
                  
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const Center(child: Text('Data missing'));
                }

                return widget.builder(
                    context, cachedVals.map((v) => v!).toList());
              },
            ));
  }
}
