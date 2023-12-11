import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';

class Events {
  final APIConnector apiConnector;

  Events(this.apiConnector);

  Future<Event> parseEvent(Map data) async {
    var val = Event.fromJson(data);
    var conn = apiConnector;
    if (conn is CacheApiConnectorMonitor) {
      conn.collectEvent(val);
    }
    return val;
  }

  Future<Event> getEvent(
      {required int eventId, required bool includeImage}) async {
    var raw = await apiConnector.getSimple(includeImage
        ? "/events/$eventId?include_image=true"
        : "/events/$eventId");

    return parseEvent(raw["data"]["event"] as Map);
  }

  Future<List<AnnotatedUser>> listParticipants({required int eventId}) async {
    log.info("Fetching participants for event $eventId");
    var raw = await apiConnector.getSimple("/events/$eventId/participants");

    // return Future.wait(
    //     (raw["data"]["participants"] as Iterable<dynamic>).map((e) async {
    //   return AnnotatedUser(
    //       user: await Users(apiConnector).fetchUser(e["entity"] ??
    //           {
    //             "long_name": e["name"],
    //             "short_name":
    //                 e["name_first"] ?? User.truncateUserName(e["name"])
    //           }),
    //       comment: e["comment"] as String?);
    // }));

    return Future.wait(
        (raw["data"]["participants"] as Iterable<dynamic>).map((e) async {
      // final user = AnnotatedUser(
      //     user: await Users(apiConnector).readUser(e["entity"] ??
      //         {
      //           "long_name": e["name"],
      //           "short_name":
      //               e["name_first"] ?? User.truncateUserName(e["name"])
      //         }),
      //     comment: e["comment"] as String?);

      // return Booking(
      //     eventId: eventId.toString(),
      //     userId: user.id,
      //     // user: user,
      //     comment: user.comment);

      return AnnotatedUser(
          user: await Users(apiConnector).readUser(e["entity"]),
          comment: e["comment"] as String?);

      // final wpFallback = "wp-user-${e['id']}";

      // return Booking(
      //     eventId: eventId.toString(),
      //     userId: await Users(apiConnector).abstractUser(e["entity"] ?? wpFallback),
      //     comment: e["comment"] as String?);
    }));
  }

  Future<List<String>> listParticipantsNames({required int eventId}) async {
    var raw = await apiConnector.getSimple("/events/$eventId/participants");

    return (raw["data"]["participants"] as Iterable<dynamic>)
        .map((e) => e["name"] as String)
        .toList();
  }

  Future<List<Event>> list() async {
    var raw = await apiConnector.getSimple("/events");

    return Future.wait(
        (raw["data"]["events"] as Iterable<dynamic>).map((e) => parseEvent(e)));
  }
}
