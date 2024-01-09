import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/week.dart';

class _CalendarDot extends StatelessWidget {
  final List<AnnotatedEvent> events;
  // final int weekday;
  // final int day;
  final DateTime date;
  final DateTime now;
  final Month month;

  const _CalendarDot(
      {Key? key,
      required this.events,
      // required this.weekday,
      // required this.day
      required this.date,
      required this.now,
      required this.month
      })
      : super(key: key);

  bool get isToday =>
    now.toIso8601String().substring(0, 10) ==
    date.toLocal().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // final Color focusColor = Theme.of(context).colorScheme.primary;
    // final Color backgroundColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    // final Color weekendColor = Colors.grey[500] ?? Colors.grey;

    final Color focusColor = 
    // Theme.of(context).colorScheme.primaryContainer;
    Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;
    // final Color backgroundColor = Theme.of(context).colorScheme.secondary.withAlpha(170);
    final Color backgroundColor = focusColor.withAlpha(200);
    final Color weekendColor = backgroundColor;
    //Theme.of(context).colorScheme.secondary.withAlpha(170);
    //Colors.grey[500] ?? Colors.grey;
    final bool isWeekend = date.weekday >= 6;
    final bool isThisMonth = date.month == month.month;

    if (events.isEmpty) {
      if (date.day == 1 && isThisMonth) {
        return Center(child: Container(
          // width: 8,
          // height: 8,
          // decoration: BoxDecoration(
          //     color: weekday >= 6
          //         ? Colors.grey[500]
          //         : Theme.of(context).colorScheme.primary,
          //     shape: BoxShape.circle),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(date.day.toString(),
            style: TextStyle(color: backgroundColor)),
            Text(DateFormat("MMM", locale.toString()).format(date).toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: backgroundColor,
            fontSize: 10, fontFeatures: const [FontFeature.enable('smcp')]))
          ])
        ));
      }

      if (isToday) {
        return Center(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text(date.day.toString(),
            style: TextStyle(color: backgroundColor)),
            Text("Today".toLowerCase(),
            textAlign: TextAlign.center,
            style: TextStyle(color: backgroundColor,
            fontSize: 10, fontFeatures: const [FontFeature.enable('smcp')]))
          ])
        );
      }
      
      if (!isThisMonth) {
        return const SizedBox();
      }


      if (isWeekend) {
        return Center(
          child: 
          Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
            // color:weekendColor.withAlpha(70),
            shape: BoxShape.circle,
            border: Border.all(
              color: weekendColor.withAlpha(70),
            ),
            ),
      ));
      }

      return Center(
          child: Container(
        width: isWeekend ? 3 : 5,
        height: isWeekend ? 3 : 5,
        decoration: BoxDecoration(
            color: (isWeekend
                ? weekendColor
                : backgroundColor).withAlpha(70),
            shape: BoxShape.circle),
      ));
    }

    final mainEvent = events.first;
    final isTruncated = mainEvent.eventLabel.length > 13 &&
        (mainEvent.eventLabel.length > 17 ||
            mainEvent.eventLabel.toLowerCase() ==
                mainEvent.eventName.toLowerCase());

    Widget ans = GestureDetector(
        onTap: () {
          router.pushNamed("event", pathParameters: {"event_id": mainEvent.id});
        },
        child: Container(
            color: Colors.transparent,
            // color: Colors.black,
            // width: 50,
            // height: 50,
            // decoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                date.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: focusColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(mainEvent.eventLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 8,
                  color: focusColor,
                  // fontWeight: FontWeight.bold
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1)
            ]))));

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
  final Month month;
  final List<AnnotatedEvent> events;
  final DateTime now;

  const _CalendarRow({Key? key, required this.week, required this.events, required this.month,
  required this.now})
      : super(key: key);

  bool isToday(DateTime date) {
    //final now = DateTime.now().toLocal();
    return now.toIso8601String().substring(0, 10) ==
        date.toLocal().toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final days = events
        .chunkBy<num>(
            (event) => (event.placement?.date ?? event.start).weekday - 1,
            initialKeys: count().take(7).toList())
        .map((e) => MapEntry((e.key + 0.2).floor() + 1, e.value))
        .map((e) => MapEntry(week.start.add(Duration(days: e.key - 1, hours: 2)), e.value));

    return 
    Row(children: [
      SizedBox(
          width: 20,
          height: 20,
          child: Container(
              decoration: BoxDecoration(
                  // color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                width: 1.5,
                color: //Theme.of(context).textTheme.bodyMedium?.color ??
                    Theme.of(context).colorScheme.tertiaryContainer,
              )),
              child: Center(
                  child: Text(
                week.weekNum.toString(),
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.tertiary,),
                textAlign: TextAlign.center,
              )))),
      Expanded(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        for (final day in days)
          SizedBox(
              width: 50,
              height: 50,
              child:
              Opacity(
                opacity: Month.fromDate(day.key) == month ? 1 : 0.6,
                child:
                  // Center(child:
                  Container(
                    decoration: isToday(day.key) ? const BoxDecoration(
                      shape: BoxShape.rectangle,
                      //color: Color(0xFFE0E0E0),
                      border: Border.fromBorderSide(BorderSide(
                        //color: Color(0xFFE0E0E0),
                        color: Color.fromARGB(118, 225, 45, 32),
                        width: 2,
                      )),
                    ) : null,
                    child:
                  _CalendarDot(
                now: now,
                events: day.value,
                date: day.key,
                month: month
                // weekday: day.key,
                // day:
                    // (,
              )))),
        // Column(
        //   children: [
        //     Text(day.day.toString()),
        //     ...events
        //         .where((event) => event.start.day == day.day)
        //         .map((event) => Text(event.title))
        //   ],
        // ),
      ]))
    ]);
  }
}

class Calendar extends StatelessWidget {
  final Month month;
  // final List<MapEntry<Week, List<AnnotatedEvent>>> events;
  final Map<Week, List<AnnotatedEvent>> events;
  final DateTime now;

  const Calendar({Key? key, required this.month, required this.events,
  required this.now})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text(month.name),
        // ...month.weeks.map((week) => Week(week: week, events: events))
        for (final week in month.coveringWeeks)
          // if (entry.key.end.isAfter(month.start) && entry.key.start.isBefore(month.end))
            _CalendarRow(month: month, week: week, events: events[week] ?? [],
            now: now),
      ],
    );
  }
}
