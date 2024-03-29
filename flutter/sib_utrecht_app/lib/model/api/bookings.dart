import 'dart:convert';

import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/cacheable_list.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/event_bookings.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/user_bookings.dart';

class Bookings {
  final APIConnector apiConnector;

  Bookings(this.apiConnector);

  ResourcePool? get pool => getCollectingPoolForConnector(apiConnector);

  // Future<Set<int>> getMyBookings() async {
  //   var raw = await apiConnector.getSimple("/users/me/bookings");

  //   var bookings = (raw["data"]["bookings"] as Iterable<dynamic>)
  //       .where((v) => v["booking"]["status"] == "approved")
  //       .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
  //       .toSet();
  //   return bookings;
  // }

  RetrievalRoute<EventBookings> getEventBookings({required String eventId}) =>
      retrieve(
          fromCached: (pool) => pool.get<EventBookings>(eventId),
          url: "/events/$eventId/participants",
          parse: (res, unpacker) {
            // log.info("In EventBookings parse, res is $res");
            return unpacker.parse<EventBookings>({
              "id": eventId,
              "bookings": (res["data"]["participants"] as Iterable<dynamic>)
                  .map((e) => {
                        "entity_id": unpacker.abstract<Entity>(e["entity"]),
                        "comment": e["comment"] as String?
                      })
                  .toList()
            });
          });

  RetrievalRoute<UserBookings> getMyBookings() => retrieve(
      // conn: apiConnector,
      fromCached: (pool) => pool.get<UserBookings>("me"),
      url: "/users/me/bookings",
      parse: (res, unpacker) => unpacker.parse<UserBookings>({
            "id": "me",
            "bookings": (res["data"]["bookings"] as Iterable<dynamic>)
                .where((v) => v["booking"]["status"] == "approved")
                .map((e) =>
                    {"event_id": "wp-${e['event']['event_id']}", "comment": null})
                .toList()
          }));

  Future<void> addMeBooking({required String eventId}) async {
    Map res = await apiConnector
        .post("/users/me/bookings/?event_id=$eventId&consent=true");

    bool isSuccess = res["status"] == "success";
    assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

    pool?.invalidateId<UserBookings>("me");
  }

  Future<void> removeMeBooking({required String eventId}) async {
    Map res =
        await apiConnector.delete("/users/me/bookings/by-event-id/$eventId");

    bool isSuccess = res["status"] == "success";
    assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

    pool?.invalidateId<UserBookings>("me");
  }
}
