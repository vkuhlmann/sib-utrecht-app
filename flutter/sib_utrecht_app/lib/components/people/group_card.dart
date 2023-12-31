import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/model/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;
  final String? role;

  const GroupCard({Key? key, required this.group, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String title =
        group.getLocalTitle(Localizations.localeOf(context)) ?? group.groupName;

    return Card(
        clipBehavior: Clip.antiAlias,
        // child: InkWell(
        //     // onTap: () {
        //     //   Navigator.pushNamed(context, "/group", arguments: group);
        //     // },
        //     child: Padding(
        //         padding: const EdgeInsets.all(10),
        //         child: Column(
        //             crossAxisAlignment: CrossAxisAlignment.start,
        //             children: [
        //               Text(group.getLocalTitle(Localizations.localeOf(context)),
        //                   style: Theme.of(context).textTheme.headlineSmall),
        //               Text(group.description,
        //                   style: Theme.of(context).textTheme.bodyText2),
        //               Text(group.membershipCount.toString() + " members",
        //                   style: Theme.of(context).textTheme.bodyText2),
        //             ]))));
        // child: InkWell(

        // child: Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ListTile(
          leading: CircleAvatar(
            child: Text(title[0]),
          ),
          title: Text(title),
          contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          onTap: () {
            // Navigator.pushNamed(context, "/group", arguments: group);
            GoRouter.of(context).pushNamed("group_members",
                pathParameters: {"group_name": group.groupName});
          },
        ));
    // ListTile(
    //   title: Text(group.getLocalTitle(Localizations.localeOf(context)) ?? group.groupName),
    //   subtitle: Text(group.groupName),
    // ));
  }
}
