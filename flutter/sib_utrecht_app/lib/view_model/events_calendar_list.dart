import 'dart:async';
import 'dart:convert';
// import 'dart:math';
import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/api_connector.dart';
import '../model/event.dart';
import '../view_model/cached_provider.dart';
import '../view_model/event_participation.dart';
import '../view_model/event_placement.dart';
import '../log.dart';

import 'annotated_event.dart';

class EventsCalendarList with ChangeNotifier {
  List<AnnotatedEvent> events = [];
  Future<void>? loading;

  Set<int> _dirtyBookState = {};
  int _dirtyStateSequence = 0;

  final List<Future> _pendingMutations = [];
  final Future<void> Function(int, bool) _setEventRegistration;

  Future<APIConnector>? _apiConnector;

  final CachedProvider<List<Event>, Map> _eventsProvider = CachedProvider<
          List<Event>, Map>(
      getCached: (c) => c.then((conn) => conn?.getCached("/events")),
      // getCached: (c) {
      //   throw Exception("This is a test");
      //   return c.then((conn) => conn?.getCached("/events"));
      // },
      getFresh: (c) => c.get("/events"),
      // getFresh: (c) {
      //   throw Exception("This is a test2");
      //   return c.get("/events");
      // },
      // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("events")),
      postProcess: (eventsRes) =>
          (eventsRes["data"]["events"] as Iterable<dynamic>)
              .map((e) => (e as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key as String, value)))
              .map((e) => Event.fromJson(e))
              .toList());

  final CachedProvider<Set<int>, Map> _bookingsProvider = CachedProvider<
          Set<int>, Map>(
      getCached: (c) => c.then((conn) => conn?.getCached("/users/me/bookings")),
      getFresh: (c) => c.get("/users/me/bookings"),
      // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("users/me/bookings")),
      postProcess: (bookingsRes) =>
          (bookingsRes["data"]["bookings"] as Iterable<dynamic>)
              .where((v) => v["booking"]["status"] == "approved")
              .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
              .toSet());

  EventsCalendarList({required setEventReg})
      : _setEventRegistration = setEventReg {
    _eventsProvider.addListener(_reprocessCached);
    _bookingsProvider.addListener(_reprocessCached);
  }

  void setParticipating(int eventId, bool value,
  {bool initiateRefresh = true}) {
    _dirtyStateSequence = _bookingsProvider.firstValidId;
    _dirtyBookState.add(eventId);

    var fut = _setEventRegistration(eventId, value);
    _pendingMutations.add(fut);

    notifyListeners();

    if (!initiateRefresh) {
      fut.then((value) {
          _pendingMutations.remove(fut);
          _dirtyBookState.remove(eventId);
          notifyListeners();
      });
      return;
    }

    fut.whenComplete(() {
      // setState(() {
      _pendingMutations.remove(fut);
      _dirtyStateSequence = _bookingsProvider.firstValidId;

      _bookingsProvider.invalidate(doRefresh: true);
      // notifyListeners();
      // });
    });
  }

  Iterable<AnnotatedEvent> placeEvent(Event event) sync* {
    var participation = EventParticipation.fromEvent(event,
        isParticipating:
            _bookingsProvider.cached?.contains(event.eventId) == true,
        setParticipating: (value) => setParticipating(event.eventId, value),
        isDirty: _bookingsProvider.cached == null ||
            _dirtyBookState.contains(event.eventId));

    if (event.end != null && event.end!.difference(event.start).inDays > 10) {
      yield AnnotatedEvent(
          event: event, participation: participation, placement: null);
      return;
    }

    // var startDay = e.start.subtract(const Duration(hours: 3));
    // startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);

    var startDay = event.start;
    startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);
    var endDay = event.end ?? event.start;
    if (!startDay.isBefore(endDay)) {
      endDay = startDay.add(const Duration(hours: 1));
    }

    for (var i = startDay;
        i.isBefore(endDay);
        i = i.add(const Duration(days: 1))) {
      var placement = EventPlacement(
          date: i == startDay ? event.start : i, isContinuation: i != startDay);
      yield AnnotatedEvent(
          event: event, participation: participation, placement: placement
          // ValueKey(("eventsItem", event.eventId, i)),
          );
    }

    // EventsItem(
    //   date: e.end,
    //   key: ValueKey(e.eventId),
    //   event: e,
    //   isParticipating:
    //       bookingsProvider.cached?.contains(e.eventId) == true,
    //   isDirty: bookingsProvider.cached == null ||
    //       _dirtyBookState.contains(e.eventId),
    //   setParticipating: (value) =>
    //       scheduleEventRegistration(e.eventId, value));
  }

  void _reprocessCached() {
    log.fine("Reassembling data for events calendar list");
    if (_bookingsProvider.cachedId > _dirtyStateSequence) {
      _dirtyStateSequence = _bookingsProvider.cachedId;
      _dirtyBookState = {};
    }

    var cachedEvents = _eventsProvider.cached;
    if (cachedEvents == null) {
      if (events.isNotEmpty) {
        events = [];
        notifyListeners();
      }
      return;
    }

    events = cachedEvents
        .map((v) => placeEvent(v))
        .flattened
        .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
        // .map(buildItem)
        .toList();

    notifyListeners();
  }

  void setApiConnector(Future<APIConnector> conn) {
    if (_apiConnector == conn) {
      return;
    }
    _apiConnector = conn;
    // _eventsProvider.setConnector(conn);
    // _bookingsProvider.setConnector(conn);
    // if (conn != null) {
    loading = _doLoad(conn);
    // }
  }

  Future<void> _doLoad(Future<APIConnector> conn) async {
    await _eventsProvider.setConnector(conn);
    await _bookingsProvider.setConnector(conn);

    await Future.wait([
      _eventsProvider.loading,
      _bookingsProvider.loading
    ]);
  }

  void refresh() {
    // var conn = _apiConnector;
    // if (conn != null) {
    //   loading = _doLoad(conn);
    // }

    log.info("Refreshing calendar");
    _eventsProvider.invalidate(doRefresh: true);
    _bookingsProvider.invalidate(doRefresh: true);

    loading = Future.wait([
      _eventsProvider.loading,
      _bookingsProvider.loading
    ]);
    // loading = Future.delayed(const Duration(milliseconds: 1500)).then((value) {
    //   throw Exception("Dit is een test");
    // });
    log.fine("Events calendar loading is now $loading");
    notifyListeners();
  }

  void loadEarlier() {}
}
