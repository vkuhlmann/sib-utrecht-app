import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

class UserProvider {
  static Widget Multiplexed({query, builder}) =>
      MultiplexedProvider<String, User>(
        query: query,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataUsers),
        obtain: (q, c) => Users(c).getUser(entityName: q),
        changeListener: (p) => p.users,
      );

  static Widget Single(
          {required String query,
          required Widget Function(BuildContext, User) builder}) =>
      SingleProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataUser),
          obtain: (String q, c) => Users(c).getUser(entityName: q),
          changeListener: (p) => p.users,);
}
