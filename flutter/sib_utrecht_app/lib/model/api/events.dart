
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';

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

  Future<List<AnnotatedUser>> listParticipants({required int eventId})
  async {
    var raw = await apiConnector.get("/events/$eventId/participants");

    return (raw["data"]["participants"] as Iterable<dynamic>)
                .map((e) {
                //   var entityData = {
                //   "long_name": e["name"],
                //   "short_name": e["name_first"] ?? User.truncateUserName(e["name"])
                // };

                // if (e["entity"] != null) {
                //   // entityData.addAll(e["entity"]);
                //   entityData = (e["entity"] as Map).map((key, value) => MapEntry(key as String, value))
                // }


                return AnnotatedUser(user: 
                User.fromJson(
                  e["entity"] ??{
                  "long_name": e["name"],
                  "short_name": e["name_first"] ?? User.truncateUserName(e["name"])
                }
                ),
                comment: e["comment"] as String?);
                }
                )
                //e["name"] as String)
                .toList();
  }

  Future<List<String>> listParticipantsNames({required int eventId})
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
