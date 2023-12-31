import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/pages/home.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider_old.dart';
import 'package:sib_utrecht_app/view_model/event/week_chunker.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../globals.dart';

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
        key: ValueKey(("eventsItem", event.id, event.placement?.date)),
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

  Map<RelativeWeek, Widget> buildEvents(List<AnnotatedEvent> events) {
    var superGroups = WeekChunked(events, (e) => e.placement?.date).superGroups;

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

  Widget buildContents(BuildContext context,
          {required Map<RelativeWeek, Widget> events,
          required Widget bottomPanel}) =>
      Stack(fit: StackFit.expand, children: [
        Positioned.fill(
          child: CustomScrollView(anchor: 0.1, center: _center, slivers: [
            // ...(events[RelativeWeek.lastWeek] ?? []).map((e) => SliverToBoxAdapter(
            //     key: ValueKey(("lastWeek", e.eventId)),
            //     child: EventsPage.buildItem(e))),
            // SliverToBoxAdapter(
            //     child: SizedBox(
            //   height: MediaQuery.sizeOf(context).height * 0.8,
            // )),
            // SliverList.builder( itemCount: 30, itemBuilder: (context, i) => SliverStickyHeader(
            //             header: Container(
            //               height: 60.0,
            //               color: Colors.lightBlue,
            //               padding: EdgeInsets.symmetric(horizontal: 16.0),
            //               alignment: Alignment.centerLeft,
            //               child: Text(
            //                 'Header #0',
            //                 style: const TextStyle(color: Colors.white),
            //               ),
            //             ),
            //             sliver: SliverList(
            //               delegate: SliverChildBuilderDelegate(
            //                 (context, i) => ListTile(
            //                   leading: CircleAvatar(
            //                     child: Text('0'),
            //                   ),
            //                   title: Text('List tile #$i'),
            //                 ),
            //                 childCount: 4,
            //               ),
            //             ),
            //           ),),
            // Builder(
            //   builder: (context) => FutureBuilderPatched(
            //       future: Future.value(null),
            //       builder: ((context, snapshot) => SliverStickyHeader(
            //             header: Container(
            //               height: 60.0,
            //               color: Colors.lightBlue,
            //               padding: EdgeInsets.symmetric(horizontal: 16.0),
            //               alignment: Alignment.centerLeft,
            //               child: Text(
            //                 'Header #0',
            //                 style: const TextStyle(color: Colors.white),
            //               ),
            //             ),
            //             sliver: SliverList(
            //               delegate: SliverChildBuilderDelegate(
            //                 (context, i) => ListTile(
            //                   leading: CircleAvatar(
            //                     child: Text('0'),
            //                   ),
            //                   title: Text('List tile #$i'),
            //                 ),
            //                 childCount: 4,
            //               ),
            //             ),
            //           ))),
            // ),

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
            )),
            // Builder(
            //   builder: (context) => FutureBuilderPatched(
            //       future: Future.value(null),
            //       builder: ((context, snapshot) => SliverStickyHeader(
            //             header: Container(
            //               height: 60.0,
            //               color: Colors.lightBlue,
            //               padding: EdgeInsets.symmetric(horizontal: 16.0),
            //               alignment: Alignment.centerLeft,
            //               child: Text(
            //                 'Header #0',
            //                 style: const TextStyle(color: Colors.white),
            //               ),
            //             ),
            //             sliver: SliverList(
            //               delegate: SliverChildBuilderDelegate(
            //                 (context, i) => ListTile(
            //                   leading: CircleAvatar(
            //                     child: Text('0'),
            //                   ),
            //                   title: Text('List tile #$i'),
            //                 ),
            //                 childCount: 4,
            //               ),
            //             ),
            //           ))),
            // ),
            // SliverToBoxAdapter(
            //     child: SizedBox(
            //   height: MediaQuery.sizeOf(context).height * 0.8,
            // )),
          ]),
        ),
        Positioned(bottom: 10, left: 0, right: 0, child: bottomPanel)
      ]);

  // https://pub.dev/packages/flutter_sticky_header

// https://stackoverflow.com/questions/62184121/how-to-group-list-items-under-sticky-headers-in-flutter
// https://github.com/Dimibe/grouped_list/blob/main/example/lib/chat_example.dart#L402

  @override
  Widget build(BuildContext context) {
    log.fine("Doing events page build");

    return WithSIBAppBar(
        showBackButton: false,
        // actions: [
        //   ActionRefreshButton(
        //     refreshFuture: loading?.then((_) => DateTime.now()),
        //     triggerRefresh: () {
        //       calendar.refresh();
        //     },
        //   )
        // ],
        child: ActionSubscriptionAggregator(
            child: CalendarListProvider(
          feedback: ActionFeedback(
            sendConfirm: (m) => ActionFeedback.sendConfirmToast(context, m),
            sendError: (m) => ActionFeedback.showErrorDialog(context, m),
          ),
          builder: (context, eventsRaw) {
            var events = buildEvents(eventsRaw);

            return buildContents(context,
                events: events, bottomPanel: const SizedBox()
                // IgnorePointer(
                //     child: Center(
                //         child: AlertsPanel(
                //             controller: alertsPanelController,
                //             loadingFutures: [
                //       if (loading != null)
                //         AlertsFutureStatus(
                //             component: "calendar",
                //             future: loading,
                //             data: {
                //               "isRefreshing": calendar.events.isNotEmpty
                //             })
                );
          },
        )));
  }
}
