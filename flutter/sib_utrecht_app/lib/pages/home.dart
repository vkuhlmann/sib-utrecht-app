import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/event/event_week.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider.dart';
import 'package:sib_utrecht_app/view_model/event/week_chunker.dart';
import 'package:sib_utrecht_app/week.dart';

class HomePageContents extends StatelessWidget {
  final Map<RelativeWeek, List<EventsGroupInfo<AnnotatedEvent>>> superGroups;

  const HomePageContents(this.superGroups, {Key? key}) : super(key: key);

  // Widget buildMainCard(
  //     BuildContext context, EventsGroupInfo<AnnotatedEvent> group) 

  Widget buildSecondaryCard(
          BuildContext context, EventsGroupInfo<AnnotatedEvent> group, Week week) =>
      Opacity(
          opacity: 1,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.title(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // fontFeatures: [const FontFeature.enable('smcp')]
                    )),
            const SizedBox(height: 8),
            // Container(

            // )
            Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color:
                            // Theme.of(context).colorScheme.secondaryContainer,
                            Theme.of(context).colorScheme.primaryContainer,
                        width: 2)),
                color: Colors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                // color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: EventWeekCore(week: week, events: group.elements, showWeekNumber: false,)
                    // Column(
                    //     children:
                    //     group.elements
                    //         .map((event) => EventTile2(
                    //             key: ValueKey((
                    //               "eventsItem",
                    //               event.id,
                    //               event.placement?.date
                    //             )),
                    //             event: event))
                    //         .toList())

                    ))
          ]));

  Widget buildFurtherEventsCard(BuildContext context) {
    var future = superGroups[RelativeWeek.future] ?? [];
    var lastWeek = superGroups[RelativeWeek.lastWeek] ?? [];

    return Card(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Stack(children: [
              Opacity(
                  opacity: 0.8,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(future.first.title(context),
                        //     style: Theme.of(context)
                        //         .textTheme
                        //         .titleMedium
                        //         ?.copyWith(
                        //             // fontStyle: FontStyle.italic
                        //             // fontFeatures: [const FontFeature.enable('smcp')]
                        //             )),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: future.first.elements.map((e) {
                              var formattedDate = DateFormat.MMMMEEEEd(
                                      Localizations.localeOf(context)
                                          .toString())
                                  .format(e.placement!.date);

                              return Text(
                                "$formattedDate: ${e.name.getLocalLong(Localizations.localeOf(context))}",
                              );
                            }).toList()),
                        const SizedBox(height: 16),
                        if (lastWeek.firstOrNull?.elements.isNotEmpty == true)
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Last week",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[600]
                                            : Colors.grey[400])),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: lastWeek.first.elements.map((e) {
                                      var formattedDate = DateFormat.MMMMEEEEd(
                                              Localizations.localeOf(context)
                                                  .toString())
                                          .format(e.placement!.date);

                                      return Text(
                                        "$formattedDate: ${e.name.getLocalLong(Localizations.localeOf(context))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? Colors.grey[600]
                                                    : Colors.grey[400]),
                                      );
                                    }).toList()),
                              ]),
                        const SizedBox(height: 24)
                      ])),
              // const SizedBox(height: 16),
              Positioned(
                  bottom: 0,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).go("/events");
                    },
                    style: ButtonStyle(
                      // backgroundColor: MaterialStateProperty.all(
                      //     Theme.of(context)
                      //         .colorScheme
                      //         .surfaceVariant),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.onInverseSurface),
                      foregroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.secondary),
                      // foregroundColor: MaterialStateProperty.all(
                      //     Theme.of(context)
                      //         .colorScheme
                      //         .inverseSurface),
                    ),
                    child: const Text(
                      "See all events",
                      // style: Theme.of(context)
                      //     .textTheme
                      //     .bodyMedium
                      //     ?.copyWith(
                      //         color: Theme.of(context)
                      //             .colorScheme
                      //             .secondary),
                    ),
                  ))
            ])));
  }

  @override
  Widget build(BuildContext context) {
    var upcomingWeek = superGroups[RelativeWeek.upcomingWeek] ?? [];
    var nextWeek = superGroups[RelativeWeek.nextWeek] ?? [];

    final anchor = WeekChunked.getUpcomingWeek(
      upcomingWeek.singleOrNull?.elements.map((e) => e.placement?.date)
      ?? [],
      now: DateTime.now());
    final bool lookAhead = anchor.upcomingWeek != anchor.currentWeek;
    var loc = AppLocalizations.of(context)!;

    return CenteredPageScroll(slivers: [
      SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Upcoming week
          // if (upcomingWeek.isEmpty)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(vertical: 32),
          //     child: Text("No events this week",
          //         style: Theme.of(context).textTheme.headlineSmall),
          //   )
          // else
          Container(
              constraints: const BoxConstraints(minHeight: 250),
              child: ThisWeekCard(
                events: upcomingWeek.single.elements,
                week: anchor.upcomingWeek,
                title: lookAhead ? loc.upcomingWeek : loc.thisWeek)),
          const SizedBox(height: 32),

          // Next week
          if (nextWeek.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text("No events next week",
                  style: Theme.of(context).textTheme.headlineMedium),
            )
          else
            ...nextWeek.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: buildSecondaryCard(context, e, anchor.upcomingWeek.next))),

          // Future
          // if (future.isNotEmpty)
          Row(children: [
            Expanded(child: buildFurtherEventsCard(context)),
          ]),
          const SizedBox(height: 48),
        ],
      ))
    ]);

    // return CustomScrollView(
    //     slivers: superGroups.entries
    //         .map((entry) => SliverStickyHeader(
    //             header: EventsGroupHeader(entry.key),
    //             sliver: SliverList(
    //                 delegate: SliverChildBuilderDelegate(
    //                     (context, index) => EventsPage.buildItem(
    //                         entry.value[index].event,
    //                         placement: entry.value[index].placement),
    //                     childCount: entry.value.length))))
    //         .toList());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // static Widget buildInProgress(
  //         BuildContext context, AsyncSnapshot<void> calendarLoadSnapshot) =>
  //     FutureBuilderPatched(
  //         future: ResourcePoolAccess.of(context).pool.connector,
  //         builder: (context, snapshot) {
  //           var data = snapshot.data;

  //           if (data != null &&
  //               data.base is HTTPApiConnector &&
  //               (data.base as HTTPApiConnector).user == null) {
  //             return buildLoginPrompt(context);
  //           }

  //           if (calendarLoadSnapshot.connectionState ==
  //               ConnectionState.waiting) {
  //             return const Padding(
  //                 padding: EdgeInsets.all(32),
  //                 child: Center(child: CircularProgressIndicator()));
  //           }

  //           if (calendarLoadSnapshot.hasError) {
  //             return Padding(
  //                 padding: const EdgeInsets.all(32),
  //                 child: Center(
  //                     child: Text(
  //                         "Error loading events: ${calendarLoadSnapshot.error}")));
  //           }

  //           // return const SizedBox();
  //           return const Center(child: Text("No events"));

  //           // return Center(child: Text(calendarLoadSnapshot.connectionState.toString()));

  //           // return Center(child: Text(calendarLoadSnapshot.hasData.toString()));
  //         });

  @override
  Widget build(BuildContext context) {
    return WithSIBAppBar(
        actions: const [],
        child: ActionSubscriptionAggregator(
            child: CalendarListProvider(
          feedback: ActionFeedback(
            sendConfirm: (m) => ActionFeedback.sendConfirmToast(context, m),
            sendError: (m) => ActionFeedback.showErrorDialog(context, m),
          ),
          builder: (context, events) {
            var superGroups =
                WeekChunked(events, (e) => e.placement?.date).superGroups;

            return HomePageContents(superGroups);
          },
        )));
  }
}
