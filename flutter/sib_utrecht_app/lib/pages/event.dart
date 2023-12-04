import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/event/event_participants.dart';
import 'package:sib_utrecht_app/components/event/thumbnail.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/signup_indicator.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/event_provider_notifier.dart';
import 'package:sib_utrecht_app/view_model/provider/event_participants_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/event_provider.dart';

import '../globals.dart';
import '../utils.dart';
import '../view_model/async_patch.dart';
import '../components/actions/alerts_panel.dart';
import '../components/api_access.dart';
import '../components/actions/action_refresh.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.eventId}) : super(key: key);
  final int eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class EventHeader extends StatelessWidget {
  final AnnotatedEvent event;

  const EventHeader(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var eventEnd = event.end;

    return Column(children: [
      Row(children: [
        Expanded(
            child: Card(
                child: ListTile(
                    title: Text(event
                        .getLocalEventName(Localizations.localeOf(context)))))),
        SignupIndicator(event: event),
        IconButton(
            onPressed: () {
              router.goNamed("event_edit",
                  pathParameters: {"event_id": event.eventId.toString()});
            },
            icon: const Icon(Icons.edit)),
      ]),
      if (event.location != null)
        Card(
            child: ListTile(
                title: Text(
                    "${AppLocalizations.of(context)!.eventLocation}: ${event.location.toString()}"))),

      Card(
          child: ListTile(
              title: Wrap(children: [
        SizedBox(
            width: 80,
            child: Text("${AppLocalizations.of(context)!.eventStarts}: ")),
        Wrap(children: [
          SizedBox(
              width: 260,
              child: Text(DateFormat.yMMMMEEEEd(
                      Localizations.localeOf(context).toString())
                  .format(event.start))),
          // const SizedBox(width: 20),
          Text(DateFormat.Hm(Localizations.localeOf(context).toString())
              .format(event.start))
        ])
      ]))),
      if (eventEnd != null)
        Card(
            child: ListTile(
                title: Wrap(children: [
          SizedBox(
              width: 80,
              child: Text("${AppLocalizations.of(context)!.eventEnds}: ")),
          Wrap(children: [
            SizedBox(
                width: 260,
                child: Text(DateFormat.yMMMMEEEEd(
                        Localizations.localeOf(context).toString())
                    .format(eventEnd))),
            // const SizedBox(width: 20),
            Text(DateFormat.Hm(Localizations.localeOf(context).toString())
                .format(eventEnd))
          ])
        ]))),
      // Table(columnWidths: const {
      //   0: IntrinsicColumnWidth(),
      //   1: FlexColumnWidth(),
      //   2: IntrinsicColumnWidth(),
      //   3: FlexColumnWidth()
      // }, children: <TableRow>[
      //   TableRow(children: <Widget>[
      //     const Text("Start: "),
      //     LocaleDateFormat(
      //         date: event.start, format: "yMMMMEEEEd"),
      //     const SizedBox(width: 30),
      //     LocaleDateFormat(date: event.start, format: "Hm")
      //   ]),
      //   TableRow(children: <Widget>[
      //     const Text("Eindigt: "),
      //     LocaleDateFormat(
      //         date: event.end, format: "yMMMMEEEEd"),
      //     const SizedBox(width: 30),
      //     LocaleDateFormat(date: event.end, format: "Hm")
      //   ])
      // ]),
    ]);
  }
}

class EventDescription extends StatelessWidget {
  final AnnotatedEvent event;

  const EventDescription(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (description, _) = event.extractDescriptionAndThumbnail();

    return Card(
        child: ListTile(
            title: Text(AppLocalizations.of(context)!.eventDescription),
            subtitle: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: HtmlWidget(
                  // ((event.data["post_content"] ?? "") as String).replaceAll("\r\n\r\n", "<br/><br/>"),
                  description ?? "",
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                ))));
  }
}

class EventPageContents extends StatelessWidget {
  // final EventProviderNotifier eventProvider;
  final EventParticipation? eventParticipation;

  final AnnotatedEvent event;
  // final bool expectParticipants;

  const EventPageContents(
      //this.eventProvider,
      {Key? key,
      required this.eventParticipation,
      required this.event})
      :
        // expectParticipants = eventProvider.doesExpectParticipants(),
        super(key: key);

  // static EventPageContents fromProvider(EventProviderNotifier eventProvider,
  //     {Key? key, EventParticipation? eventParticipation}) {
  //   var cachedEvent = eventProvider.event.cached;
  //   AnnotatedEvent? event;
  //   if (cachedEvent != null) {
  //     event = AnnotatedEvent(
  //       event: cachedEvent,
  //       participation: eventParticipation,
  //       participants: eventProvider.participants.cached,
  //     );
  //   }

  //   return EventPageContents(eventProvider,
  //       eventParticipation: eventParticipation, event: event);
  // }

  @override
  Widget build(BuildContext context) {
    // ActionProvider actionProvider = ActionProvider.of(context);
    // actionProvider.controller.widgets.clear();
    // actionProvider.controller.widgets.add(const Icon(Icons.abc));
    // actionProvider.controller.widgets = [
    //   const Icon(Icons.abc)
    // ];

    return SelectionArea(
        child: CustomScrollView(slivers: [
      SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          sliver: SliverList.list(children: [
            const SizedBox(height: 20),
            // if (eventProvider.event.cached == null)
            //   FutureBuilderPatched(
            //       future: eventProvider.event.loading,
            //       builder: (eventContext, eventSnapshot) {
            //         if (eventSnapshot.hasError) {
            //           return Padding(
            //               padding: const EdgeInsets.all(32),
            //               child:
            //                   Center(child: formatError(eventSnapshot.error)));
            //         }
            //         if (eventSnapshot.connectionState ==
            //             ConnectionState.waiting) {
            //           return const Padding(
            //               padding: EdgeInsets.all(32),
            //               child: Center(child: CircularProgressIndicator()));
            //         }

            //         return const SizedBox();
            //       }),
            ...(() {
              // final AnnotatedEvent? event = this.event;
              // if (event == null) {
              //   return [];
              // }

              return [
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(children: [
                          EventHeader(event),
                          EventDescription(event),
                          EventThumbnail(event),
                          const SizedBox(height: 32),
                          EventParticipantsProvider(
                              eventId: event.eventId,
                              builder: (context, participants) {
                                // if ()
                                return EventParticipants(event,
                                    participants: participants);

                                // if (expectParticipants) ...[
                                //   EventParticipants(event, eventProvider: eventProvider)
                                // ]
                              })
                        ])))
              ];
            }())
          ])),
    ]));
  }
}

class _EventPageState extends State<EventPage> {
  final AlertsPanelController _alertsPanelController = AlertsPanelController();
  late EventProviderNotifier _eventProvider;

  @override
  void initState() {
    super.initState();

    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "details", status: "loading", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "details", status: "done", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "participants", status: "loading", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "participants", status: "done", data: {}));

    _eventProvider = EventProviderNotifier(
        eventId: widget.eventId, apiConnector: null, cachedEvent: null);
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).connector;

    if (apiConnector != _eventProvider.apiConnector) {
      log.info(
          "Event page: API connector changed from ${_eventProvider.apiConnector} "
          " to $apiConnector, reloading event data");

      var cachedEv = ResourcePoolAccess.of(context)
          .pool
          .eventsProvider
          .events
          .firstWhereOrNull((element) => element.eventId == widget.eventId);

      _eventProvider = EventProviderNotifier(
          eventId: widget.eventId,
          apiConnector: apiConnector,
          cachedEvent: cachedEv == null ? null : FetchResult(cachedEv, null));
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var provEvents = ResourcePoolAccess.of(context).pool.eventsProvider;
    return WithSIBAppBar(
        actions: const [],
        child: ActionSubscriptionAggregator(
            child: EventProvider.Single(
                query: widget.eventId,
                builder: (context, event) {
                  // ListenableBuilder(
                  //     listenable: Listenable.merge([_eventProvider, provEvents]),
                  //     builder: (context, _) {
                  log.fine(
                      "Building event page for event id ${widget.eventId}");

                  // var prov = _eventProvider;
                  // var cachedEvent = prov.event.cached;

                  EventParticipation? participation;
                  // if (event != null) {
                  participation = provEvents.getMeParticipation(event,
                      feedback: ActionFeedback(
                        sendConfirm: (m) =>
                            ActionFeedback.sendConfirmToast(context, m),
                        sendError: (m) =>
                            ActionFeedback.showErrorDialog(context, m),
                      ));
                  // }

                  return
                      // WithSIBAppBar(
                      //     actions: [
                      //       ActionRefreshButton(
                      //           refreshFuture: Future.wait([
                      //             _eventProvider.event.loading,
                      //             if (prov.doesExpectParticipants())
                      //               _eventProvider.participants.loading
                      //           ]).then((_) => DateTime.now()),
                      //           triggerRefresh: _eventProvider.refresh)
                      //     ],
                      //     child:
                      Column(children: [
                    Expanded(
                        child: EventPageContents(
                            event: AnnotatedEvent(
                              event: event,
                              participation: participation,
                              // participants: eventProvider.participants.cached,
                            ),
                            eventParticipation: participation)),
                    // AlertsPanel(
                    //     controller: _alertsPanelController,
                    //     loadingFutures: [
                    //       AlertsFutureStatus(
                    //           component: "details",
                    //           future: _eventProvider.event.loading,
                    //           data: {
                    //             "isRefreshing": _eventProvider.event.cached != null
                    //           }),
                    //       if (prov.doesExpectParticipants())
                    //         AlertsFutureStatus(
                    //             component: "participants",
                    //             future: _eventProvider.participants.loading,
                    //             data: {
                    //               "isRefreshing":
                    //                   _eventProvider.participants.cached != null
                    //             })
                    //     ])
                  ]);
                })));
  }
}
