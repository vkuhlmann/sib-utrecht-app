import 'dart:async';

import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/membership.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Members implements CacheableResource {
  @override
  String get id => groupName;

  final String groupName;

  final List<Membership> memberships;
  final Map metadata;

  Members(
      {required this.groupName,
      required this.memberships,
      required this.metadata});

  factory Members.fromJson(Map json, AnchoredUnpacker unpacker) {
    return Members(
        groupName: json['group_name'],
        memberships: (json['memberships'] as Iterable)
            .map((e) => Membership.fromJson(e, unpacker))
            .toList()
        // .fold([], (previousValue, element) =>
        // foThen(element, (p0) =>
        // [...previousValue, p0]))
        // .toList()
        ,
        metadata: json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...metadata,
      'group_name': groupName,
      'memberships': memberships.map((e) => e.toJson()).toList(),
    };
  }
}
