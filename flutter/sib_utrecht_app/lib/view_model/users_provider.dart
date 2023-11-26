// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:sib_utrecht_app/components/actions/feedback.dart';
// import 'package:sib_utrecht_app/model/api_connector.dart';
// import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
// import 'package:sib_utrecht_app/model/group.dart';
// import 'package:sib_utrecht_app/model/groups.dart';
// import 'package:sib_utrecht_app/model/user.dart';
// import 'package:sib_utrecht_app/view_model/cached_provider.dart';
// import 'package:sib_utrecht_app/view_model/event_participation.dart';

// import '../log.dart';

// class UsersProvider with ChangeNotifier {
//   // final CachedProvider<List<Group>> _usersProvider =
//   //     CachedProvider<List<Group>>(obtain: (c) => Groups(c).list());

//   // final Map<String, CachedProvider<List<Group>> _usersProvider =
//   //     CachedProvider<List<Group>>(obtain: (c) => Groups(c).list());

//   // final CachedProvider<Set<int>> _bookingsProvider =
//   //     CachedProvider<Set<int>>(obtain: (c) => Bookings(c).getMyBookings());

//   Map<String, User> users = {};

//   Future<APIConnector>? _apiConnector;
//   // Set<int> _dirtyBookState = {};
//   // int _dirtyStateSequence = 0;
//   Future<void>? loading;

//   final List<Future> _pendingMutations = [];

//   GroupsProvider() {
//     _groupsProvider.addListener(_reprocessCached);
//     // _bookingsProvider.addListener(_reprocessCached);
//   }

//   // EventParticipation getMeParticipation(Event event,
//   //     {required ActionFeedback feedback}) {
//   //   return EventParticipation.fromEvent(event,
//   //       isParticipating: isMeParticipating(event.eventId) == true,
//   //       setParticipating: (value) =>
//   //           setMeParticipating(event.eventId, value, feedback: feedback),
//   //       isDirty: isMeBookingDirty(event.eventId));
//   // }

//   // bool? isMeParticipating(int eventId) {
//   //   return _bookingsProvider.cached?.contains(eventId);
//   // }

//   // bool isMeBookingDirty(int eventId) {
//   //   return _bookingsProvider.cached == null ||
//   //       _dirtyBookState.contains(eventId);
//   // }

//   void _reprocessCached() {
//     // log.fine("Reassembling data for events calendar list");
//     // if (_bookingsProvider.cachedId > _dirtyStateSequence) {
//     //   _dirtyStateSequence = _bookingsProvider.cachedId;
//     //   _dirtyBookState = {};
//     // }

//     var cachedEvents = _groupsProvider.cached;
//     if (cachedEvents == null) {
//       if (groups.isNotEmpty) {
//         groups = [];
//         notifyListeners();
//       }
//       return;
//     }

//     // log.fine("Bookings are: ${_bookingsProvider.cached}");

//     groups = cachedEvents
//         // .map((v) => placeEvent(v, feedback))
//         // .flattened
//         // .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
//         // .map(buildItem)
//         .toList();

//     // log.fine("Events are now: ${events
//     // .where((e) => e.placement?.date.isAfter(DateTime(2023, 11, 10)) == true)
//     // .map((e) => e.participation?.isParticipating)}");

//     notifyListeners();
//   }

//   void setApiConnector(Future<CacherApiConnector> conn) {
//     if (_apiConnector == conn) {
//       return;
//     }
//     _apiConnector = conn;
//     // _eventsProvider.setConnector(conn);
//     // _bookingsProvider.setConnector(conn);
//     // if (conn != null) {
//     loading = _doLoad(conn);
//     // }
//   }

//   Future<void> _doLoad(Future<CacherApiConnector> conn) async {
//     // await _eventsProvider.setConnector(conn);
//     // await _bookingsProvider.setConnector(conn);
//     await _groupsProvider.setConnector(conn);

//     // await Future.wait([_eventsProvider.loading, _bookingsProvider.loading]);
//     await _groupsProvider.loading;
//   }

//   void refresh() {
//     // var conn = _apiConnector;
//     // if (conn != null) {
//     //   loading = _doLoad(conn);
//     // }

//     log.info("Refreshing calendar");
//     _groupsProvider.invalidate(doRefresh: true);
//     // _bookingsProvider.invalidate(doRefresh: true);

//     loading = Future.wait([_groupsProvider.loading]);
//     // loading = Future.delayed(const Duration(milliseconds: 1500)).then((value) {
//     //   throw Exception("Dit is een test");
//     // });
//     // log.fine("Groups provider loading is now $loading");
//     notifyListeners();
//   }

//   // void loadEarlier() {}

//   // void setMeParticipating(int eventId, bool value,
//   //     {bool initiateRefresh = true, required ActionFeedback feedback}) {
//   //   // _dirtyStateSequence = _bookingsProvider.firstValidId;
//   //   // _dirtyBookState.add(eventId);

//   //   var fut = Future.value(_apiConnector).then((conn) => _setMeParticipation(
//   //       api: conn, eventId: eventId, value: value, feedback: feedback));
//   //   _pendingMutations.add(fut);

//   //   notifyListeners();

//   //   if (!initiateRefresh) {
//   //     fut.then((value) {
//   //       _pendingMutations.remove(fut);
//   //       _dirtyBookState.remove(eventId);
//   //       notifyListeners();
//   //     });
//   //     return;
//   //   }

//   //   fut.whenComplete(() {
//   //     // setState(() {
//   //     _pendingMutations.remove(fut);
//   //     _dirtyStateSequence = _bookingsProvider.firstValidId;

//   //     _bookingsProvider.invalidate(doRefresh: true);
//   //     // notifyListeners();
//   //     // });
//   //   });
//   // }
// }
