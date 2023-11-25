
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/group.dart';

class GroupCard extends StatelessWidget {
  final Group group;

  const GroupCard({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
        child: ListTile(
          title: Text(group.getLocalTitle(Localizations.localeOf(context)) ?? group.groupName),
          subtitle: Text(group.groupName),
        ));
  }
}
