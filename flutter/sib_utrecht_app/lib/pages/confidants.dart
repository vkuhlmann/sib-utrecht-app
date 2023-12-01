import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/groups_provider.dart';
import 'package:sib_utrecht_app/view_model/user_provider.dart';

class ConfidantsPageContents extends StatelessWidget {
  final List<User> confidants;
  // final GroupsProvider groupsProvider;

  const ConfidantsPageContents({Key? key, required this.confidants})
      : super(key: key);

  // static ConfidantsPageContents fromProvider(GroupsProvider provider, {Key? key}) {
  //   return ConfidantsPageContents(
  //     key: key,
  //     groups: provider.groups,
  //     groupsProvider: provider,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CenteredPageScroll(
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            sliver: SliverList.list(
                children: confidants
                    .map((user) =>
                        UserCard(user: user, key: ValueKey(user.entityName)))
                    .toList()))
      ],
    ));
  }
}

class ConfidantsPage extends StatefulWidget {
  const ConfidantsPage({Key? key}) : super(key: key);

  @override
  State<ConfidantsPage> createState() => _ConfidantsPageState();
}

class _ConfidantsPageState extends State<ConfidantsPage> {
  // late GroupsProvider groupsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // groupsProvider = GroupsProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBar(title: Text("Groups")),
    //     body: GroupsPageContents.fromProvider(groupsProvider));
    var provGroups = ResourcePoolAccess.of(context).pool.groupsProvider;
    return 
    // WithSIBAppBar(
    //     actions: const [],
    //     child: 
        ListenableBuilder(
            listenable: provGroups,
            builder: (context, _) {
              Group? v = provGroups.groups.firstWhereOrNull(
                  (element) => element.groupName == "confidants");
              if (v == null) {
                return const Center(child: Text("Group not found"));
              }
              // return const Center(child: Text("Group found"));

              return GroupMembersProvider(
                  groupName: "confidants",
                  builder: (context, members) =>
                      // Text("Members are ${members.map((m) => m["entity"] as String).toList().join(", ")}")
                      UserProvider.Multiplexed(
                          query: members
                              .map((m) => m["entity"] as String)
                              .toList(),
                          builder: (context, users) =>
                              ConfidantsPageContents(confidants: users)));

              // UserProvider(entityNames: [],)
              // ConfidantsPageContents(confidants: v.users);
            }
            // UserProvider(entityNames: provGroups.groups[], builder: builder)

            // Column(children: [
            //   Expanded(child: GroupsPageContents.fromProvider(provGroups)),
            // ])),
            );
  }
}
