import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/bookings.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';

// import '../constants.dart';

import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget BookingsProvider(
        {required Widget Function(BuildContext, Set<int>) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataBookings),
        changeListener: (p) => p.events,
        obtain: (void q, c) => Bookings(c).getMyBookings());

