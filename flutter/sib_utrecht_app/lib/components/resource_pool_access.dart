import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/login_state.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/log.dart';

// class ResourcePoolAccess extends InheritedWidget {
//   final ResourcePool pool;

//   const ResourcePoolAccess({Key? key, required Widget child, required this.pool})
//       : super(key: key, child: child);

//   static ResourcePoolAccess? maybeOf(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<ResourcePoolAccess>();
//   }

//   static ResourcePoolAccess of(BuildContext context) {
//     final ResourcePoolAccess? result = maybeOf(context);
//     assert(result != null, 'No ResourcePoolAccess found in context');
//     return result!;
//   }

//   @override
//   bool updateShouldNotify(ResourcePoolAccess oldWidget) => pool != oldWidget.pool;
// }

class ResourcePoolProvider extends StatefulWidget {
  final Widget child;
  final Future<LoginState> state;
  final String? channelName;

  const ResourcePoolProvider(
      {Key? key,
      required this.child,
      required this.state,
      required this.channelName})
      : super(key: key);

  @override
  State<ResourcePoolProvider> createState() => _ResourcePoolProviderState();
}

class _ResourcePoolProviderState extends State<ResourcePoolProvider> {
  late Future<ResourcePool> pool;
  // Future<APIConnector>? apiConnector;
  late Future<CacherApiConnector> conn;

  @override
  void initState() {
    super.initState();
    reset();
  }

  static Future<CacherApiConnector> getConnector(
      Future<ResourcePool> pool, Future<LoginState> state) async {
    final c = (await state).connector;
    final p = await pool;

    return CacherApiConnector(base: c, pool: p);
  }

  void reset() {
    setState(() {
      pool = ResourcePool.load(widget.channelName);
      conn = getConnector(pool, widget.state);
    });
  }

  @override
  void didUpdateWidget(ResourcePoolProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.channelName != oldWidget.channelName ||
        widget.state != oldWidget.state) {
      reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilderPatched(
        future: pool,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error loading cache: ${snapshot.error}");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
            // return const Text("Loading cache...");
          }

          var data = snapshot.data;

          if (data == null) {
            return const Text("Missing cache data");
          }

          // return ResourcePoolAccess(
          //   pool: data,
          //   child: widget.child,
          // );

          return APIAccess(
              state: widget.state,
              pool: data,
              connector: conn,
              child: widget.child);
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
