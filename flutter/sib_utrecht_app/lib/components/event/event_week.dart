import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/components/event/event_day.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/week.dart';

class ThisWeekCard extends StatelessWidget {
  final List<AnnotatedEvent> events;
  final Week week;
  final String title;

  const ThisWeekCard(
      {required this.events, required this.week, Key? key, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var todayFormatted =
        DateFormat.MMMMEEEEd(Localizations.localeOf(context).toString())
            .format(DateTime.now());

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          // group.title(context),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
              // fontFeatures: [const FontFeature.enable('smcp')]
              )),
      const SizedBox(height: 8),
      Card(
          // color: Theme.of(context).colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                  color:
                      // Theme.of(context).colorScheme.secondaryContainer,
                      // Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.primary,
                  width: 2)),
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: events.isEmpty
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text("No events",
                              style: Theme.of(context).textTheme.bodyLarge)))
                  : EventWeekCore(
                      week: week,
                      events: events,
                      showWeekNumber: false,
                    )
              //  [
              //   // Padding(
              //   //     padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              //   //     child:
              //   //     Row(mainAxisSize: MainAxisSize.min, children: [
              //   //       Icon(
              //   //         Icons.arrow_right_rounded,
              //   //         color: Colors.grey[400]
              //   //         // color: Colors.orange[600]
              //   //       ),
              //   //       Text("Today: $todayFormatted",
              //   //           style: Theme.of(context)
              //   //               .textTheme
              //   //               .bodyMedium
              //   //               ?.copyWith(
              //   //                 color: Colors.grey[400],
              //   //                   // color: Colors.orange[200]
              //   //                   ))
              //   //     ])),

              //   // ...group.elements
              //   //     .map((event) => EventTile2(
              //   //         key: ValueKey((
              //   //           "eventsItem",
              //   //           event.id,
              //   //           event.placement?.date
              //   //         )),
              //   //         event: event))
              //   //     .toList()
              // ]
              )),
      Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
}

class EventWeek extends StatelessWidget {
  final String? weekTitle;
  final List<AnnotatedEvent> events;
  // final bool isPrimary;
  // final bool isSelected;
  final Week week;
  final bool showWeekNumber;

  const EventWeek(
      {Key? key,
      this.weekTitle,
      required this.week,
      required this.events,
      this.showWeekNumber = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) => EventWeekCore(
        week: week,
        events: events,
        weekTitle: weekTitle,
        showWeekNumber: showWeekNumber,
      );
}

class EventWeekCore extends StatelessWidget {
  final Week week;
  final String? weekTitle;
  final List<AnnotatedEvent> events;
  // final ;
  // final bool showWeekName;

  EventWeekCore(
      {Key? key,
      String? weekTitle,
      required this.week,
      required this.events,
      bool showWeekNumber = true})
      : weekTitle =
            weekTitle ?? (showWeekNumber ? "Week ${week.weekNum}" : null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekTitle = this.weekTitle;

    // return Text("EventWeekCore");

    // if (events.isEmpty) {
    //   return Align(
    //       alignment: Alignment.centerLeft,
    //       child: Padding(
    //           padding: const EdgeInsets.all(16),
    //           child: Text("No events",
    //               style: Theme.of(context).textTheme.bodyLarge)));
    // }

    return Column(
      children: [
        if (weekTitle != null)
          Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(weekTitle,
                      style: Theme.of(context).textTheme.titleMedium))),
        // for (var event in events) ...[
        //   Text(event.event.title),
        //   Text(event.event.description),
        // ],
        if (events.isEmpty)
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text("No events",
                  style: Theme.of(context).textTheme.bodyLarge)),

        for (final day in events
            .groupListsBy((element) =>
                (element.placement?.date ?? element.start)
                    .toIso8601String()
                    .substring(0, 10))
            .entries
            .sortedBy<String>((element) => element.key))
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: EventDay(day: DateTime.parse(day.key), events: day.value)),
      ],
    );
  }
}
