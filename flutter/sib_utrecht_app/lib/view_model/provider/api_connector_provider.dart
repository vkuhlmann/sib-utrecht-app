import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';

// import '../constants.dart';

import 'package:sib_utrecht_app/view_model/single_provider.dart';

class ApiConnectorProvider extends StatelessWidget {
  final Widget Function(BuildContext, APIConnector) builder;

  const ApiConnectorProvider({required this.builder, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilderPatched(
        future: APIAccess.of(context).connector,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data != null) {
            return builder(context, data);
          }

          return const SizedBox();
        });
  }
}

// Widget ApiConnectorProvider(
//         {required Widget Function(BuildContext, APIConnector) builder}) =>
//         Builder
//     FutureBuilderPatched(future: APIA)
    
//     // SingleProvider(
//     //     query: null,
//     //     builder: builder,
//     //     errorTitle: (loc) => loc.couldNotLoad("APIConnector"),
//     //     obtain: (void q, c) => Future.value(c));

