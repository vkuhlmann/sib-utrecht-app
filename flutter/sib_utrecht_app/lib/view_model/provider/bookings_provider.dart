import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/bookings.dart';
import 'package:sib_utrecht_app/model/booking.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/model/user_bookings.dart';

// import '../constants.dart';

import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget BookingsProvider(
        {required Widget Function(BuildContext, UserBookings, FetchResult<void>) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataBookings),
        // changeListener: (p) => p._events,
        obtain: (void q, c) => Bookings(c).getMyBookings());

