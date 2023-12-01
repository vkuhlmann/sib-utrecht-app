import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/groups_provider.dart';
import 'package:sib_utrecht_app/view_model/user_provider.dart';

class UserPageContents extends StatelessWidget {
  final User user;

  const UserPageContents({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CenteredPageScroll(
      slivers: [
        SliverAppBar(
          // leading: EntityIcon(entity: user),
          // leading: const SizedBox(),
          automaticallyImplyLeading: false,
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            EntityIcon(entity: user),
            const SizedBox(width: 16),
            Text(user.longName)
          ]),
          pinned: true,
          expandedHeight: 200,
          // stretch: true,
          flexibleSpace:
              // FlexibleSpaceBar(
              //   background: Container(
              //     // color: Colors.blue[800],
              //   child: Center(child:
              LayoutBuilder(
                  builder: (context, constraints) => Center(
                          child: ScaleTransition(
                        scale:
                            AlwaysStoppedAnimation(constraints.maxHeight / 60),
                        child: EntityIcon(entity: user),
                      ))
                  // ))

                  // child: Center(child:
                  // EntityIcon(entity: user)))
                  // background: Image.network(
                  //   user.photoUrl,
                  //   fit: BoxFit.cover,
                  // ),
                  ),
        ),
        SliverToBoxAdapter(
          child: UserCard(user: user),
        ),
        SliverToBoxAdapter(
          child: Center(child: EntityTile(entity: user)),
        ),
        SliverToBoxAdapter(
          child: Center(child: Text(user.entityName)),
        ),
        const SliverToBoxAdapter(
            child: SizedBox(
                // color: Colors.blue[100],
                height: 1000,
                child: Center(child: Text("Hello"))))
        // SliverPadding(
        //     padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        //     sliver: SliverList.list(
        //         children: confidants
        //             .map((user) =>
        //                 UserCard(user: user, key: ValueKey(user.entityName)))
        //             .toList()))
      ],
    ));
  }
}

class UserPage extends StatefulWidget {
  final String entityName;

  const UserPage({Key? key, required this.entityName}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
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
    return
        // WithSIBAppBar(
        //     actions: const [],
        //     child:
        UserProvider.Multiplexed(
            query: [widget.entityName],
            builder: (context, users) => UserPageContents(user: users[0]));
  }
}
