import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/entity_card.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/view_model/provider/entity_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/group_provider.dart';

class GroupMembersPage extends StatelessWidget {
  final String groupName;

  const GroupMembersPage({Key? key, required this.groupName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ActionSubscriptionAggregator(
        child: GroupProvider.Single(
            query: groupName,
            builder: (context, group) => GroupMembersProvider(
                groupName: groupName,
                builder: (context, membersNames) {
                  if (membersNames.isEmpty) {
                    return const Center(child: Text("No members found"));
                  }

                  return EntityProvider.Multiplexed(
                      query: membersNames
                          .map((e) => e['entity'] as String)
                          .toList(),
                      builder: (context, members) =>
                          // Padding(
                          //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          //     child:
                          CenteredPageScroll(slivers: [
                            SliverAppBar(
                              automaticallyImplyLeading: false,
                              title:
                                  // Padding(
                                  //     padding: const EdgeInsets.fromLTRB(0, 32, 0, 32),
                                  //     child:
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Transform.scale(
                                        scale: 0.7,
                                        child: EntityIcon(entity: group)),
                                    const SizedBox(width: 16),
                                    Text(group.getLocalLongName(
                                        Localizations.localeOf(context)))
                                  ]),
                              pinned: true,
                            ),
                            SliverPadding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 16, 0, 32),
                                sliver: SliverList.builder(
                                  itemCount: members.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 6, 0, 6),
                                        child: EntityCard(
                                            entity: members[index],
                                            role: membersNames[index]["role"]
                                                as String?)
                                        //  ListTile(
                                        //   leading: CircleAvatar(
                                        //     child: Text(members[index]['entity']?[0] ?? "N/A"),
                                        //   ),
                                        //   title: Text(members[index]['entity'] ?? "N/A"),
                                        // )

                                        );
                                  },
                                )),
                            SliverToBoxAdapter(
                                child: Column(children: [
                              const SizedBox(height: 16),
                              ElevatedButton(
                                  onPressed: () {
                                    router.pushNamed("group_members_add",
                                        pathParameters: {
                                          "group_name": groupName
                                        });
                                  },
                                  child: const Text("Add or remove members")),
                              const SizedBox(height: 64)
                            ]))
                          ]));
                })));
  }
}
