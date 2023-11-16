
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/view_model/events_provider.dart';
import 'package:sib_utrecht_app/log.dart';

class ResourcePool {
  Future<CacherApiConnector>? connector;
  EventsProvider? _eventsProvider;

  EventsProvider get eventsProvider {
    var val = _eventsProvider ?? EventsProvider();
    var conn = connector;
    if (conn != null) {
      val.setApiConnector(conn);
    }
    _eventsProvider = val;
    return val;
  }

  void setApiConnector(Future<CacherApiConnector> conn) {
    connector = conn;
    
    var evProv = _eventsProvider;
    if (evProv != null) {
      evProv.setApiConnector(conn);
    }
  }

  ResourcePool() {
    log.info("Creating ResourcePool");
  }
}

class ResourcePoolAccess extends InheritedWidget {
  final ResourcePool pool;

  const ResourcePoolAccess({Key? key, required Widget child, required this.pool})
      : super(key: key, child: child);

  static ResourcePoolAccess? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ResourcePoolAccess>();
  }

  static ResourcePoolAccess of(BuildContext context) {
    final ResourcePoolAccess? result = maybeOf(context);
    assert(result != null, 'No ResourcePoolAccess found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ResourcePoolAccess oldWidget) => pool != oldWidget.pool;
}

class ResourcePoolProvider extends StatefulWidget {
  final Widget child;

  const ResourcePoolProvider({Key? key, required this.child})
      : super(key: key);

  @override
  State<ResourcePoolProvider> createState() => _ResourcePoolProviderState();
}

class _ResourcePoolProviderState extends State<ResourcePoolProvider> {
  late ResourcePool pool;
  Future<APIConnector>? apiConnector;

  @override
  void initState() {
    super.initState();
    pool = ResourcePool();
  }

  @override
  Widget build(BuildContext context) {
    return ResourcePoolAccess(
      pool: pool,
      child: widget.child,
    );
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      log.fine(
          "[Resource pool] API connector changed from ${this.apiConnector} to $apiConnector");
      setState(() {
      this.apiConnector = apiConnector;  
      });
      // _eventProvider.setConnector(apiConnector);
      // _participantsProvider.setConnector(apiConnector);
      pool.setApiConnector(apiConnector);
    }

    super.didChangeDependencies();
  }
}

// class ResourcePoolProvider extends StatelessWidget {
//   final ResourcePool pool;
//   final Widget child;

//   ResourcePoolProvider({Key? key, required this.child})
//       : pool = ResourcePool(), super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ResourcePoolAccess(
//       pool: pool,
//       child: child,
//     );
//   }

//   @override
//   void didChangeDependencies() {
//     final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
//     if (this.apiConnector != apiConnector) {
//       log.fine(
//           "[EventPage] API connector changed from ${this.apiConnector} to $apiConnector");
//       this.apiConnector = apiConnector;
//       _eventProvider.setConnector(apiConnector);
//       _participantsProvider.setConnector(apiConnector);
//       var a = widget.eventsCalendarList;

//       if (a != null) {
//         a.setApiConnector(apiConnector);
//       }
//     }

//     super.didChangeDependencies();
//   }
// }

