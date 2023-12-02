import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/event/event_tile.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_provider.dart';
import 'package:sib_utrecht_app/view_model/event/week_chunker.dart';

class HomePageContents extends StatelessWidget {
  final Map<RelativeWeek, List<EventsGroupInfo<AnnotatedEvent>>> superGroups;

  const HomePageContents(this.superGroups, {Key? key}) : super(key: key);

  Widget buildMainCard(
      BuildContext context, EventsGroupInfo<AnnotatedEvent> group) {
    var todayFormatted =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString())
            .format(DateTime.now());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(group.title(context),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              // fontFeatures: [const FontFeature.enable('smcp')]
              )),
      const SizedBox(height: 8),
      Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //     padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                    //     child:
                    //     Row(mainAxisSize: MainAxisSize.min, children: [
                    //       Icon(
                    //         Icons.arrow_right_rounded,
                    //         color: Colors.grey[400]
                    //         // color: Colors.orange[600]
                    //       ),
                    //       Text("Today: $todayFormatted",
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .bodyMedium
                    //               ?.copyWith(
                    //                 color: Colors.grey[400],
                    //                   // color: Colors.orange[200]
                    //                   ))
                    //     ])),
                    ...group.elements
                        .map((event) => EventTile(
                            key: ValueKey((
                              "eventsItem",
                              event.eventId,
                              event.placement?.date
                            )),
                            event: event))
                        .toList()
                  ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            // Icon(
            //   Icons.arrow_right_rounded,
            //   color: Colors.grey[400]
            //   // color: Colors.orange[600]
            // ),
            Text("Today: $todayFormatted",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      // color: Colors.orange[200]
                    ))
          ])),
    ]);
  }

  Widget buildSecondaryCard(
          BuildContext context, EventsGroupInfo<AnnotatedEvent> group) =>
      Opacity(
          opacity: 0.8,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(group.title(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    // fontFeatures: [const FontFeature.enable('smcp')]
                    )),
            const SizedBox(height: 8),
            Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: Column(
                        children: group.elements
                            .map((event) => EventTile(
                                key: ValueKey((
                                  "eventsItem",
                                  event.eventId,
                                  event.placement?.date
                                )),
                                event: event))
                            .toList())))
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
                                "$formattedDate: ${e.getLocalEventName(Localizations.localeOf(context))}",
                              );
                            }).toList()),
                        const SizedBox(height: 16),
                        if (lastWeek.isNotEmpty)
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
                                        "$formattedDate: ${e.getLocalEventName(Localizations.localeOf(context))}",
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

    return CenteredPageScroll(slivers: [
      SliverToBoxAdapter(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // Upcoming week
          if (upcomingWeek.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text("No upcoming events",
                  style: Theme.of(context).textTheme.headlineMedium),
            )
          else
            Container(
                constraints: const BoxConstraints(minHeight: 250),
                child: Column(
                    children: upcomingWeek
                        .map((e) => buildMainCard(context, e))
                        .toList())),
          const SizedBox(height: 32),

          // Next week
          if (nextWeek.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text("No events next week",
                  style: Theme.of(context).textTheme.headlineMedium),
            )
          else
            ...nextWeek.map((e) => buildSecondaryCard(context, e)),

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

  static Widget buildLoginPrompt(BuildContext context) => Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        FilledButton(
            onPressed: () {
              GoRouter.of(context).go("/login?immediate=true");
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

  static Widget buildInProgress(
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

            if (calendarLoadSnapshot.hasError) {
              return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                      child: Text(
                          "Error loading events: ${calendarLoadSnapshot.error}")));
            }

            // return const SizedBox();
            return const Center(child: Text("No events"));

            // return Center(child: Text(calendarLoadSnapshot.connectionState.toString()));

            // return Center(child: Text(calendarLoadSnapshot.hasData.toString()));
          });

  @override
  Widget build(BuildContext context) {
    return WithSIBAppBar(
        actions: const [],
        child: EventsCalendarProvider(
            builder: (context, calendar) => FutureBuilderPatched(
                  future: calendar.loading,
                  builder: (calendarLoadContext, calendarLoadSnapshot) {
                    if (calendar.events.isEmpty) {
                      return Center(
                          child: buildInProgress(
                              calendarLoadContext, calendarLoadSnapshot));
                    }

                    var superGroups =
                        WeekChunked(calendar.events, (e) => e.placement?.date)
                            .superGroups;

                    return HomePageContents(superGroups);
                  },
                )));
  }
}
