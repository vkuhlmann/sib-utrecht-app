import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cache_monitor.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Events {
  final APIConnector apiConnector;

  Events(this.apiConnector);

  // Future<Event> parseEvent(Map data) async {
  //   var val = Event.fromJson(data);
  //   var conn = apiConnector;
  //   if (conn is CacheApiConnectorMonitor) {
  //     conn.collectEvent(val);
  //   }
  //   return val;
  // }

  // Future<Event> getEvent(
  //     {required int eventId, required bool includeImage}) async {
  //   var raw = await apiConnector.getSimple(includeImage
  //       ? "/events/$eventId?include_image=true"
  //       : "/events/$eventId");

  //   return parseEvent(raw["data"]["event"] as Map);
  // }

  Future<FetchResult<Event>> getEvent({required String eventId, required bool requireBody}) => retrieve(
      conn: apiConnector,
      fromCached: (pool) {
        var event = pool.events[eventId];
        if (event == null) {
          return null;
        }

        if (!requireBody) {
          return event;
        }

        var body = pool.eventBodies[Event.getBodyIdForEventId(event.value.id)];
        if (body == null) {
          return null;
        }

        return FetchResult.merge(event, body).withValue(event.value.withBody(body.value));

      },
      url: "/events/$eventId?include_image=true",
      parse: (res, unpacker) => unpacker.parse<Event>(res["data"]["event"]));

  Future<FetchResult<List<Future<AnnotatedUser>>>> listParticipants(
          {required String eventId}) =>
      retrieve(
          conn: apiConnector,
          fromCached: null,
          url: "/events/$eventId/participants",
          parse: (res, unpacker) => (res["data"]["participants"] as Iterable)
              .map((e) async => AnnotatedUser(
                  user: await Users(apiConnector).readUser(e["entity"], unpacker),
                  comment: e["comment"] as String?))
              .toList());

  // Future<List<AnnotatedUser>> listParticipants({required int eventId}) async {
  //   log.info("Fetching participants for event $eventId");
  //   var raw = await apiConnector.getSimple("/events/$eventId/participants");

  //   // return Future.wait(
  //   //     (raw["data"]["participants"] as Iterable<dynamic>).map((e) async {
  //   //   return AnnotatedUser(
  //   //       user: await Users(apiConnector).fetchUser(e["entity"] ??
  //   //           {
  //   //             "long_name": e["name"],
  //   //             "short_name":
  //   //                 e["name_first"] ?? User.truncateUserName(e["name"])
  //   //           }),
  //   //       comment: e["comment"] as String?);
  //   // }));

  //   return Future.wait(
  //       (raw["data"]["participants"] as Iterable<dynamic>).map((e) async {
  //     // final user = AnnotatedUser(
  //     //     user: await Users(apiConnector).readUser(e["entity"] ??
  //     //         {
  //     //           "long_name": e["name"],
  //     //           "short_name":
  //     //               e["name_first"] ?? User.truncateUserName(e["name"])
  //     //         }),
  //     //     comment: e["comment"] as String?);

  //     // return Booking(
  //     //     eventId: eventId.toString(),
  //     //     userId: user.id,
  //     //     // user: user,
  //     //     comment: user.comment);

  //     return AnnotatedUser(
  //         user: await Users(apiConnector).readUser(e["entity"]),
  //         comment: e["comment"] as String?);

  //     // final wpFallback = "wp-user-${e['id']}";

  //     // return Booking(
  //     //     eventId: eventId.toString(),
  //     //     userId: await Users(apiConnector).abstractUser(e["entity"] ?? wpFallback),
  //     //     comment: e["comment"] as String?);
  //   }));
  // }


  Future<FetchResult<List<String>>> listParticipantsIds(
          {required int eventId}) =>
      retrieve(
          conn: apiConnector,
          fromCached: null,
          url: "/events/$eventId/participants",
          parse: (res, unpacker) => (res["data"]["participants"] as Iterable)
              .map((e) => unpacker.abstract<Entity>(e["entity"]))
              .toList());

  // Future<List<String>> listParticipantsNames({required int eventId}) async {
  //   var raw = await apiConnector.getSimple("/events/$eventId/participants");

  //   return (raw["data"]["participants"] as Iterable<dynamic>)
  //       .map((e) => e["name"] as String)
  //       .toList();
  // }

  // Future<List<Event>> list() async {
  //   var raw = await apiConnector.getSimple("/events");

  //   return Future.wait(
  //       (raw["data"]["events"] as Iterable<dynamic>).map((e) => parseEvent(e)));
  // }

  Future<FetchResult<List<Event>>> list() => retrieve(
      conn: apiConnector,
      fromCached: null,
      url: "/events",
      parse: (res, unpacker) => (res["data"]["events"] as Iterable)
          .map((e) => unpacker.parse<Event>(e))
          .toList());
}
