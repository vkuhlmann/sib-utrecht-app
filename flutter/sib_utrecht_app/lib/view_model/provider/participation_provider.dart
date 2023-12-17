import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/events_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/api_connector_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/bookings_provider.dart';

class EventParticipationProvider {
  // static Widget Multiplexed({query, builder}) => MultiplexedProvider(
  //     query: query,
  //     builder: builder,
  //     errorTitle: (loc) => loc.couldNotLoad(loc.dataParticipation),
  //     changeListener: (p) => p.events,
  //     obtain: (int id, c) =>
  //         Events(c).getEvent(eventId: id, includeImage: true));

  // static Widget Single(
  //         {required int query,
  //         required Widget Function(BuildContext, Event) builder}) =>
  //     SingleProvider(
  //       query: query,
  //       builder: builder,
  //       errorTitle: (loc) => loc.couldNotLoad(loc.dataParticipation}),
  //       changeListener: (p) => p.events,
  //       obtain: (int id, c) =>
  //           Events(c).getEvent(eventId: id, includeImage: true),
  //     );

  static Widget Multiplexed(
          {required List<Event> query,
          required Widget Function(
                  BuildContext context, List<AnnotatedEvent> events)
              builder}) =>
      Builder(
          builder: (context) => ApiConnectorProvider(
              builder: (context, connector) => BookingsProvider(
                  builder: (context, bookings, _) => builder(
                      context,
                      query
                          .map((e) => 
                          AnnotatedEvent(event: e, participation:
                          EventParticipation.fromEvent(
                                e,
                                isParticipating: bookings.contains(e.id),
                                setParticipating: (value) => setMeParticipation(
                                    api: connector,
                                    event: e,
                                    value: value,
                                    feedback: ActionFeedback(
                                      sendConfirm: (m) =>
                                          ActionFeedback.sendConfirmToast(
                                              context, m),
                                      sendError: (m) =>
                                          ActionFeedback.showErrorDialog(
                                              context, m),
                                    )),
                              )))
                          .toList()))));

  static Widget Single(
          {required Event query,
          required Widget Function(BuildContext, AnnotatedEvent)
              builder}) =>
      Multiplexed(
          query: [query],
          builder: (context, events) => builder(context, events.first));
}
