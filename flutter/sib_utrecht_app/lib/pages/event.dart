import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/event/event_participants.dart';
import 'package:sib_utrecht_app/components/event/thumbnail.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/resource_pool_access.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/signup_indicator.dart';
import 'package:sib_utrecht_app/model/booking.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/event_provider_notifier.dart';
import 'package:sib_utrecht_app/view_model/provider/event_bookings_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/event_participants_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/event_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/participation_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';

import '../globals.dart';
import '../components/actions/alerts_panel.dart';
import '../components/api_access.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key, required this.eventId});
  final String eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class EventHeader extends StatelessWidget {
  final AnnotatedEvent event;

  const EventHeader(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    log.fine("Building EventHeader for event id ${event.id}");

    var eventEnd = event.date.end;
    final wpPermalink = event.wpPermalink;

    final loc = AppLocalizations.of(context);
    if (loc == null) {
      throw StateError("AppLocalizations is null");
    }

    return Column(children: [
      Row(children: [
        Expanded(
            child: Card(
                child: ListTile(
                    title: Text(event.name
                        .getLocalLong(Localizations.localeOf(context)))))),
        SignupIndicator(
          event: event,
          isFixedWidth: false,
        ),
        IconButton(
            onPressed: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                router.pushNamed("event_edit",
                    pathParameters: {"event_id": event.id});
              });
            },
            icon: const Icon(Icons.edit)),
      ]),
      if (event.location != null)
        Card(
            child: ListTile(
                title: Text(
                    "${loc.eventLocation}: ${event.location.toString()}"))),

      Card(
          child: ListTile(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            // Text(event.date.start.toIso8601String()),
            // Text(event.date.start.toString()),
            // Text(event.toFragments().get<String>(["date.start", "date"])
            // ?? "null"),
            Wrap(children: [
              SizedBox(
                  width: 80,
                  child:
                      Text("${loc.eventStarts}: ")),
              Wrap(children: [
                SizedBox(
                    width: 260,
                    child: Text(DateFormat.yMMMMEEEEd(
                            Localizations.localeOf(context).toString())
                        .format(event.date.start))),
                // const SizedBox(width: 20),
                Text(DateFormat.Hm(Localizations.localeOf(context).toString())
                    .format(event.date.start))
              ]),
            ]),
            if (eventEnd != null)
              Wrap(children: [
                SizedBox(
                    width: 80,
                    child:
                        Text("${AppLocalizations.of(context)!.eventEnds}: ")),
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
              ]),
            if (wpPermalink != null && wpPermalink.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Card(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer
                          .withOpacity(0.2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 16),
                          Flexible(
                              child: Text(
                            wpPermalink,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: IconButton(
                                icon: const Icon(Icons.content_copy, size: 16),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: wpPermalink));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Link copied to clipboard")));
                                }),
                          )
                        ],
                      )))
          ]))),
      if (event.participation?.isActive == true &&
          event.participation?.isParticipating == false)
        // Card(
        //     child: ListTile(
        //         title:
        Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
                onPressed: () {
                  var func = event.participation?.setParticipating;
                  if (func == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Participation set function missing")));
                    return;
                  }

                  try {
                    func(true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Participation set function failed: ${formatErrorMsg(e.toString())}")));
                    return;
                  }
                },
                // child: Text("Sign up now!",
                //     style: Theme.of(context).textTheme.headlineMedium),
                style: (Theme.of(context).filledButtonTheme.style ??
                        FilledButton.styleFrom())
                    .copyWith(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)))),
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Sign up now!",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )))))
      //  Text("Sign up now!",
      //     style: TextStyle(fontWeight: FontWeight.bold)))),

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
  final Event event;

  const EventDescription(this.event, {super.key});

  @override
  Widget build(BuildContext context) {
    log.fine("Building EventDescription for event id ${event.id}");

    final eventBody = event.body;
    if (eventBody == null) {
      throw StateError("Event body is null");
    }

    final (description, _, _) = eventBody.extractDescriptionAndThumbnail();
    final loc = AppLocalizations.of(context);
    if (loc == null) {
      throw StateError("AppLocalizations is null");
    }

    return Card(
        child: ListTile(
            title: Text(loc.eventDescription),
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
  final EventParticipation? eventParticipation;
  final AnnotatedEvent event;

  const EventPageContents(
      {super.key, required this.eventParticipation, required this.event});

  @override
  Widget build(BuildContext context) {
    log.fine("Building EventPageContents for event id ${event.id}");

    return SelectionArea(
        child: CustomScrollView(slivers: [
      SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          sliver: SliverList.list(children: [
            const SizedBox(height: 20),
            Center(
                child: Container(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(children: [
                      EventHeader(event),
                      EventProvider.Single(
                        query: event.id,
                        requireBody: true,
                        builder: (context, event, _) => Column(children: [
                          EventDescription(event),
                          EventThumbnail(event),
                        ]),
                      ),
                      const SizedBox(height: 32),
                      EventParticipantsProvider(
                          eventId: event.id,
                          builder: (context, participants)
                              //  =>
                              // FutureBuilderPatched(
                              //     future: Future.wait(participantFutures),
                              //     builder: (context, snapshot)
                              // UserProvider.Multiplexed(
                              //     query: bookings
                              //         .map((e) => e.userId)
                              //         .toList(),
                              //     builder: (context, users)
                              {
                            // final participants = snapshot.data;

                            // if (participants == null) {
                            //   return const SizedBox();
                            // }

                            if (participants.isEmpty &&
                                !event.participate.signup
                                    .doesExpectParticipants()) {
                              return const SizedBox();
                            }

                            // var participants = bookings.mapIndexed((index, element) =>
                            //   AnnotatedUser(
                            //     user: users[index],
                            //     comment: element.comment
                            //   )
                            // ).toList();

                            // if ()
                            return EventParticipants(event,
                                participants: participants);

                            // if (expectParticipants) ...[
                            //   EventParticipants(event, eventProvider: eventProvider)
                            // ]
                          })
                    ])))
          ])),
    ]));
  }
}

class _EventPageState extends State<EventPage> {
  final AlertsPanelController _alertsPanelController = AlertsPanelController();
  // late EventProviderNotifier _eventProvider;

  @override
  void initState() {
    super.initState();

    log.fine("Doing initState on EventPage");

    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "details", status: "loading", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "details", status: "done", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "participants", status: "loading", data: {}));
    _alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "participants", status: "done", data: {}));

    // _eventProvider = EventProviderNotifier(
    //     eventId: widget.eventId, apiConnector: null, cachedEvent: null);
  }

  @override
  void didChangeDependencies() {
    // final apiConnector = APIAccess.of(context).connector;

    // if (apiConnector != _eventProvider.apiConnector) {
    //   log.info(
    //       "Event page: API connector changed from ${_eventProvider.apiConnector} "
    //       " to $apiConnector, reloading event data");

    //   var cachedEv = ResourcePoolAccess.of(context)
    //       .pool
    //       .eventsProvider
    //       .events
    //       .firstWhereOrNull((element) => element.eventId == widget.eventId);

    //   _eventProvider = EventProviderNotifier(
    //       eventId: widget.eventId,
    //       apiConnector: apiConnector,
    //       cachedEvent: cachedEv == null ? null : FetchResult(cachedEv, null));
    // }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    log.info("Building EventPage for event id ${widget.eventId}");

    // var provEvents = ResourcePoolAccess.of(context).pool.eventsProvider;
    return WithSIBAppBar(
        actions: const [],
        child: ActionSubscriptionAggregator(
            child: EventProvider.Single(
                query: widget.eventId,
                requireBody: false,
                builder: (context, event, _) =>
                    EventParticipationProvider.Single(
                        query: event,
                        builder: (context, annotatedEvent) {
                          // ListenableBuilder(
                          //     listenable: Listenable.merge([_eventProvider, provEvents]),
                          //     builder: (context, _) {
                          // log.fine(
                          //     "Building event page for event id ${widget.eventId}");

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
                                    event: annotatedEvent,
                                    eventParticipation:
                                        annotatedEvent.participation)),
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
                        }))));
  }
}
