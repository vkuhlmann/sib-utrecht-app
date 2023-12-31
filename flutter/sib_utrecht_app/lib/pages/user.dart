import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:sib_utrecht_app/components/people/entity_header.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/components/people/user_details_edit.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';

class UserPageContents extends StatelessWidget {
  final User user;

  const UserPageContents({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? entityName = user.entityName;

    return SelectionArea(
        child: CustomScrollView(
      slivers: [
        EntityAppBar(user),
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child:
                        // Row(children: [],)
                        Center(
                            child: Text(
                      "User details",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
                maxCrossAxisExtent: 700,
                child: SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                    sliver: MultiSliver(children: [
                      SliverToBoxAdapter(
                        child: Card(
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child: Column(children: [
                                  EditUserDetails(user: user),
                                  const SizedBox(height: 32),
                                  ExpansionTile(
                                      title: const Text("Debug information"),
                                      childrenPadding: const EdgeInsets.all(16),
                                      children: [
                                        UserCard(user: user),
                                        Center(child: EntityTile(entity: user)),
                                        Row(children: [
                                          Text(
                                              "Entity name: ${entityName ?? 'null'}"),
                                          const SizedBox(width: 8),
                                          if (entityName != null)
                                            IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: entityName));
                                                },
                                                icon: const Icon(Icons.copy,
                                                    size: 16))
                                        ]),
                                      ]),
                                ]))),
                      )
                    ])))),
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Center(
                        child: Text(
                      "Memberships",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
              maxCrossAxisExtent: 700,
              child: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                  sliver: MultiSliver(children: const [
                    SliverToBoxAdapter(
                        child: Card(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child:
                                    Center(child: Text("To be implemented")))))
                  ])),
            ))
        //  SliverToBoxAdapter(
        //   child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         // const SizedBox(height: 48),

        //         const SizedBox(height: 8),
        //         ,
        //         const SizedBox(height: 32),
        //         Text(
        //           "Memberships",
        //           style: Theme.of(context).textTheme.headlineSmall,
        //         ),
        //         const SizedBox(height: 8),
        //         const Card(
        //             child: Padding(
        //                 padding:
        //                     EdgeInsets.fromLTRB(8, 16, 8, 16),
        //                 child: Center(child: Text("To be implemented")))),
        //         const SizedBox(height: 32),
        //         const SizedBox(
        //             height: 1000, child: Center(child: Text("Hello")))
        //       ]),
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
        UserProvider.Single(
            query: widget.entityName,
            builder: (context, user, _) => UserPageContents(user: user));
  }
}
