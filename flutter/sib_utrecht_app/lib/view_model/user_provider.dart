import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
// import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/users.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';

// import '../constants.dart';

class UserProvider extends StatefulWidget {
  final List<String> entityNames;
  final Widget Function(BuildContext context, List<User> users) builder;

  const UserProvider(
      {Key? key, required this.entityNames, required this.builder})
      : super(key: key);

  @override
  State<UserProvider> createState() => _UserProviderState();
}

class _UserProviderState extends State<UserProvider> {
  Future<CacherApiConnector>? apiConnector;
  late List<CachedProvider<User>> users;

  @override
  void initState() {
    super.initState();

    initUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    var conn = APIAccess.of(context).connector;
    apiConnector = conn;
    setState(() {
      for (var element in users) {
        element.setConnector(conn);
      }
    });
  }

  @override
  void didUpdateWidget(UserProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // var conn = apiConnector;

    // if (conn != null) {
    //   for (var element in users) {
    //     element.setConnector(conn);
    //   }
    // }

    initUsers();
  }

  void initUsers() {
    var newUsers = widget.entityNames
        .map((e) => CachedProvider<User>(
              obtain: (c) => Users(c).getUser(entityName: e),
            ))
        .toList();

    var conn = apiConnector;
    if (conn != null) {
      for (var element in newUsers) {
        element.setConnector(conn);
      }
    }

    setState(() {
      // apiConnector = ResourcePoolAccess.of(context).pool.connector;
      users = newUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text("Test");

    return ListenableBuilder(
        listenable: Listenable.merge(users),
        builder: (context, _) => FutureBuilderPatched(
              future: Future.wait(users.map((e) => e.loading)),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return formatError(snapshot.error);
                }

                var cachedVals = users.map((e) => e.cached).toList();
                if (cachedVals.contains(null)) {
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

// class UserProvider with ChangeNotifier {
//   final Future<CacherApiConnector>? apiConnector;

//   final CachedProvider<User> user;
//   // final CachedProvider<List<String>> participants;

//   UserProvider({
//     required this.apiConnector,
//     User? cachedEvent,
//     required String entityName
//   }) 
//   : user = CachedProvider<User>(
//     cache: cachedEvent,
//     obtain: (c) => Users(c).getUser(entityName: entityName),
//   )
//     // participants = CachedProvider<List<String>>(
//   //   obtain: (c) => Events(c).listParticipants(eventId: eventId),
//   // )
//   {
//     user.addListener(_reprocessCached);
//     // participants.addListener(_reprocessCached);

//     var conn = apiConnector;

//     if (conn != null) {
//       user.setConnector(conn);
//       // participants.setConnector(conn);
//     }
//   }

//   static UserProvider forContext(BuildContext context, {required entityName}) {
//     return UserProvider(
//       apiConnector: ResourcePoolAccess.of(context).pool.connector,
//       entityName: entityName
//     );
//   }

//   @override
//   void dispose() {
//     user.removeListener(_reprocessCached);
//     // participants.removeListener(_reprocessCached);
//     super.dispose();
//   }

//   void refresh() {
//     user.invalidate();
//     // participants.invalidate();
//   }

//   void _reprocessCached() {
//     notifyListeners();
//   }


//   // bool doesExpectParticipants() {
//   //   Event? eventCached = event.cached;

//   //   if (eventCached != null) {
//   //     var signupType = eventCached.signupType;

//   //     if (signupType == "api") {
//   //       return true;
//   //     }
//   //   }

//   //   var cachedParticipants = participants.cached;

//   //   if (cachedParticipants != null && cachedParticipants.isNotEmpty) {
//   //     return true;
//   //   }

//   //   return false;
//   // }

//   // static (String?, Map?) extractDescriptionAndThumbnail(Event event) {
//   //   String description = ((event.data["post_content"] ??
//   //           event.data["description"] ??
//   //           "") as String)
//   //       .replaceAll("\r\n\r\n", "<br/><br/>");
//   //   Map? thumbnail = event.data["thumbnail"];

//   //   if (thumbnail != null &&
//   //       thumbnail["url"] != null &&
//   //       !(thumbnail["url"] as String).startsWith("http")) {
//   //     thumbnail["url"] = "$wordpressUrl/${thumbnail["url"]}";
//   //   }

//   //   if (thumbnail == null && description.contains("<img")) {
//   //     final img = RegExp("<img[^>]+src=\"(?<url>[^\"]+)\"[^>]*>")
//   //         .firstMatch(description);

//   //     if (img != null) {
//   //       thumbnail = {"url": img.namedGroup("url")};
//   //       // description = description.replaceAll(img.group(0)!, "");
//   //       description = description.replaceFirst(img.group(0)!, "");
//   //     }
//   //   }

//   //   if (thumbnail != null &&
//   //       thumbnail["url"] != null &&
//   //       (thumbnail["url"] as String).startsWith("http://sib-utrecht.nl/")) {
//   //     thumbnail["url"] = (thumbnail["url"] as String)
//   //         .replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
//   //   }

//   //   description = description.replaceAll(
//   //       RegExp("^(\r|\n|<br */>|<br *>)*", multiLine: false), "");

//   //   return (description.isEmpty ? null : description, thumbnail);
//   // }
// }