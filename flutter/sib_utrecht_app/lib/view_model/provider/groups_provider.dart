import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

Widget GroupsProvider(
        {required Widget Function(BuildContext, List<Group>) builder}) =>
    SingleProvider(
        query: null,
        builder: builder,
        errorTitle: (loc) => loc.couldNotLoad(loc.dataGroups),
        changeListener: (p) => p.groups,
        obtain: (void q, c) => Groups(c).list());
