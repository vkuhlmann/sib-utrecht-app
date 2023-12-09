import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget GroupMembersProvider(
        {required String groupName,
        required Widget Function(BuildContext, List<Map> members) builder}) =>
    SingleProvider(
      query: groupName,
      builder: builder,
      errorTitle: (loc) => loc.couldNotLoad(loc.dataMembers),
      changeListener: (p) => p.groups,
      obtain: (String q, c) => Groups(c).listMembers(groupName: q),
    );
