import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class Resource<T> extends ChangeNotifier {
  final Map<String, FetchResult<T>> data = {};

  FetchResult<T>? operator [](String id) => data[id];

  void collect(String? id, FetchResult<T> data) {
    if (id == null) {
      return;
    }

    final prevVal = this.data[id];
    final ts = data.timestamp;
    if (ts != null && prevVal?.timestamp?.isAfter(ts) == true) {
      return;
    }

    this.data[id] = data;
    if (prevVal?.value != data.value) {
      log.info("ResourcePool: $id changed");
      // notifyListeners();
    }
  }

  void invalidate() {
    data.clear();
    notifyListeners();
  }

  void invalidateId(String id) {
    data.remove(id);
    notifyListeners();
  }
}

class ResourcePoolBase {
  final Resource<User> users = Resource();
  final Resource<Group> groups = Resource();
  final Resource<Event> events = Resource();

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
