import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/provider/event_bookings_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';

Widget EventParticipantsProvider(
        {required String eventId,
        required Widget Function(BuildContext, List<AnnotatedUser>) builder}) =>
    Builder(
        builder: (context) => EventBookingsProvider(
            eventId: eventId,
            builder: (context, eventBookings, _) {
              log.info("EventParticipantsProvider: ${eventBookings.bookings.values.length}");

              return UserProvider.Multiplexed(
                query: eventBookings.bookings.values
                    .map((e) => e.entityId)
                    .toList(),
                builder: (context, users) => builder(
                    context,
                    eventBookings.bookings.values
                        .mapIndexed((index, e) => AnnotatedUser(
                            user: users[index].value, comment: e.comment))
                        .toList()));}));
