import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class EntityTile extends StatelessWidget {
  final Entity entity;

  const EntityTile({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget caption = const Text("Unknown");

    final ent = entity;
    if (ent is User) {
      caption = Text(ent.shortName);

      // return Column(children: [
      //   EntityIcon(entity: entity),
      //   Text(ent.shortName),
      //   // Text("Unknown")
      // ]);
    }
    if (ent is Group) {
      caption = Text(ent.getLocalTitle(Localizations.localeOf(context)));

      // return Column(children: [
      //   EntityIcon(entity: entity),
      //   Text(ent.getLocalTitle(Localizations.localeOf(context))),
      //   // Text("Unknown")
      // ]);
    }

    // return const Column(children: [Icon(Icons.question_mark), Text("Unknown")]);
    return Column(children: [
        EntityIcon(entity: entity),
        caption,
        // Text("Unknown")
      ]);
  }
}
