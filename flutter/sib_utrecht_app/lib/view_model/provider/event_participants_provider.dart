import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget EventParticipantsProvider(
        {required String eventId,
        required Widget Function(
                BuildContext, List<Future<AnnotatedUser>>, FetchResult<void>)
            builder}) =>
    SingleProvider(
        query: eventId,
        builder: builder,
        // changeListener: (p) => Listenable.merge([p._events, p._users]),
        errorTitle: (loc) => loc.couldNotLoad(loc.dataParticipants),
        obtain: (String q, c) => Events(c).listParticipants(eventId: q)
        // .then((v) => v.map((e) => e.user).toList()),
        );
