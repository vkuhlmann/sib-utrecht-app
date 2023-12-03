import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget EventParticipantsProvider(
        {required int eventId,
        required Widget Function(BuildContext, List<AnnotatedUser> members)
            builder}) =>
    SingleProvider(
      query: eventId,
      builder: builder,
      obtainProvider: (int q) => CachedProvider(
        obtain: (c) => Events(c).listParticipants(eventId: q),
      ),
    );
