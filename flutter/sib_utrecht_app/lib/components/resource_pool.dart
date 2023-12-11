
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';
import 'package:sib_utrecht_app/log.dart';

// class ResourcePool extends ResourcePoolBase {
//   Future<CacherApiConnector>? connector;
//   // EventsProvider? _eventsProvider;
//   // GroupsProvider? _groupsProvider;


//   // By event ID
//   Map<String, FetchResult<Booking>>? myBookings;

//   final ChangeNotifier myBookingsChange = ChangeNotifier();

//   // final CachedProvider<List<Event>> eventsProvider =
//   //   CachedProvider<List<Event>>(obtain: (c) => Events(c).list());

//   // final CachedProvider<Set<int>> bookingsProvider =
//   //   CachedProvider<Set<int>>(obtain: (c) => Bookings(c).getMyBookings());

//   ResourcePool() {
//     log.info("Creating ResourcePool");
//   }

//   // Future<FetchResult<User>> getUser(FetchResult<dynamic> raw) async {
//   // }

//   // EventsProvider get eventsProvider {
//   //   var val = _eventsProvider ?? EventsProvider();
//   //   var conn = connector;
//   //   if (conn != null) {
//   //     val.setApiConnector(conn);
//   //   }
//   //   _eventsProvider = val;
//   //   return val;
//   // }

//   // GroupsProvider get groupsProvider {
//   //   var val = _groupsProvider ?? GroupsProvider();
//   //   var conn = connector;
//   //   if (conn != null) {
//   //     val.setApiConnector(conn);
//   //   }
//   //   _groupsProvider = val;
//   //   return val;
//   // }

//   void setApiConnector(Future<CacherApiConnector> conn) {
//     connector = conn;
    
//     // var evProv = _eventsProvider;
//     // if (evProv != null) {
//     //   evProv.setApiConnector(conn);
//     // }
//   }

// }

class ResourcePoolAccess extends InheritedWidget {
  final ResourcePoolBase pool;

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
  late Future<ResourcePoolBase> pool;
  // Future<APIConnector>? apiConnector;

  @override
  void initState() {
    super.initState();
    pool = ResourcePoolBase.load(null);
  }

  @override
  Widget build(BuildContext context) {
    return
    FutureBuilderPatched(future: pool,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("Error loading cache: ${snapshot.error}");
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Text("Loading cache...");
      }

      var data = snapshot.data;

      if (data == null) {
        return const Text("Missing cache data");
      }

      return ResourcePoolAccess(
        pool: data,
        child: widget.child,
      );
    });
  }

  // @override
  // void didChangeDependencies() {
  //   final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
  //   if (this.apiConnector != apiConnector) {
  //     log.fine(
  //         "[Resource pool] API connector changed from ${this.apiConnector} to $apiConnector");
  //     setState(() {
  //     this.apiConnector = apiConnector;  
  //     });
  //     // _eventProvider.setConnector(apiConnector);
  //     // _participantsProvider.setConnector(apiConnector);
  //     // pool.setApiConnector(apiConnector);
  //   }

  //   super.didChangeDependencies();
  // }
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

