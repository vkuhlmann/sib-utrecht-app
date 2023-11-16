
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/event.dart';

class Events {
  final APIConnector apiConnector;

  // List<dynamic>? _bookings;
  // Set<int>? _bookingsSet;

  Events(this.apiConnector);


  Future<Event> getEvent({required int eventId, required bool includeImage})
  async {
    var raw = await apiConnector.get(
      includeImage ? 
      "/events/$eventId?include_image=true"
      :
      "/events/$eventId"
      );

    return Event.fromJson(
            (raw["data"]["event"] as Map)
                .map<String, dynamic>((key, value) => MapEntry(key, value)));
  }

  Future<List<String>> listParticipants({required int eventId})
  async {
    var raw = await apiConnector.get("/events/$eventId/participants");

    return (raw["data"]["participants"] as Iterable<dynamic>)
                .map((e) => e["name"] as String)
                .toList();
  }

  Future<List<Event>> list() async {
    var raw = await apiConnector.get("/events");

    return (raw["data"]["events"] as Iterable<dynamic>)
              .map((e) => (e as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key as String, value)))
              .map((e) => Event.fromJson(e))
              .toList();
  }
}
