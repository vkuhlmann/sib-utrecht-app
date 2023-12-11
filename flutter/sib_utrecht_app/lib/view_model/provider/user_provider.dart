import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

class UserProvider {
  static Widget Multiplexed(
          {query,
          required Widget Function(BuildContext, List<User>) builder}) =>
      MultiplexedProvider<String, User>(
        query: query,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUsers),
        obtain: (q, c) async => (await Users(c).getUser(entityName: q)).value,
        changeListener: (p) => p.users,
      );

  static Widget Single(
          {required String query,
          required Widget Function(BuildContext, User) builder}) =>
      SingleProvider(
        query: query,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUser),
        obtain: (String q, c) async {
            log.info("UserProvider: obtaining $q with $c");
            final ans = (await Users(c).getUser(entityName: q));
            log.info("UserProvider: obtained $ans");
            return ans.value;
        },
        changeListener: (p) => p.users,
      );
}
