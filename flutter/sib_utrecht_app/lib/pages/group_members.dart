import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/people/entity_card.dart';
import 'package:sib_utrecht_app/view_model/entity_provider.dart';
import 'package:sib_utrecht_app/view_model/group_members_provider.dart';

class GroupMembersPage extends StatelessWidget {
  final String groupName;

  const GroupMembersPage({Key? key, required this.groupName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
    // WithSIBAppBar(
    //     actions: [],
    //     child: 
        GroupMembersProvider(
            groupName: groupName,
            builder: (context, membersNames) {
              if (membersNames.isEmpty) {
                return const Center(child: Text("No members found"));
              }

              return EntityProvider(
                  entityNames:
                      membersNames.map((e) => e['entity'] as String).toList(),
                  builder: (context, members) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: 
                      CustomScrollView(slivers: [
                        SliverPadding(padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                        sliver:
                      SliverList.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                              child: EntityCard(entity: members[index], role: membersNames[index]["role"] as String?)
                              //  ListTile(
                              //   leading: CircleAvatar(
                              //     child: Text(members[index]['entity']?[0] ?? "N/A"),
                              //   ),
                              //   title: Text(members[index]['entity'] ?? "N/A"),
                              // )

                              );
                        },
                      ))])));
            });
  }
}
