import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [ListTile(
            leading: CircleAvatar(
                child: Text(user.shortName[0]),
              ),
      title: Text(user.longName),
      subtitle: Text(user.entityName),
    ),
    ...((user.data["profile"]?["contact"] as List?)
    ?.map((cont) => (cont as Map).entries.first)
    .map((cont) =>
    // ListTile(
    //   title: Text(cont.key),
    //   subtitle: Text(cont.value),
    // )
    Padding(padding: const EdgeInsets.fromLTRB(32, 16, 16, 16), child:
      Text("${cont.key}: ${cont.value}")
    )) ?? []),
    // Text(user.emailAddress),
    ]));
  }
}
