import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget GroupMembersProvider(
        {required String groupName,
        required Widget Function(BuildContext, Members members, FetchResult<void>) builder}) =>
    SingleProvider(
      query: groupName,
      builder: builder,
      errorTitle: (loc) => loc.couldNotLoad(loc.dataMembers),
      // changeListener: (p) => p._members,
      obtain: (String q, c) => Groups(c).getMembers(groupName: q),
    );
