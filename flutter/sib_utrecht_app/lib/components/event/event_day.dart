import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/components/event/event_tile2.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';

class EventDay extends StatelessWidget {
  final DateTime? day;
  final List<AnnotatedEvent> events;

  const EventDay({Key? key, required this.day, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = this.day;

    final weekdayFormat = DateFormat.EEEE(Localizations.localeOf(context).toString());
    // String? weekDay;
    // if (placement != null) {
    //   weekDay = format.format(placement.date);
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (day != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 0, 0),
            child: Text(weekdayFormat.format(day),
                style: Theme.of(context).textTheme.titleSmall)),
        for (final event in events) ...[
          Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: 
          EventTile2(
          key: ValueKey(("eventsItem", event.id, event.placement?.date)),
          event: event)),
          ],
      ],
    );
  }
}
