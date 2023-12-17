import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/membership.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

abstract interface class CacheableResource {
  String get id;

  static T fromJson<T extends CacheableResource>(
      Map json, AnchoredUnpacker unpacker) {
    if (T == Event) {
      return Event.fromJson(json, unpacker) as T;
    }
    if (T == EventBody) {
      return EventBody.fromJson(json) as T;
    }

    if (T == Group) {
      return Group.fromJson(json) as T;
    }
    if (T == User) {
      return User.fromJson(json) as T;
    }
    if (T == Entity) {
      final a = json.entries.first;
      final type = a.key;
      final data = a.value as Map;

      if (type == "user") {
        return User.fromJson(data) as T;
      }
      if (type == "group") {
        return Group.fromJson(data) as T;
      }

      throw Exception("Unknown entity type: $type");

      // if (json.value["type"] == "group") {
      //   return Group.fromJson(json.value) as T;
      // }
      // return User.fromJson(json.value) as T;
    }

    // if (T extends User) {

    // }
    // if (T is Entity) {
    //   return Entity.fromJson(json.value) as T;
    // }

    if (T == Members) {
      return Members.fromJson(json, unpacker) as T;
      // return Members.fromJson(json.value,
      //         AnchoredUnpacker(base: unpacker, anchor: json.mapValue((p0) {})))
      //     as T;
    }

    throw Exception("Unknown type $T");
  }

  Map toJson();
}
