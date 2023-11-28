import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class EntityCard extends StatelessWidget {
  final Entity entity;

  const EntityCard({Key? key, required this.entity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entity is User) {
      return UserCard(user: entity as User);
    }
    if (entity is Group) {
      return GroupCard(group: entity as Group);
    }
    
    return const Card(child: Text("Unknown entity type"));
  }
}