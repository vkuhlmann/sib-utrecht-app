
import 'package:sib_utrecht_app/model/api_connector.dart';

class Bookings {
  final APIConnector apiConnector;

  // List<dynamic>? _bookings;
  // Set<int>? _bookingsSet;

  Bookings(this.apiConnector);

  // Future<List<dynamic>> get raw async {
  //   List<dynamic> bookings = _bookings ?? await apiConnector.get("/users/me/bookings").then(
  //       (value) => (value["data"]["bookings"] as Iterable<dynamic>)
  //           .where((v) => v["booking"]["status"] == "approved")
  //           .toList(),
  //     );
  //   _bookings = bookings;
  //   return bookings;
  // }

  Future<Set<int>> getMyBookings() async {
    var raw = await apiConnector.get("/users/me/bookings");

    var bookings = (raw["data"]["bookings"] as Iterable<dynamic>)
        .where((v) => v["booking"]["status"] == "approved")
        .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
        .toSet();
    return bookings;
  }
}
