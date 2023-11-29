import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  Widget buildContactOption(BuildContext context, String type, dynamic value) {
    Icon? icon = {
      "e-mail": const Icon(Icons.email),
      "email": const Icon(Icons.email),
    }[type];

    Widget title = Text(value.toString());

    if (type == "email" || type == "e-mail") {
      String email = value as String;

      title = Row(
        children: [
          title,
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: IconButton(
              icon: const Icon(Icons.content_copy, size: 16),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text: email));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "E-mail copied to clipboard")));
              }),
          )
        ],
      );
    }

    String? subtitle;

    if (icon == null) {
      subtitle = type;
    }

    return ListTile(
      leading: icon,
      title: title,
      subtitle: subtitle != null ? Text(type) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
            onTap: () {
              GoRouter.of(context).pushNamed("user_page",
                  pathParameters: {"entity_name": user.entityName});
            },
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(
                leading: EntityIcon(entity: user),
                // CircleAvatar(
                //   child: Text(user.shortName[0]),
                // ),
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
                          // Padding(padding: const EdgeInsets.fromLTRB(32, 16, 16, 16), child:
                          //   Text("${cont.key}: ${cont.value}")
                          // )
                          Padding(
                              padding: const EdgeInsets.fromLTRB(32, 8, 16, 8),
                              child:
                                  buildContactOption(context, cont.key, cont.value))) ??
                  []),
              // Text(user.emailAddress),
            ])));
  }
}
