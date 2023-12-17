import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/members.dart';
import 'package:sib_utrecht_app/model/membership.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/collecting_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Resource<T extends CacheableResource> extends ChangeNotifier {
  // final void Function(Map<String, FetchResult<T>>) save;
  // final dynamic Function(T) serialize;
  // final String Function
  // final T Function(Map json, ResourcePoolBase? pool)

  final Box box;
  final String name;
  final Map<String, FetchResult<T>> data;
  final Map<String, DateTime> invalidationTimestamps = {};

  Resource(
      {required this.data,
      // required this.save,
      required this.name,
      required this.box
      // required this.serialize
      });

  factory Resource.load(
    Box box,
    String entryName,
    // dynamic Function(T) serialize, T Function(dynamic) deserialize
  ) {
    Map<String, FetchResult<T>> data = {};
    dynamic rawData;
    try {
      rawData = box.get(entryName);
    } catch (e) {
      log.warning("Failed to load $entryName from cache: $e");
      box.delete(entryName);
    }

    log.fine("Raw data: $rawData");

    data = ((rawData ?? {}) as Map).map(
      (key, value) {
        final a = FetchResult.fromJson<Map>(value, (v) => v as Map);
        return MapEntry(
            key,
            a.mapValue((p0) => CacheableResource.fromJson<T>(
                p0, CollectingUnpacker(anchor: a, pool: null))));
      },
    );

    var v = Resource<T>(
        box: box,
        data: data,
        // data: ((box.get(entryName) ?? {}) as Map).map((key, value) =>
        //     MapEntry(key, FetchResult.fromJson(value, deserialize))),
        // save: (data) async {
        //   await box.put(entryName,
        //       data.map((key, value) => MapEntry(key, value.toJson(serialize))));

        //   // log.info("Saved $entryName to cache, ${data.length} entries");
        // },
        name: entryName);

    log.info("Loaded $entryName from cache, ${v.data.length} entries");
    return v;
  }

  FetchResult<T>? operator [](String id) {
    // log.info("[Cache] ResourcePool: $id retrieved, timestamp: ${data[id]?.timestamp}, invalidated: ${data[id]?.invalidated}");
    var val = data[id];
    if (val == null) {
      return null;
    }

    final invalidTs = invalidationTimestamps[id];
    if (invalidTs != null && val.timestamp?.isAfter(invalidTs) != true) {
      return val.asInvalidated();
    }

    return val;
  }

  void collect(FetchResult<T> data) {
    final id = data.value.id;
    // if (id == null) {
    //   return;
    // }

    final prevVal = this.data[id];
    final ts = data.timestamp;
    if (ts != null &&
        prevVal != null &&
        prevVal.timestamp?.isAfter(ts) == true) {
      return;
    }

    if (prevVal != null && prevVal.timestamp == ts && prevVal.invalidated) {
      log.info("[Cache] Not collecting invalidated $id");
      return;
    }

    bool hasValueChanged = prevVal == null ||
        !const DeepCollectionEquality()
            .equals(prevVal.value.toJson(), data.value.toJson());

    // if (prevVal != null &&
    //     ) {
    //   // log.info("ResourcePool: $id unchanged");
    //   return;
    // }

    if (!hasValueChanged && prevVal.timestamp == ts) {
      // log.info("[Cache] ResourcePool: $id unchanged");
      return;
    }

    this.data[id] = data;
    if (hasValueChanged) {
      log.info("[Cache] ResourcePool: $id changed ($name)");
      // notifyListeners();
    }
    log.info(
        "[Cache] ResourcePool: $id collected, timestamp changed from ${prevVal?.timestamp} to $ts, "
        " invalidated changed from ${prevVal?.invalidated} to ${data.invalidated}");

    var boxPutVal = this
        .data
        .map((key, value) => MapEntry(key, value.toJson((v) => v.toJson())));

    // final String boxPutValStr = jsonEncode(boxPutVal);

    // if (name == "default-eventBodies") {
    //   log.info("Saving $name to cache:\n$boxPutValStr");
    // }

    box.put(name, boxPutVal).catchError((e) {
      log.severe("Failed to save $name to cache: $e");
    });
    // save(this.data);
  }

  void invalidate() {
    DateTime invalidationTimestamp = DateTime.now();

    log.info("[Cache] Invalidating $name");
    // data.clear();
    for (var entry in data.entries.toList()) {
      data[entry.key] = entry.value.asInvalidated();
      invalidationTimestamps[entry.key] = invalidationTimestamp;
    }

    notifyListeners();
  }

  void invalidateId(String id) {
    DateTime invalidationTimestamp = DateTime.now();
    invalidationTimestamps[id] = invalidationTimestamp;

    // data.remove(id);
    var val = data[id];
    if (val == null) {
      return;
    }

    log.info("[Cache] Invalidating $id in $name");
    data[id] = val.asInvalidated();

    notifyListeners();
  }
}

class ResourcePoolBase {
  final Resource<User> users; // = Resource();
  final Resource<Group> groups; // = Resource();
  final Resource<Event> events; // = Resource();
  final Resource<EventBody> eventBodies;
  final Resource<Members> members;

  ResourcePoolBase({
    required this.users,
    required this.groups,
    required this.events,
    required this.eventBodies,
    required this.members,
  });

  static ResourcePoolBase _load(String? channelName, Box box) {
    // Hive.init(null);
    // final box = await Hive.openBox("cache");

    channelName ??= "default";

    return ResourcePoolBase(
        users: Resource.load(box, "$channelName-users"),
        groups: Resource.load(box, "$channelName-groups"),
        events: Resource.load(box, "$channelName-events"),
        eventBodies: Resource.load(box, "$channelName-eventBodies"),
        members: Resource.load(box, "$channelName-members"));
  }

  static Future<ResourcePoolBase> load(String? channelName) async {
    try {
      Hive.init(null);
    } catch (e) {
      log.severe("Failed to init hive: $e");
      Hive.deleteFromDisk();
      Hive.init(null);
    }
    Box? box;
    try {
      box = await Hive.openBox("cache");
    } catch (e) {
      log.severe("Failed to open cache box: $e");
      Hive.deleteBoxFromDisk("cache");
      box = await Hive.openBox("cache");
    }

    log.info("Opened cache box");

    return _load(channelName, box);
  }

  void collect<T>(FetchResult<T> data) {
    if (data.value is User) {
      users.collect(data as FetchResult<User>);
      return;
    }
    if (data.value is Group) {
      groups.collect(data as FetchResult<Group>);
      return;
    }
    if (data.value is Event) {
      events.collect(data as FetchResult<Event>);
      return;
    }
    if (data.value is EventBody) {
      eventBodies.collect(data as FetchResult<EventBody>);
      return;
    }
    if (data.value is Members) {
      members.collect(data as FetchResult<Members>);
      return;
    }

    log.warning("Not collecting into ResourcePool: ${data.value.runtimeType}");
  }

  // final Map<String, FetchResult<User>> users = {};
  // final Map<String, FetchResult<Group>> groups = {};
  // final Map<String, FetchResult<Event>> events = {};

  // final ChangeNotifier usersChange = ChangeNotifier();
  // final ChangeNotifier groupsChange = ChangeNotifier();
  // final ChangeNotifier eventsChange = ChangeNotifier();

  // void collectUser(FetchResult<User> data) {
  //   final id = data.value.id;
  //   if (id == null) {
  //     return;
  //   }

  //   users[id] = data;
  //   usersChange.notifyListeners();
  // }

  // void collectGroup(FetchResult<Group> data) {
  //   groups[data.query] = data;
  //   groupsChange.notifyListeners();
  // }

  // void collectEvent(FetchResult<Event> data) {
  //   events[data.query] = data;
  //   eventsChange.notifyListeners();
  // }
}
