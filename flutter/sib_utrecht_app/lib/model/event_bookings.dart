import 'dart:convert';

import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';

class EventBookings with CacheableResource {
  @override
  final String id;

  final Map<String, Booking> bookings;

  EventBookings({required String eventId, required this.bookings})
      : id = eventId;

  factory EventBookings.fromJson(Map json) {
    // log.info("EventBookings parsing ${jsonEncode(json)}");

    final eventId = json['id'];

    return EventBookings(
        eventId: eventId,
        bookings: Map.fromEntries((json['bookings'] as Iterable)
            .map((e) => Booking(
                  eventId: eventId,
                  comment: e["comment"],
                  entityId: e["entity_id"],
                ))
            .map((e) => MapEntry(e.entityId, e)))
        // .toSet(),
        );
  }

  @override
  Map toJson() {
    return {
      'id': id,
      'bookings': bookings.values
          .map((e) => {
                'entity_id': e.entityId,
                'comment': e.comment,
              })
          .toList(),
    };
  }
}
