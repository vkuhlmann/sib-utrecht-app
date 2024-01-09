import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/event/annotated_event.dart';

import 'signup_indicator.dart';

class EventTile2 extends StatefulWidget {
  final AnnotatedEvent event;

  const EventTile2({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventTile2> createState() => _EventTile2State();
}

class _EventTile2State extends State<EventTile2> {
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

    String primaryInfoLine = dayMonth ?? "";
    String secondaryInfoLine = "";

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

      secondaryInfoLine += "@ $locationName";
    }

    if (showTime) {
      // if (secondaryInfoLine.isNotEmpty) {
      //   secondaryInfoLine += ", ";
      // }
      // secondaryInfoLine += _timeFormat.format(widget.event.start);
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

    return
        // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //   if (weekDay != null)
        //     Padding(
        //         padding: const EdgeInsets.fromLTRB(8, 20, 0, 0),
        //         child: Text(weekDay)),
        //   Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 12),
        //       child:
        Card(
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
                    // if (placement?.isContinuation != true)
                    //       SignupIndicator(event: widget.event),
                    // if (placement?.isContinuation != true)
                    //   Padding(
                    //       padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    //       child: SignupIndicator(
                    //         event: widget.event,
                    //         isFixedWidth: false,
                    //       )),
                    Expanded(
                        child: Text(
                            widget.event.getLocalEventName(
                                Localizations.localeOf(context)),
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium)),
                    const SizedBox(width: 16),
                    // Expanded(
                    //     child:
                    //   Align(
                    // alignment: Alignment.centerRight,
                    // child: Container(
                    //     constraints: const BoxConstraints(maxWidth: 130),
                    SizedBox(
                        width: 140,
                        // alignment: Alignment.centerRight,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Container(
                              //     constraints: const BoxConstraints(minWidth: 55),
                              //     // alignment: Alignment.centerRight,
                              //     child:
                              // SizedBox(
                              //     width: 70,
                              //     child:
                              // dayMonth == null
                              //     ? const SizedBox()
                              //     : Align(
                              //         alignment: Alignment.centerRight,
                              //       child: Text(dayMonth)),
                              if (primaryInfoLine.isNotEmpty)
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(primaryInfoLine)),

                              // Container(
                              //     alignment: Alignment.center,
                              //     // padding: const EdgeInsets.all(0),
                              //     // margin: const EdgeInsets.all(5),
                              //     child: Text(dayMonth)),
                              if (secondaryInfoLine.isNotEmpty)
                                Text(secondaryInfoLine,
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[600]
                                            : Colors.grey[400],
                                        fontSize: 12))
                            ])),
                    // if (placement?.isContinuation != true)
                    //   Padding(
                    //       padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    //       child: SignupIndicator(
                    //         event: widget.event,
                    //         isFixedWidth: false,
                    //       ))
                    // else
                    //   const SizedBox(width: 50),
                  ],
                )));

    // return Container(
    //         alignment: Alignment.centerLeft,
    //         padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
    //         child: Row(children: [
    //           WeekdayIndicator(event: widget.event),
    //           Padding(padding: const EdgeInsets.fromLTRB(5, 0, 5, 0), child:
    //           Container(constraints: const BoxConstraints(minWidth: 55), child:
    //           // SizedBox(
    //           //     width: 70,
    //           //     child:
    //               dayMonth == null
    //                   ? const SizedBox()
    //                   : Container(
    //                       alignment: Alignment.center,
    //                       padding: const EdgeInsets.all(0),
    //                       margin: const EdgeInsets.all(5),
    //                       child:
    //                       Text(dayMonth)
    //                           ))),
    //           Expanded(
    //               child: Container(
    //                   alignment: Alignment.centerLeft,
    //                   padding: const EdgeInsets.all(0),
    //                   margin: const EdgeInsets.all(5),
    //                   child:
    //                   Column(
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                     Text(widget.event.getLocalEventName(Localizations.localeOf(context))),
    //                     if (infoLine.isNotEmpty)
    //                       Text(infoLine, style: TextStyle(color:
    //                       Theme.of(context).brightness == Brightness.light ? Colors.grey[600] : Colors.grey[400],
    //                       fontSize: 12))
    //                   ])
    //                   )),
    //           if (placement?.isContinuation != true)
    //             SignupIndicator(event: widget.event),
    //         ])));
  }
}
