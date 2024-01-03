import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/event_tile2.dart';
import 'package:sib_utrecht_app/components/event/event_week.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider.dart';
import 'package:sib_utrecht_app/view_model/event/week_chunker.dart';
import 'package:sib_utrecht_app/week.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:sib_utrecht_app/utils.dart';

import '../globals.dart';
import '../view_model/event/annotated_event.dart';
import '../components/event/event_group.dart';
import '../components/actions/alerts_panel.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

// Bidirectional scroll code based on https://api.flutter.dev/flutter/rendering/RenderViewport-class.html

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
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

  // // Map<RelativeWeek, Widget>
  // List<MapEntry<Month, Widget>> buildEventSlivers(
  //     BuildContext context, List<AnnotatedEvent> events) {

  //   return byMonth;

  //   // map((k, v) => MapEntry(k, v
  //   //         .map<Widget>((entry) => EventMonth(
  //   //               // isMultiWeek: entry.isMultiWeek,
  //   //               isMultiWeek: true,
  //   //               key: ValueKey(("EventsGroup", k, entry.key)),
  //   //               title: k?.toDisplayString(context) ?? loc.eventCategoryOngoing,
  //   //               // entry.title(context),
  //   //               // isMajor: k == RelativeWeek.upcomingWeek,
  //   //               isMajor: false
  //   //               initiallyExpanded: true,
  //   //                   // k != RelativeWeek.ongoing && k != RelativeWeek.future,
  //   //               children: entry.elements,
  //   //               weeks: month.weeks.toList(),
  //   //               divideEvents: k != RelativeWeek.ongoing,
  //   //             ))
  //   //         .toList()));

  //   // return byMonth.map((k, v) {
  //   //   if (k == RelativeWeek.past || k == RelativeWeek.lastWeek) {
  //   //     v = v.reversed.toList();
  //   //   }

  //   //   return MapEntry(k, MultiSliver(children: v));
  //   // });

  //   // return superGroups.map((k, v) => MapEntry(
  //   //     k,
  //   //     // Builder(
  //   //     //     builder: (context) => Column(
  //   //           MultiSliver(
  //   //             children: .rever)));
  // }

  Widget buildContents(BuildContext context,
      {required List<AnnotatedEvent> events, required Widget bottomPanel}) {
    final ongoing = events.where((element) => element.placement?.date == null);

    var _byWeek1 = events.map((e) {
      final placement = e.placement;
      if (placement == null) {
        return null;
      }
      return (week: Week.fromDate(placement.date), e: e);
    }).whereNotNull();

    final minWeek =
        _byWeek1.map((e) => e.week).minOrNull ?? Week.fromDate(DateTime.now());
    final maxWeek = _byWeek1.map((e) => e.week).maxOrNull ?? minWeek;

    var byWeek = _byWeek1
        .chunkBy((p0) => p0.week,
            initialKeys: Week.range(minWeek, maxWeek).toList())
        .map((e) => MapEntry(e.key, e.value.map((e) => e.e).toList()))
        .toList();

    // for (final w in Week.range(minWeek, maxWeek)) {
    //   byWeek[]
    //   if (!byWeek.any((e) => e.key == w)) {
    //     byWeek.add(MapEntry(w, []));
    //   }
    // }

    // .chunkBy<Week?>((e) {
    //   final placement = e.placement;
    //   if (placement == null) {
    //     return null;
    //   }
    //   return Week.fromDate(placement.date);
    // });
    // WeekChunked(events, (e) => e.placement?.date).superGroups;
    var loc = AppLocalizations.of(context)!;

    final byMonth = byWeek.chunkBy<Month>((elem) => elem.key.month);

    DateTime now = DateTime.now();
    // now = now.add(const Duration(days: 8));

    final anchor = WeekChunked.getUpcomingWeek(
        events.map((e) => e.placement?.date),
        now: now);

    final currentWeek = anchor.currentWeek;
    final upcomingWeek = anchor.upcomingWeek;
    final lookAhead = upcomingWeek != currentWeek;

    final upcomingMonth = upcomingWeek.month;

    return Stack(fit: StackFit.expand, children: [
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

          // SliverCrossAxisConstrained(
          //   maxCrossAxisExtent: 700, child:
          // events[RelativeWeek.lastWeek] ?? const SliverToBoxAdapter(),
          // // ),
          // // SliverCrossAxisConstrained(
          // //   maxCrossAxisExtent: 700, child:
          // events[RelativeWeek.past] ?? const SliverToBoxAdapter(),
          // ),

          // SliverList.list(
          //   children: [
          //     Center(
          //         child: Container(
          //             constraints: const BoxConstraints(maxWidth: 700),
          //             child:
          //                 events[RelativeWeek.lastWeek] ?? const SizedBox())),
          //     Center(
          //         child: Container(
          //             constraints: const BoxConstraints(maxWidth: 700),
          //             child: events[RelativeWeek.past] ?? const SizedBox())),
          //   ],
          // ),

          // SliverStickyHeader(
          // header: Container(
          //     color: Theme.of(context).colorScheme.secondaryContainer,
          //     child: Padding(
          //         padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          //         child:
          //             // Row(children: [],)
          //             Center(
          //                 child: Text(
          //           "User details",
          //           style: Theme.of(context).textTheme.titleLarge,
          //         )))),
          // sliver: SliverCrossAxisConstrained(
          //     maxCrossAxisExtent: 700,
          //     child: SliverPadding(
          // padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
          //         sliver: SliverToBoxAdapter(child: Text("Test"),)
          //     ))),

          for (final monthEntry
              in byMonth.where((entry) => entry.key < upcomingMonth))
            EventMonth(
                key: ValueKey(monthEntry.key),
                title: monthEntry.key.toDisplayString(context),
                // isMajor: k == RelativeWeek.upcomingWeek,
                isMajor: false,
                initiallyExpanded: true,
                children: monthEntry.value
                // weeks: month.weeks.toList(),
                // divideEvents: k != RelativeWeek.ongoing,
                ),

          SliverToBoxAdapter(key: _center),

          for (final monthEntry
              in byMonth.where((entry) => entry.key >= upcomingMonth))
            EventMonth(
              key: ValueKey(monthEntry.key),
              title: monthEntry.key.toDisplayString(context),
              isMajor: false,
              initiallyExpanded: true,
              children: monthEntry.value,
              weekBuilder: ({required events, required week}) => week ==
                      upcomingWeek
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ThisWeekCard(
                          events: events,
                          week: week,
                          title: lookAhead ? loc.upcomingWeek : loc.thisWeek))
                  : EventWeek(events: events, week: week),
            ),

          // SliverCrossAxisConstrained(
          //   key: _center,
          //   maxCrossAxisExtent: 700,
          //   child:
          // events[RelativeWeek.upcomingWeek] ?? const SliverToBoxAdapter(),
          // ),

          // SliverToBoxAdapter(
          //     key: _center,
          //     child: Padding(
          //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          //         child: Center(
          //             child: Container(
          //                 constraints: const BoxConstraints(maxWidth: 700),
          //                 child: events[RelativeWeek.upcomingWeek] ??
          //                     const SizedBox())))),

          // SliverCrossAxisConstrained(
          //   maxCrossAxisExtent: 700, child:
          // events[RelativeWeek.nextWeek] ?? const SliverToBoxAdapter(),
          // // ),

          // // SliverCrossAxisConstrained(
          // //   maxCrossAxisExtent: 700, child:
          // events[RelativeWeek.future] ?? const SliverToBoxAdapter(),
          // ),

          // SliverCrossAxisConstrained(
          //   maxCrossAxisExtent: 700, child:
          // SliverPadding(
          //     padding: const EdgeInsets.only(left: 8),
          //     sliver:
          //         events[RelativeWeek.ongoing] ?? const SliverToBoxAdapter()),
          // ),

          //  ?? loc.eventCategoryOngoing

          EventGroup(
              title: loc.eventCategoryOngoing,
              isMajor: false,
              sliver: SliverPadding(
                  key: const ValueKey("ongoing"),
                  padding: const EdgeInsets.only(left: 8),
                  sliver: SliverList.list(children: [
                    for (var event in ongoing)
                      EventTile2(key: ValueKey(event.id), event: event)
                  ]))),

          // SliverList.list(
          //   children: [
          //     Center(
          //         child: Container(
          //             constraints: const BoxConstraints(maxWidth: 700),
          //             child:
          //                 events[RelativeWeek.nextWeek] ?? const SizedBox())),
          //     Center(
          //         child: Container(
          //             constraints: const BoxConstraints(maxWidth: 700),
          //             child:
          //                 events[RelativeWeek.future] ?? const SizedBox())),
          //     Center(
          //         child: Container(
          //             constraints: const BoxConstraints(maxWidth: 700),
          //             child:
          //                 events[RelativeWeek.ongoing] ?? const SizedBox())),
          //   ],
          // ),
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
  }

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
          builder: (context, events) {
            // var events = buildEventSlivers(context, eventsRaw);

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
