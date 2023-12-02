import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class EntityIcon extends StatelessWidget {
  final Entity entity;

  const EntityIcon({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ent = entity;
    if (ent is User) {
      return CircleAvatar(
        backgroundColor: Colors.red[900],
        radius: 28,
        child: 
        SelectionContainer.disabled(child:
        Text(ent.shortName[0], style: const TextStyle(color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.normal),
        )),
      );
    }
    if (ent is Group) {
      return CircleAvatar(
        child: 
        SelectionContainer.disabled(child:
        Text(ent.getLocalShortName(Localizations.localeOf(context)))),
      );
    }
    
    return const Icon(Icons.question_mark);
  }
}