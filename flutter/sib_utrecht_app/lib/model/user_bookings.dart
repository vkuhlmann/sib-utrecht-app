import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';

class UserBookings with CacheableResource {
  @override
  final String id;

  final Map<String, Booking> bookings;

  UserBookings({required this.id, required this.bookings});

  factory UserBookings.fromJson(Map json) {
    final userId = json['id'];

    return UserBookings(
      id: userId,
      bookings: 
        Map.fromEntries(
      (json['bookings'] as Iterable)
          .map((e) => Booking(eventId: e["event_id"].toString(),
              comment: e["comment"],
              entityId: userId,
          )).map((e) => MapEntry(e.eventId, e)))
          // .toSet(),
    );
  }

  @override
  Map toJson() {
    return {
      'id': id,
      'bookings': bookings.values.map((e) => {
        'event_id': e.eventId,
        'comment': e.comment,
      }).toList(),
    };
  }

}
