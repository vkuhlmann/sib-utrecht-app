import 'dart:async';
import "package:collection/collection.dart";
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/event_placement.dart';
import 'package:sib_utrecht_app/view_model/event/events_provider.dart';


class EventsCalendarList with ChangeNotifier {
  List<AnnotatedEvent> events = [];

  ActionFeedback feedback;
  final EventsProvider eventsProvider;

  Future<void>? get loading => eventsProvider.loading;
  void refresh() => eventsProvider.refresh();

  EventsCalendarList({required this.eventsProvider, required this.feedback}) {
    eventsProvider.addListener(_reprocessCached);

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
          );
    }
  }

  void _reprocessCached() {
    events =
      eventsProvider.events
        .map((v) => placeEvent(v, feedback))
        .flattened
        .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
        // .map(buildItem)
        .toList();

    notifyListeners();
  }

}
