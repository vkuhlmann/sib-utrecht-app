import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/components/event/event_tile3.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';

class EventDay extends StatelessWidget {
  final DateTime day;
  final List<AnnotatedEvent> events;

  const EventDay({Key? key, required this.day, required this.events})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final day = this.day;

    final weekdayFormat =
        DateFormat.EEEE(Localizations.localeOf(context).toString());
    // String? weekDay;
    // if (placement != null) {
    //   weekDay = format.format(placement.date);
    // }

    String dayMonth =
        DateFormat.MMMd(Localizations.localeOf(context).toString()).format(day);
    dayMonth = dayMonth.replaceFirst(RegExp("\\.\$"), "");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if (day != null)
        Padding(
            padding: const EdgeInsets.fromLTRB(8, 20, 0, 4),
            child: Row(children: [
              Text(weekdayFormat.format(day),
                  style: Theme.of(context).textTheme.titleSmall),
              Expanded(
                child: Container(),
              ),
              // Text(dayMonth,
              //     style: TextStyle(
              //         color: Theme.of(context).brightness == Brightness.light
              //             ? Colors.grey[600]
              //             : Colors.grey[400], fontSize: 12)),
              const SizedBox(width: 20)
            ])),
        for (final event in events) ...[
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: EventTile3(
                  key:
                      ValueKey(("eventsItem", event.id, event.placement?.date)),
                  event: event)),
        ],
        // Padding(
        //     padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        //     child:
        //         Align(alignment: Alignment.centerRight, child: Text(dayMonth)))
      ],
    );
  }
}
