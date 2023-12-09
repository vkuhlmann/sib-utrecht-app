
import 'package:sib_utrecht_app/model/api_connector.dart';

class Bookings {
  final APIConnector apiConnector;

  Bookings(this.apiConnector);

  Future<Set<int>> getMyBookings() async {
    var raw = await apiConnector.getSimple("/users/me/bookings");

    var bookings = (raw["data"]["bookings"] as Iterable<dynamic>)
        .where((v) => v["booking"]["status"] == "approved")
        .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
        .toSet();
    return bookings;
  }
}
