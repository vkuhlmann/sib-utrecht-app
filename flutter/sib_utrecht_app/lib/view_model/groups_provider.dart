// import 'package:flutter/material.dart';
// import 'package:sib_utrecht_app/model/api_connector.dart';
// import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
// import 'package:sib_utrecht_app/model/group.dart';
// import 'package:sib_utrecht_app/model/api/groups.dart';
// import 'package:sib_utrecht_app/view_model/cached_provider.dart';

// class GroupsProvider with ChangeNotifier {
//   final CachedProvider<List<Group>> _groupsProvider =
//       CachedProvider<List<Group>>(obtain: (c) => Groups(c).list());

//   List<Group> groups = [];

//   Future<APIConnector>? _apiConnector;
//   Future<void>? loading;

//   GroupsProvider() {
//     _groupsProvider.addListener(_reprocessCached);
//   }

//   void _reprocessCached() {
//     var cachedEvents = _groupsProvider.cached;
//     if (cachedEvents == null) {
//       if (groups.isNotEmpty) {
//         groups = [];
//         notifyListeners();
//       }
//       return;
//     }

//     groups = cachedEvents.value;
//     notifyListeners();
//   }

//   void setApiConnector(Future<CacherApiConnector> conn) {
//     if (_apiConnector == conn) {
//       return;
//     }
//     _apiConnector = conn;
//     loading = _doLoad(conn);
//   }

//   Future<void> _doLoad(Future<CacherApiConnector> conn) async {
//     await _groupsProvider.setConnector(conn);

//     await _groupsProvider.loading;
//     _reprocessCached();
//   }

//   void refresh() {
//     _groupsProvider.invalidate(doRefresh: true);

//     loading = Future.wait([_groupsProvider.loading]);
//     notifyListeners();
//   }
// }
