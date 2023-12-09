import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';

// import '../constants.dart';

import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget ApiConnectorProvider(
        {required Widget Function(BuildContext, APIConnector) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad("APIConnector"),
        obtain: (void q, c) => Future.value(c));

