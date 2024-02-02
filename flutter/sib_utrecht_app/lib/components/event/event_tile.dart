import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/event/annotated_event.dart';

import 'weekday_indicator.dart';
import 'signup_indicator.dart';

class EventTile extends StatefulWidget {
  final AnnotatedEvent event;

  const EventTile(
      {Key? key,
      required this.event,
    })
      : super(key: key);

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
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

    final ev = widget.event;

    String infoLine = "";

    final meetup = ev.participate.meetup;
    final meetupTime = meetup.time;

    // final meetupLocation = meetup.location;
    
    bool showTime = meetup.time?.toIso8601String().substring(0, 10)
      == placement?.date.toIso8601String().substring(0, 10)
      && meetup.time?.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
      != meetup.time;

    
    bool showLocation = meetup.location != null;
      // && showTime;
      // && (widget.event.placement?.isContinuation != true)

    if (showLocation) {
      infoLine += "@ ${meetup.location ?? 'Unknown'}";
    }

    if (showTime && meetupTime != null) {
      if (infoLine.isNotEmpty) {
        infoLine += ", ";
      }
      infoLine += _timeFormat.format(meetupTime);
    }

    return InkWell(
        onTap: () {
          GoRouter.of(context).push("/event/${widget.event.id}");
        },
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Row(children: [
              WeekdayIndicator(event: widget.event),
              Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child:
              Container(constraints: const BoxConstraints(minWidth: 55), child:
              // SizedBox(
              //     width: 70,
              //     child: 
                  dayMonth == null
                      ? const SizedBox()
                      : Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(0),
                          margin: const EdgeInsets.all(5),
                          child: 
                          Text(dayMonth)
                              ))),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.all(5),
                      child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(ev.name.getLocalLong(Localizations.localeOf(context))),
                        if (infoLine.isNotEmpty)
                          Text(infoLine, style: TextStyle(color:
                          Theme.of(context).brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
                          fontSize: 12))
                      ])
                      )),
              if (placement?.isContinuation != true)
                SignupIndicator(event: widget.event, isFixedWidth: false,),
            ])));
  }
}
