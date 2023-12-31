import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/event/event_day.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';

class EventWeek extends StatelessWidget {
  final String? weekTitle;
  final List<AnnotatedEvent> events;
  // final bool showWeekName;

  const EventWeek({Key? key, required this.weekTitle, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekTitle = this.weekTitle;

    return Column(
      children: [
        if (weekTitle != null)
        Padding(padding: const EdgeInsets.only(bottom: 2),
        child:
          Align(
              alignment: Alignment.center,
              child: Text(weekTitle,
                  style: Theme.of(context).textTheme.titleMedium))),
        // for (var event in events) ...[
        //   Text(event.event.title),
        //   Text(event.event.description),
        // ],
        for (final day in events
            .groupListsBy((element) =>
                (element.placement?.date ?? element.start)
                    .toIso8601String()
                    .substring(0, 10))
            .entries
            .sortedBy<String>((element) => element.key))
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
          EventDay(day: DateTime.parse(day.key), events: day.value)),
      ],
    );
  }
}
