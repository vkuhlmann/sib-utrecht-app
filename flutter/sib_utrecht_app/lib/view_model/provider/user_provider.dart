import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

class UserProvider {
  static Widget Multiplexed(
          {query,
          required Widget Function(BuildContext, List<FetchResult<User>>) builder}) =>
      MultiplexedProvider<String, User>(
        query: query,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUsers),
        obtain: (q, c) async => (await Users(c).getUser(entityName: q)),
        // changeListener: (p) => p._users,
      );

  static Widget Single(
          {required String query,
          required Widget Function(BuildContext, User, FetchResult<void>) builder}) =>
      SingleProvider(
        query: query,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUser),
        obtain: (String q, c) async {
            log.info("UserProvider: obtaining $q with $c");
            final ans = (await Users(c).getUser(entityName: q));
            log.info("UserProvider: obtained $ans");
            return ans;
        },
        // changeListener: (p) => p._users,
      );
}
