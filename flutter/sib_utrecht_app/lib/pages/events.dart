import 'dart:async';
import 'dart:math';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_list.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider.dart';
import 'package:sib_utrecht_app/view_model/event/week_chunker.dart';

import '../globals.dart';

import '../utils.dart';
import '../components/api_access.dart';
import '../view_model/event/annotated_event.dart';
import '../view_model/async_patch.dart';
import '../components/event/event_group.dart';
import '../components/actions/alerts_panel.dart';
import '../components/event/event_tile.dart';
import '../components/actions/action_refresh.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

// Bidirectional scroll code based on https://api.flutter.dev/flutter/rendering/RenderViewport-class.html

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();

  static Widget buildItem(AnnotatedEvent event) {
    return EventTile(
        key: ValueKey(("eventsItem", event.eventId, event.placement?.date)),
        event: event);
  }
}

class _EventsPageState extends State<EventsPage> {
  final AlertsPanelController alertsPanelController = AlertsPanelController();

  // Used by CustomScrollView to position upcoming events at the top
  final UniqueKey _center = UniqueKey();

  bool forceShowEventsStatus = true;
  bool forceShowBookingsStatus = true;

  @override
  void initState() {
    super.initState();

    alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "calendar", status: "loading", data: {}));
    alertsPanelController.dismissedMessages.add(const AlertsPanelStatusMessage(
        component: "calendar", status: "done", data: {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Map<RelativeWeek, Widget> buildEvents(EventsCalendarList list) {
    var superGroups =
        WeekChunked(list.events, (e) => e.placement?.date).superGroups;

    return superGroups.map((k, v) => MapEntry(
        k,
        Builder(
            builder: (context) => Column(
                children: v
                    .map<Widget>((entry) => EventsGroup(
                        key: ValueKey(("EventsGroup", k, entry.key)),
                        title: entry.title(context),
                        isMajor: k == RelativeWeek.upcomingWeek,
                        initiallyExpanded: k != RelativeWeek.ongoing &&
                            k != RelativeWeek.future,
                        children: entry.elements))
                    .toList()))));
  }

  Widget buildLoginPrompt(BuildContext context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        FilledButton(
            onPressed: () {
              router.go("/login?immediate=true");
            },
            style: (Theme.of(context).filledButtonTheme.style ??
                    FilledButton.styleFrom())
                .copyWith(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)))),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Log in",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ))))
      ]));

  Widget buildInProgress(
          BuildContext context, AsyncSnapshot<void> calendarLoadSnapshot) =>
      FutureBuilderPatched(
          future: ResourcePoolAccess.of(context).pool.connector,
          builder: (context, snapshot) {
            var data = snapshot.data;

            if (data != null &&
                data.base is HTTPApiConnector &&
                (data.base as HTTPApiConnector).user == null) {
              return buildLoginPrompt(context);
            }

            if (calendarLoadSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }

            // if (calendarLoadSnapshot.hasError) {
            //   return Padding(
            //       padding: const EdgeInsets.all(32),
            //       child: Center(
            //           child: Text(
            //               "Error loading events: ${calendarLoadSnapshot.error}")));
            // }

            // return const SizedBox();
            return const Center(child: Text("No events"));

            // return Center(child: Text(calendarLoadSnapshot.connectionState.toString()));

            // return Center(child: Text(calendarLoadSnapshot.hasData.toString()));
          });

  Widget buildContents(BuildContext context,
          {required Map<RelativeWeek, Widget> events,
          required Widget bottomPanel}) =>
      Stack(fit: StackFit.expand, children: [
        Positioned.fill(
          child: CustomScrollView(anchor: 0.1, center: _center, slivers: [
            SliverList.list(
              children: [
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child:
                            events[RelativeWeek.lastWeek] ?? const SizedBox())),
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: events[RelativeWeek.past] ?? const SizedBox())),
              ],
            ),
            SliverToBoxAdapter(
                key: _center,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
                    child: Center(
                        child: Container(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: events[RelativeWeek.upcomingWeek] ??
                                const SizedBox())))),
            SliverList.list(
              children: [
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child:
                            events[RelativeWeek.nextWeek] ?? const SizedBox())),
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child:
                            events[RelativeWeek.future] ?? const SizedBox())),
                Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child:
                            events[RelativeWeek.ongoing] ?? const SizedBox())),
              ],
            ),
            SliverToBoxAdapter(
                child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.2,
            ))
          ]),
        ),
        Positioned(bottom: 10, left: 0, right: 0, child: bottomPanel)
      ]);

  @override
  Widget build(BuildContext context) {
    log.fine("Doing events page build");

    return EventsCalendarProvider(builder: (context, calendar) {
      var loading = calendar.loading;
      return WithSIBAppBar(
          showBackButton: false,
          actions: [
            ActionRefreshButton(
              refreshFuture: loading?.then((_) => DateTime.now()),
              triggerRefresh: () {
                calendar.refresh();
              },
            )
          ],
          child: FutureBuilderPatched(
            future: calendar.loading,
            builder: (calendarLoadContext, calendarLoadSnapshot) {
              if (calendar.events.isEmpty) {
                return Center(
                    child: buildInProgress(
                        calendarLoadContext, calendarLoadSnapshot));
              }

              var events = buildEvents(calendar);

              return buildContents(context,
                  events: events,
                  bottomPanel: IgnorePointer(
                      child: Center(
                          child: AlertsPanel(
                              controller: alertsPanelController,
                              loadingFutures: [
                        if (loading != null)
                          AlertsFutureStatus(
                              component: "calendar",
                              future: loading,
                              data: {
                                "isRefreshing": calendar.events.isNotEmpty
                              })
                      ]))));
            },
          ));
    });
  }
}
