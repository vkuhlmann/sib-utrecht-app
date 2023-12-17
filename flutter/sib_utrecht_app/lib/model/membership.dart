import 'dart:async';

import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Membership {
  final String groupName;
  // final Entity entity;
  final String entity;
  final String role;
  final Map data;

  Membership(
      {required this.groupName,
      required this.entity,
      required this.role,
      required this.data});

  static Membership fromJson(Map json, AnchoredUnpacker unpacker) {
    return Membership(
      groupName: json['group_name'],
      entity: unpacker.abstract<Entity>(json['entity']),
      role: json['role'],
      data: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...data,
      'group_name': groupName,
      'entity': entity,
      'role': role,
    };
  }
}

