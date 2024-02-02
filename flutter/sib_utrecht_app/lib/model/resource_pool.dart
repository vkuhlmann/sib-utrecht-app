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
import 'package:sib_utrecht_app/model/fetch_result.dart';

class Resource<T extends CacheableResource> {
  final Box box;
  final String name;
  final Map<String, DateTime> invalidationTimestamps = {};

  Resource(
      {
      required this.name,
      required this.box
      });

  String getKey(String id) => "$name-$id";

  FetchResult<T>? operator [](String id) {
    // log.info("[Cache] ResourcePool: $id retrieved, timestamp: ${data[id]?.timestamp}, invalidated: ${data[id]?.invalidated}");

    final raw = box.get(getKey(id));
    if (raw == null) {
      return null;
    }

    final a = FetchResult.fromJson<Map>(raw, (v) => v as Map);
    final val = a.mapValue((p0) => CacheableResource.fromJson<T>(
        p0, CollectingUnpacker(anchor: a, pool: null)));

    // var val = data[id];
    // if (val == null) {
    //   return null;
    // }

    final invalidTs = invalidationTimestamps[id];
    if (invalidTs != null && val.timestamp?.isAfter(invalidTs) != true) {
      return val.asInvalidated();
    }

    return val;
  }

  void _setValue(String id, FetchResult<T> val) {
    box.put(getKey(id), val.toJson((v) => v.toJson())).catchError((e) {
      log.severe("Failed to save $id to cache: $e");
      throw e;
    });
  }

  void collect(FetchResult<T> data) {
    final id = data.value.id;
    // if (id == null) {
    //   return;
    // }

    final prevVal = this[id];
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

    // this.data[id] = data;
    _setValue(id, data);

    if (hasValueChanged) {
      log.info("[Cache] ResourcePool: $id changed ($name)");
      // notifyListeners();
    }
    log.info(
        "[Cache] ResourcePool: $id collected, timestamp changed from ${prevVal?.timestamp} to $ts, "
        " invalidated changed from ${prevVal?.invalidated} to ${data.invalidated}");

    // var boxPutVal = this
    //     .data
    //     .map((key, value) => MapEntry(key, value.toJson((v) => v.toJson())));

    // final String boxPutValStr = jsonEncode(boxPutVal);

    // if (name == "default-eventBodies") {
    //   log.info("Saving $name to cache:\n$boxPutValStr");
    // }

    // box.put(name, boxPutVal).catchError((e) {
    //   log.severe("Failed to save $name to cache: $e");
    // });
    // save(this.data);
  }

  // void invalidate() {
  //   DateTime invalidationTimestamp = DateTime.now();

  //   log.info("[Cache] Invalidating $name");
  //   // data.clear();
  //   for (var entry in data.entries.toList()) {
  //     data[entry.key] = entry.value.asInvalidated();
  //     invalidationTimestamps[entry.key] = invalidationTimestamp;
  //   }

  //   notifyListeners();
  // }

  bool silentInvalidateId(String id) {
    DateTime invalidationTimestamp = DateTime.now();
    invalidationTimestamps[id] = invalidationTimestamp;

    // data.remove(id);
    var val = this[id];
    if (val == null) {
      return false;
    }

    log.info("[Cache] Invalidating $id in $name");
    _setValue(id, val.asInvalidated());

    return true;
  }
}

class ResourcePool extends ChangeNotifier {
  static const String version = "2024-02-02";

  Box box;
  String channelName;

  ResourcePool(
      {
      required this.box,
      required this.channelName}) {
      checkVersion();
    }

  void checkVersion() {
    final boxVersion = box.get("version");
    if (boxVersion != version) {
      box.clear();
    }
    box.put("version", version);
  }

  static Future<ResourcePool> load(String? channelName) async {
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

    return ResourcePool(channelName: channelName ?? "default", box: box);
  }

  Resource<T> getResource<T extends CacheableResource>() {
    return Resource<T>(box: box, name: _getResourceName(T));
  }

  String _getResourceName(Type t) => "$channelName-$t";

  FetchResult<T>? get<T extends CacheableResource>(String id) =>
      getResource<T>()[id];

  void collect<T extends CacheableResource>(FetchResult<T> data) =>
      getResource<T>().collect(data);

  void invalidateId<T extends CacheableResource>(String id) {
    bool changed = getResource<T>().silentInvalidateId(id);

    if (changed) {
      notifyListeners();
    }
  }
}
