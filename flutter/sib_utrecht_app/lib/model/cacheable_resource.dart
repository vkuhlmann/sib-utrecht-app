import 'package:sib_utrecht_app/model/cacheable_list.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/event_bookings.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/membership.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/model/user_bookings.dart';

abstract mixin class CacheableResource {
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
      if (json.entries.length == 1) {
        final a = json.entries.first;
        final type = a.key;
        final data = a.value as Map;

        if (type == "user") {
          return unpacker.parse<User>(data) as T;
        }
        if (type == "group") {
          return unpacker.parse<Group>(data) as T;
        }

        // throw Exception("Unknown entity type: $type");
      }

      return unpacker.parse<User>(json) as T;

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

    if (T == CacheableList<User>) {
      return CacheableList<User>.fromJson(json, unpacker) as T;
    }
    if (T == CacheableList<Event>) {
      return CacheableList<Event>.fromJson(json, unpacker) as T;
    }
    if (T == CacheableList<Group>) {
      return CacheableList<Group>.fromJson(json, unpacker) as T;
    }

    if (T == UserBookings) {
      return UserBookings.fromJson(json) as T;
    }

    if (T == EventBookings) {
      return EventBookings.fromJson(json) as T;
    }

    throw Exception("Unknown type $T");
  }

  Map toJson();
}
