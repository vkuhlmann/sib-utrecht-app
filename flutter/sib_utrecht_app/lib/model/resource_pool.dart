import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Resource<T> extends ChangeNotifier {
  final Map<String, FetchResult<T>> data;
  final void Function(Map<String, FetchResult<T>>) save;
  final Map<String, DateTime> invalidationTimestamps = {};

  final dynamic Function(T) serialize;

  final String name;

  Resource(
      {required this.data,
      required this.save,
      required this.name,
      required this.serialize});

  static Resource<T> load<T>(Box box, String entryName,
      dynamic Function(T) serialize, T Function(dynamic) deserialize) {
    var v = Resource<T>(
        data: ((box.get(entryName) ?? {}) as Map).map((key, value) =>
            MapEntry(key, FetchResult.fromJson(value, deserialize))),
        save: (data) async {
          await box.put(entryName,
              data.map((key, value) => MapEntry(key, value.toJson(serialize))));

          // log.info("Saved $entryName to cache, ${data.length} entries");
        },
        name: entryName,
        serialize: serialize);

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

  void collect(String? id, FetchResult<T> data) {
    if (id == null) {
      return;
    }

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
            .equals(serialize(prevVal.value), serialize(data.value));

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
      log.info("[Cache] ResourcePool: $id changed");
      // notifyListeners();
    }
    log.info("[Cache] ResourcePool: $id collected, timestamp changed from ${prevVal?.timestamp} to $ts, "
    " invalidated changed from ${prevVal?.invalidated} to ${data.invalidated}");

    save(this.data);
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

  ResourcePoolBase({
    required this.users,
    required this.groups,
    required this.events,
  });

  static ResourcePoolBase _load(String? channelName, Box box) {
    // Hive.init(null);
    // final box = await Hive.openBox("cache");

    channelName ??= "default";

    return ResourcePoolBase(
      users: Resource.load(
          box, "$channelName-users", (u) => u.data, (d) => User.fromJson(d)),
      groups: Resource.load(
          box, "$channelName-groups", (u) => u.data, (d) => Group.fromJson(d)),
      events: Resource.load(
          box, "$channelName-events", (u) => u.data, (d) => Event.fromJson(d)),
    );
  }

  static Future<ResourcePoolBase> load(String? channelName) async {
    Hive.init(null);
    final box = await Hive.openBox("cache");

    return _load(channelName, box);
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
