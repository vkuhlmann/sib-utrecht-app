import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Bookings {
  final APIConnector apiConnector;

  Bookings(this.apiConnector);

  // Future<Set<int>> getMyBookings() async {
  //   var raw = await apiConnector.getSimple("/users/me/bookings");

  //   var bookings = (raw["data"]["bookings"] as Iterable<dynamic>)
  //       .where((v) => v["booking"]["status"] == "approved")
  //       .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
  //       .toSet();
  //   return bookings;
  // }

  Future<FetchResult<Set<String>>> getMyBookings() => retrieve(
      conn: apiConnector,
      fromCached: null,
      url: "/users/me/bookings",
      parse: (res, unpacker) => (res["data"]["bookings"] as Iterable<dynamic>)
          .where((v) => v["booking"]["status"] == "approved")
          .map((e) => e["event"]["event_id"].toString())
          .toSet());
}
