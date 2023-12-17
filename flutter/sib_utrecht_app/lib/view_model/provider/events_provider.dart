import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget EventsProvider(
        {required Widget Function(BuildContext, List<Event>, FetchResult<void>) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataEvents),
        changeListener: (p) => p.users,
        obtain: (void q, c) => Events(c).list());
