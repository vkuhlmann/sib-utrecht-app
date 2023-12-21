
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/cacheable_list.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/fragments_bundle.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class Events {
  final APIConnector apiConnector;

  Events(this.apiConnector);

  ResourcePool? get pool => getCollectingPoolForConnector(apiConnector);

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

  Future<FetchResult<Event>> getEvent(
          {required String eventId, required bool requireBody}) =>
      retrieve(
          conn: apiConnector,
          fromCached: (pool) {
            var event = pool.get<Event>(eventId);
            // log.info("In Event fromCached, event $eventId, cached fetchResult is $event");
            if (event == null) {
              return null;
            }

            if (!requireBody) {
              return event;
            }

            var body = pool.get<EventBody>(event.value.id);
            if (body == null) {
              return null;
            }

            return FetchResult.merge(event, body)
                .withValue(event.value.withBody(body.value));
          },
          // url: "",
          url: "/events/$eventId?include_image=true",
          parse: (res, unpacker) =>
              unpacker.parse<Event>(res["data"]["event"]));

  Future<int> createEvent(FragmentsBundle data) async {
    final res = await apiConnector.post("/events", body: data.toPayload());

    pool?.invalidateId<CacheableList<Event>>("events");

    return res["data"]["event_id"];
  }

  Future<void> deleteEvent(String eventId) async {
    await apiConnector.delete("/events/$eventId");

    pool?.invalidateId<EventBody>(eventId);
    pool?.invalidateId<Event>(eventId);
    pool?.invalidateId<CacheableList<Event>>("events");
  }

  Future<void> updateEvent(String eventId, FragmentsBundle data) async {
    await apiConnector.put("/events/$eventId", body: data.toPayload());

    pool?.invalidateId<EventBody>(eventId);
    pool?.invalidateId<Event>(eventId);
  }

  Future<Event> startEdit(String eventId) async {
    final res = await apiConnector.post("/events/$eventId/edit");

    return Event.fromJson((res["data"]["event"] as Map), DirectUnpacker());
  }


  Future<FetchResult<List<Future<AnnotatedUser>>>> listParticipants(
          {required String eventId}) =>
      retrieve(
          conn: apiConnector,
          fromCached: null,
          url: "/events/$eventId/participants",
          parse: (res, unpacker) => (res["data"]["participants"] as Iterable)
              .map((e) async => AnnotatedUser(
                  user:
                      await Users(apiConnector).readUser(e["entity"], unpacker),
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
          fromCached: (p) => p.get<CacheableList<Entity>>("event-$eventId-participants"),
          url: "/events/$eventId/participants",
          parse: (res, unpacker) => unpacker.parse<CacheableList<Entity>>({
                "id": "event-$eventId-participants",
                "data": res["data"]["participants"],
              }));
  // (res["data"]["participants"] as Iterable)
  //     .map((e) => unpacker.abstract<Entity>(e["entity"]))
  //     .toList());

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

  Future<FetchResult<List<String>>> list() => retrieve(
      conn: apiConnector,
      fromCached: (p) => p.get<CacheableList<Event>>("events"),
      url: "/events",
      parse: (res, unpacker) =>
      unpacker.parse<CacheableList<Event>>({
        "id": "events",
        "data": res["data"]["events"],
      }));
      //  (res["data"]["events"] as Iterable)
      //     .map((e) => unpacker.abstract<Event>(e))
      //     .toList());
}
