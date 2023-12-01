import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/action_provider.dart';
import 'package:sib_utrecht_app/components/event/thumbnail.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/signup_indicator.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/view_model/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event_provider.dart';

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
    final (description, _) =
        EventProvider.extractDescriptionAndThumbnail(event);

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

class EventParticipants extends StatelessWidget {
  final AnnotatedEvent event;
  final EventProvider eventProvider;

  const EventParticipants(this.event, {Key? key, required this.eventProvider})
      : super(key: key);

  // Widget buildParticipant(BuildContext context, AnnotatedUser participant) {
  //   return EntityTile(entity: participant);
  //   // return Card(
  //   //     child: ListTile(
  //   //         title: Text(participant.user.name),
  //   //         subtitle: Text(participant.user.email)));
  // }

  @override
  Widget build(BuildContext context) {
    // return SliverPadding(
    //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     sliver: SliverList(
    //         delegate: SliverChildListDelegate([

    var participantsCached = event.participants;

    return Column(children: [
      Card(
          child: ListTile(
              title: Text(
                  "${AppLocalizations.of(context)!.eventParticipants} (${eventProvider.participants.cached?.length ?? 'n/a'}):"))),
      if (participantsCached == null)
        FutureBuilderPatched(
            future: eventProvider.participants.loading,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: formatError(snapshot.error)));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return const SizedBox();
            }),
      if (participantsCached == [])
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Text(
                    AppLocalizations.of(context)!.eventNoParticipantsYet))),
      if (participantsCached != null && participantsCached.isNotEmpty)
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 32),
            child: Wrap(
                // crossAxisCount: 6,
                // shrinkWrap: true,
                spacing: 10,
                children: [
                  ...participantsCached.map<Widget>((e) =>
                      // Padding(
                      //       padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                      // child:
                      //Card(child: ListTile(title: Text(e)))
                      // Card(child:
                      SizedBox(
                          width: 96, height: 80, child: EntityTile(entity: e))),
                  const SizedBox(height: 32),
                ]))
    ]);
  }
}

class EventPageContents extends StatelessWidget {
  final EventProvider eventProvider;
  final EventParticipation? eventParticipation;

  final AnnotatedEvent? event;
  final bool expectParticipants;

  EventPageContents(this.eventProvider,
      {Key? key, required this.eventParticipation, required this.event})
      : expectParticipants = eventProvider.doesExpectParticipants(),
        super(key: key);

  static EventPageContents fromProvider(EventProvider eventProvider,
      {Key? key, EventParticipation? eventParticipation}) {
    var cachedEvent = eventProvider.event.cached;
    AnnotatedEvent? event;
    if (cachedEvent != null) {
      event = AnnotatedEvent(
        event: cachedEvent,
        participation: eventParticipation,
        participants: eventProvider.participants.cached,
      );
    }

    return EventPageContents(eventProvider,
        eventParticipation: eventParticipation, event: event);
  }

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
            if (eventProvider.event.cached == null)
              FutureBuilderPatched(
                  future: eventProvider.event.loading,
                  builder: (eventContext, eventSnapshot) {
                    if (eventSnapshot.hasError) {
                      return Padding(
                          padding: const EdgeInsets.all(32),
                          child:
                              Center(child: formatError(eventSnapshot.error)));
                    }
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()));
                    }

                    return const SizedBox();
                  }),
            ...(() {
              final AnnotatedEvent? event = this.event;
              if (event == null) {
                return [];
              }

              return [
                Center(child: 
      Container(constraints: const BoxConstraints(maxWidth: 700), child:
                Column(children: [
                EventHeader(event),
                EventDescription(event),
                EventThumbnail(event),
                const SizedBox(height: 32),
                if (expectParticipants) ...[
                  EventParticipants(event, eventProvider: eventProvider)
                ]
              ])))
              ];
            }())
          ])),
    ]));
  }
}

class _EventPageState extends State<EventPage> {
  final AlertsPanelController _alertsPanelController = AlertsPanelController();
  late EventProvider _eventProvider;

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

    _eventProvider = EventProvider(
        eventId: widget.eventId, apiConnector: null, cachedEvent: null);
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).connector;

    if (apiConnector != _eventProvider.apiConnector) {
      log.info(
          "Event page: API connector changed from ${_eventProvider.apiConnector} "
          " to $apiConnector, reloading event data");
      _eventProvider = EventProvider(
          eventId: widget.eventId,
          apiConnector: apiConnector,
          cachedEvent: ResourcePoolAccess.of(context)
              .pool
              .eventsProvider
              .events
              .firstWhereOrNull(
                  (element) => element.eventId == widget.eventId));
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var provEvents = ResourcePoolAccess.of(context).pool.eventsProvider;
    return 
    ListenableBuilder(
        listenable: Listenable.merge([_eventProvider, provEvents]),
        builder: (context, _) {
          log.fine("Building event page for event id ${widget.eventId}");

          var prov = _eventProvider;
          var cachedEvent = prov.event.cached;

          EventParticipation? participation;
          if (cachedEvent != null) {
            participation = provEvents.getMeParticipation(cachedEvent,
                feedback: ActionFeedback(
                  sendConfirm: (m) =>
                      ActionFeedback.sendConfirmToast(context, m),
                  sendError: (m) => ActionFeedback.showErrorDialog(context, m),
                ));
          }

          return WithSIBAppBar(
              actions: [
                ActionRefreshButton(
                    refreshFuture: Future.wait([
                      _eventProvider.event.loading,
                      if (prov.doesExpectParticipants())
                        _eventProvider.participants.loading
                    ]).then((_) => DateTime.now()),
                    triggerRefresh: _eventProvider.refresh)
              ],
              child: Column(children: [
                Expanded(
                    child: EventPageContents.fromProvider(prov,
                        eventParticipation: participation)),
                AlertsPanel(
                    controller: _alertsPanelController,
                    loadingFutures: [
                      AlertsFutureStatus(
                          component: "details",
                          future: _eventProvider.event.loading,
                          data: {
                            "isRefreshing": _eventProvider.event.cached != null
                          }),
                      if (prov.doesExpectParticipants())
                        AlertsFutureStatus(
                            component: "participants",
                            future: _eventProvider.participants.loading,
                            data: {
                              "isRefreshing":
                                  _eventProvider.participants.cached != null
                            })
                    ])
              ]));
        });
  }
}
