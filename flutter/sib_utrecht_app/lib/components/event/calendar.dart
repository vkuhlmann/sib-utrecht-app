import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiver/iterables.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/week.dart';

class _CalendarDot extends StatelessWidget {
  final List<AnnotatedEvent> events;
  final int weekday;
  final int day;

  const _CalendarDot(
      {Key? key,
      required this.events,
      required this.weekday,
      required this.day})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
            color: weekday >= 6 ? Colors.grey[500] : Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle),
      ));
    }

    final mainEvent = events.first;
    final isTruncated = mainEvent.eventLabel.length > 13 && 
    (mainEvent.eventLabel.length > 17 || mainEvent.eventLabel.toLowerCase() == mainEvent.eventName.toLowerCase());

    Widget ans = GestureDetector(
      onTap: () {
        router.goNamed("event", pathParameters: {"event_id": mainEvent.id});
      },
      child:
    Container(
      color: Colors.transparent,
      // color: Colors.black,
      // width: 50,
      // height: 50,
      // decoration: BoxDecoration(
      //     color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
      child: Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        Text(day.toString(), textAlign: TextAlign.center,),
        Text(mainEvent.eventLabel, textAlign: TextAlign.center, style: TextStyle(fontSize: 8),
        overflow: TextOverflow.ellipsis, maxLines: 1)
      ])
    )));

    if (isTruncated) {
      ans = Tooltip(
        message: mainEvent.getLocalEventName(Localizations.localeOf(context)),
        triggerMode: TooltipTriggerMode.longPress,
        waitDuration: const Duration(milliseconds: 500),
        child: ans,
      );
    }

    return ans;
    // Tooltip(
    //   message: isTruncated ? mainEvent.getLocalEventName(Localizations.localeOf(context)) : null,
    //   child:
    // );
  }
}

class _CalendarRow extends StatelessWidget {
  final Week week;
  final List<AnnotatedEvent> events;

  const _CalendarRow({Key? key, required this.week, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = events
        .chunkBy<num>((event) => (event.placement?.date ?? event.start).weekday - 1,
            initialKeys: count().take(7).toList())
        .map((e) => MapEntry((e.key + 0.2).floor() + 1, e.value));

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days
            .map((day) => //Expanded(child: 
                  SizedBox(width: 50, height: 50, child: 
                  // Center(child: 
                  _CalendarDot(events: day.value, weekday: day.key,
                    day: (week.start.add(Duration(days: day.key - 1, hours: 2))).day,
                  ))
                  // Column(
                  //   children: [
                  //     Text(day.day.toString()),
                  //     ...events
                  //         .where((event) => event.start.day == day.day)
                  //         .map((event) => Text(event.title))
                  //   ],
                  // ),
                )
            .toList());
  }
}

class Calendar extends StatelessWidget {
  final Month month;
  final List<MapEntry<Week, List<AnnotatedEvent>>> events;

  const Calendar({Key? key, required this.month, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(      children: [
        // Text(month.name),
        // ...month.weeks.map((week) => Week(week: week, events: events))
        for (final entry in events)
          _CalendarRow(week: entry.key, events: entry.value)
      ],
    );
  }
}
