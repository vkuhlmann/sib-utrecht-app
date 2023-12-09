import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

class GroupProvider {
  static Widget Multiplexed({query, builder}) => MultiplexedProvider(
      query: query,
      builder: builder,
      errorTitle: (loc) => loc.couldNotLoad(loc.dataGroups),
      changeListener: (p) => p.groups,
      obtain: (String q, c) => Groups(c).getGroup(groupName: q));

  static Widget Single(
          {required String query,
          required Widget Function(BuildContext, Group) builder}) =>
      SingleProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataGroup),
          changeListener: (p) => p.groups,
          obtain: (String q, c) => Groups(c).getGroup(groupName: q));
}
