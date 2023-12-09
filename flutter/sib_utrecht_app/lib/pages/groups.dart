import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/centered_page.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/view_model/provider/groups_provider.dart';

class GroupsPageContents extends StatelessWidget {
  final List<Group> groups;
  // final GroupsProvider groupsProvider;

  const GroupsPageContents({Key? key, required this.groups}) : super(key: key);

  // static GroupsPageContents fromProvider(GroupsProvider provider, {Key? key}) {
  //   return GroupsPageContents(
  //     key: key,
  //     groups: provider.groups,
  //     groupsProvider: provider,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CustomScrollView(
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 32),
            sliver: SliverList.list(
                children:
                    groups.map((group) => GroupCard(group: group)).toList()))
      ],
    ));
  }
}

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
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
    // var provGroups = ResourcePoolAccess.of(context).pool.groupsProvider;
    return ActionSubscriptionAggregator(
        child: CenteredPage(
            child:
                //  ListenableBuilder(
                //   listenable: provGroups,
                GroupsProvider(
              builder: (context, groups) =>
          // WithSIBAppBar(actions: const [], child:
          Column(children: [
        Expanded(child: GroupsPageContents(groups: groups)),
      ]),
    )));
  }
}
