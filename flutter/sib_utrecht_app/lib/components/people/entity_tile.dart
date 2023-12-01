import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class EntityTile extends StatelessWidget {
  final Entity entity;

  const EntityTile({Key? key, required this.entity}) : super(key: key);

  Widget getCaption() {
    final ent = entity;
    if (ent is User) {
      return Text(ent.shortNameUnique, overflow: TextOverflow.ellipsis,);
    }
    if (ent is Group) {
      return Builder(builder: (context) =>
        Text(ent.getLocalTitle(Localizations.localeOf(context))));
    }

    return const Text("Unknown");
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
        EntityIcon(entity: entity),
        const SizedBox(height: 4,),
        getCaption(),
      ]);
  }
}
