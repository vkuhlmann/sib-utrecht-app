import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/provider/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/group_provider.dart';
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
          horizontalPadding: 8,
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            sliver: 
            SliverList.list(
                children: confidants
                    .map((user) =>
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                          child: UserCard(user: user, key: ValueKey(user.entityName))))
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
  Widget build(BuildContext context) => ActionSubscriptionAggregator(
      child: GroupProvider.Single(
          query: "confidants",
          builder: (context, group) => GroupMembersProvider(
              groupName: "confidants",
              builder: (context, members) => UserProvider.Multiplexed(
                  query: members.map((m) => m["entity"] as String).toList(),
                  builder: (context, users) =>
                      ConfidantsPageContents(confidants: users)))));
}
