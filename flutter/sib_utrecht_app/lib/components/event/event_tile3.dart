import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/event/annotated_event.dart';

import 'signup_indicator.dart';

class EventTile3 extends StatefulWidget {
  final AnnotatedEvent event;

  const EventTile3({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventTile3> createState() => _EventTile3State();
}

class _EventTile3State extends State<EventTile3> {
  final _timeFormat = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
    var placement = widget.event.placement;
    String? dayMonth;
    if (placement != null) {
      dayMonth = DateFormat.MMMd(Localizations.localeOf(context).toString())
          .format(placement.date);
      dayMonth = dayMonth.replaceFirst(RegExp("\\.\$"), "");
    }

    String secondaryInfoLine = dayMonth ?? "";
    String primaryInfoLine = "";

    bool showTime = widget.event.start.toIso8601String().substring(0, 10) ==
            placement?.date.toIso8601String().substring(0, 10) &&
        widget.event.start.copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0) !=
            widget.event.start;

    bool showLocation = widget.event.location != null && showTime;
    // && (widget.event.placement?.isContinuation != true)

    if (showLocation) {
      String locationFull = widget.event.location ?? 'Unknown';
      RegExpMatch match = RegExp(r"^(?<name>.*?)( \((?<address>.*)\))?$")
          .firstMatch(locationFull)!;

      String locationName = match.namedGroup("name")!;
      // String locationAddress = match.namedGroup("address") ?? "";

      primaryInfoLine += "@ $locationName";
    }

    if (showTime) {
      if (primaryInfoLine.isNotEmpty) {
        primaryInfoLine += ", ";
      }
      primaryInfoLine += _timeFormat.format(widget.event.start);
    }

    // final format = DateFormat.EEEE(Localizations.localeOf(context).toString());
    // String? weekDay;
    // if (placement != null) {
    //   weekDay = format.format(placement.date);
    // }

    final bool isActive = widget.event.isActive;

    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: isActive
                ? BorderSide(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        :
                        // null
                        Theme.of(context).colorScheme.secondary)
                : BorderSide.none),
        color: Theme.of(context).colorScheme.primaryContainer,
        child: ListTile(
            onTap: () {
              GoRouter.of(context).push("/event/${widget.event.id}");
            },
            leading: (placement?.isContinuation != true)
                ? SignupIndicator.Maybe(widget.event)
                : null,
            title: Row(
              children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                          widget.event.getLocalEventName(
                              Localizations.localeOf(context)),
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.titleMedium),
                      if (primaryInfoLine.isNotEmpty)
                        Text(primaryInfoLine,
                            // textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                fontSize: 12))
                    ])),
                const SizedBox(width: 16),
                // SizedBox(
                //     width: 140,
                //     child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  if (secondaryInfoLine.isNotEmpty)
                    Align(
                        alignment: Alignment.centerRight,
                        child: Text(secondaryInfoLine,
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.grey[600]
                                    : Colors.grey[400],
                                fontSize: 12))),
                ]),
              ],
            )));
  }
}
