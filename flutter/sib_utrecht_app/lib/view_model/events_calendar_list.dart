import 'dart:async';
import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/view_model/events_provider.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/event.dart';
import '../view_model/event_participation.dart';
import '../view_model/event_placement.dart';
import '../log.dart';

import 'annotated_event.dart';

class EventsCalendarList with ChangeNotifier {
  List<AnnotatedEvent> events = [];
  // final Future<void> Function(APIConnector?, int, bool) _setEventRegistration;

  ActionFeedback feedback;
  final EventsProvider eventsProvider;

  Future<void>? get loading => eventsProvider.loading;
  void refresh() => eventsProvider.refresh();

  EventsCalendarList({required this.eventsProvider, required this.feedback}) {
    eventsProvider.addListener(_reprocessCached);
    // _eventsProvider.addListener(_reprocessCached);
    // _bookingsProvider.addListener(_reprocessCached);

    _reprocessCached();
  }

  @override
  void dispose() {
    eventsProvider.removeListener(_reprocessCached);
    super.dispose();
  }

  Iterable<AnnotatedEvent> placeEvent(Event event, ActionFeedback feedback) sync* {
    var participation = EventParticipation.fromEvent(event,
        isParticipating:
            eventsProvider.isMeParticipating(event.eventId) == true,
        setParticipating: (value) => eventsProvider
            .setMeParticipating(event.eventId, value, feedback: feedback),
        isDirty: eventsProvider.isMeBookingDirty(event.eventId));

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
    // if (_bookingsProvider.cachedId > _dirtyStateSequence) {
    //   _dirtyStateSequence = _bookingsProvider.cachedId;
    //   _dirtyBookState = {};
    // }

    // var cachedEvents = _eventsProvider.cached;
    // if (cachedEvents == null) {
    //   if (events.isNotEmpty) {
    //     events = [];
    //     notifyListeners();
    //   }
    //   return;
    // }

    // log.fine("Bookings are: ${_bookingsProvider.cached}");

    events =
      eventsProvider.events
        .map((v) => placeEvent(v, feedback))
        .flattened
        .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
        // .map(buildItem)
        .toList();

    // log.fine("Events are now: ${events
    // .where((e) => e.placement?.date.isAfter(DateTime(2023, 11, 10)) == true)
    // .map((e) => e.participation?.isParticipating)}");

    notifyListeners();
  }

}
