
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/view_model/group_members_provider.dart';

class GroupMembersPage extends StatelessWidget {
  final String groupName;

  const GroupMembersPage({Key? key, required this.groupName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    WithSIBAppBar(actions: [], child: 
    GroupMembersProvider(groupName: groupName, builder: (context, members) {
      if (members.isEmpty) {
        return const Center(child: Text("No members found"));
      }

      return ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(members[index]['entity'] ?? "N/A"),
            );
          },
        );
    }));
  }
}
