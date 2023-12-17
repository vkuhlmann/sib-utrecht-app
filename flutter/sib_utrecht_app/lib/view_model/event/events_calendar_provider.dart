import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/event_placement.dart';
import 'package:sib_utrecht_app/view_model/event/events_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/api_connector_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/bookings_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/events_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/participation_provider.dart';

Iterable<AnnotatedEvent> placeEvent(
    Event event, EventParticipation participation) sync* {
  // var participation = EventParticipation.fromEvent(event,
  //     isParticipating:
  //         eventsProvider.isMeParticipating(event.eventId) == true,
  //     setParticipating: (value) => eventsProvider
  //         .setMeParticipating(event, value, feedback: feedback),
  //     isDirty: eventsProvider.isMeBookingDirty(event.eventId));

  // var participation = eventsProvider.getMeParticipation(event, feedback: feedback);

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
        event: event, participation: participation, placement: placement);
  }
}

List<AnnotatedEvent> toCalendarList(List<AnnotatedEvent> events) {
  return events
      .map((e) => placeEvent(e, e.participation!))
      // EventParticipation.fromEvent(
      //   e,
      //   isParticipating: participating.contains(e.eventId),
      //   setParticipating: (value) => setMeParticipation(
      //       api: api, event: e, value: value, feedback: feedback),
      // ),
      // feedback))
      .flattened
      .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
      .toList();
}

class CalendarListProvider extends StatelessWidget {
  final Widget Function(BuildContext context, List<AnnotatedEvent> data)
      builder;
  final ActionFeedback feedback;

  const CalendarListProvider(
      {super.key, required this.builder, required this.feedback});

  // @override
  // Widget build(BuildContext context) => ApiConnectorProvider(
  //     builder: (context, connector) => EventsProvider(
  //         builder: (context, events) => BookingsProvider(
  //             builder: (context, bookings) => builder(context,
  //                 toCalendarList(connector, events, bookings, feedback)))));

  @override
  Widget build(BuildContext context) => EventsProvider(
      builder: (context, events, _) => EventParticipationProvider.Multiplexed(
          query: events,
          builder: (context, annotatedEvents) =>
              builder(context, toCalendarList(annotatedEvents))));
}

// class EventsCalendarList with ChangeNotifier {
//   List<AnnotatedEvent> events = [];

//   ActionFeedback feedback;
//   // final EventsProvider eventsProvider;

//   Future<void>? get loading => eventsProvider.loading;
//   void refresh() => eventsProvider.refresh();

//   EventsCalendarList({required this.eventsProvider, required this.feedback}) {
//     eventsProvider.addListener(_reprocessCached);

//     _reprocessCached();
//   }

//   @override
//   void dispose() {
//     eventsProvider.removeListener(_reprocessCached);
//     super.dispose();
//   }

//   void _reprocessCached() {
//     events = eventsProvider.events.map((v) => placeEvent(v, feedback));

//     notifyListeners();
//   }
// }
