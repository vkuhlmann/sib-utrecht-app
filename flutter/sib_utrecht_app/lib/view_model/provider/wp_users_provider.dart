import 'package:flutter/material.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

// import '../constants.dart';

import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget WPUsersProvider(
        {required Widget Function(BuildContext, List<String>, FetchResult<void>) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUsers),
        // changeListener: (p) => p._users,
        obtain: (void q, c) => Users(c).listWP());


// class WPUsersProvider extends StatefulWidget {
//   final Widget Function(BuildContext context, List<Map> members) builder;

//   const WPUsersProvider(
//       {Key? key, required this.builder})
//       : super(key: key);

//   @override
//   State<WPUsersProvider> createState() => _WPUsersProviderState();
// }

// class _WPUsersProviderState extends State<WPUsersProvider> {
//   Future<CacherApiConnector>? apiConnector;
//   late CachedProvider<List<Map>> content;

//   @override
//   void initState() {
//     super.initState();

//     initContent();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     var conn = APIAccess.of(context).connector;
//     apiConnector = conn;
//     log.info('[WPUsersProvider] didChangeDependencies, conn: $conn');
    
//     setState(() {
//       content.setConnector(conn);
//     });
//   }

//   @override
//   void didUpdateWidget(WPUsersProvider oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     // var conn = apiConnector;

//     // if (conn != null) {
//     //   // for (var element in users) {
//     //   //   element.setConnector(conn);
//     //   // }
//     // }
//     // if (widget.groupName != oldWidget.groupName) {
//     //   initContent();
//     // }
//   }

//   void initContent() {
//     setState(() {
//       // apiConnector = ResourcePoolAccess.of(context).pool.connector;
//       content = CachedProvider<List<Map>>(
//         obtain: (c) => Users(c).listWP(),
//       );

//       var conn = apiConnector;
//       if (conn != null) {
//         content.setConnector(conn);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // log.info('[WPUsersProvider] build, conn: ${APIAccess.of(context).connector}');
//     return ListenableBuilder(
//       listenable: content,
//       builder: (context, _) => FutureBuilderPatched(
//           future: content.loading,
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return formatError(snapshot.error);
//             }

//             var cached = content.cached;
//             log.info("[WPUsersProvider] cached.length: ${cached?.value.length}");

//             if (cached == null) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               return const Center(child: Text('No data'));
//             }

//             return widget.builder(context, cached.value);
//           }),
//     );
//   }
// }
