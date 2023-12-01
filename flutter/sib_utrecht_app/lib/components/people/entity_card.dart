import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class EntityCard extends StatelessWidget {
  final Entity entity;
  final String? role;

  const EntityCard({Key? key, required this.entity, this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (entity is User) {
      return UserCard(user: entity as User, role: role);
    }
    if (entity is Group) {
      return GroupCard(group: entity as Group, role: role);
    }
    
    return const Card(child: Text("Unknown entity type"));
  }
}