import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final String? role;

  const UserCard({Key? key, required this.user, this.role}) : super(key: key);

  Widget buildContactOption(BuildContext context, String type, dynamic value) {
    Icon? icon = {
      "e-mail": const Icon(Icons.email),
      "email": const Icon(Icons.email),
    }[type];

    Widget title = Text(
      value.toString(),
      overflow: TextOverflow.ellipsis,
    );

    if (type == "email" || type == "e-mail") {
      String email = value as String;

      title = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: title),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: IconButton(
                icon: const Icon(Icons.content_copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: email));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("E-mail copied to clipboard")));
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
    String subtitle = user.entityName ?? "";

    if (role != null) {
      subtitle += " ($role)";
    }

    String? entityName = user.entityName;

    return
        // Card(
        //     child:
        Stack(children: [
      // EntityIcon(entity: user),
      // Expanded(
      // child:
      // Positioned(child:
      Padding(
          padding: const EdgeInsets.fromLTRB(55, 0, 0, 0),
          child: Card(
            // color: Colors.red,
                  child: InkWell(
              onTap: entityName == null
                  ? null
                  : () {
                      GoRouter.of(context).pushNamed("user_page",
                          pathParameters: {"entity_name": entityName});
                    },
              child: 
                      // Text("test")
                      Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  // dense: true,
                                  visualDensity: VisualDensity.compact,
                                  // contentPadding: EdgeInsets.zero,
                                  // leading:
                                  // Transform.translate(offset: Offset(-32, 0), child: EntityIcon(entity: user)),
                                  // leading: EntityIcon(entity: user),
                                  // CircleAvatar(
                                  //   child: Text(user.shortName[0]),
                                  // ),
                                  title: Text(user.longName),
                                  subtitle: Text(subtitle),
                                ),
                                ...((user.data["profile"]?["contact"] as List?)
                                        ?.map((cont) =>
                                            (cont as Map).entries.first)
                                        .map((cont) =>
                                            // ListTile(
                                            //   title: Text(cont.key),
                                            //   subtitle: Text(cont.value),
                                            // )
                                            // Padding(padding: const EdgeInsets.fromLTRB(32, 16, 16, 16), child:
                                            //   Text("${cont.key}: ${cont.value}")
                                            // )
                                            Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        32, 8, 16, 8),
                                                child: buildContactOption(
                                                    context,
                                                    cont.key,
                                                    cont.value))) ??
                                    []),
                                // Text(user.emailAddress),
                              ]))))),
      Positioned(left: 0, top: 7, child: 
      Transform.scale(scale: 0.8, child:
      EntityIcon(entity: user)))
    ]);
  }
}
