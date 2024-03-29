import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

    final ev = widget.event;
    final meetup = ev.participate.meetup;
    final meetupTime = meetup.time;

    bool showTime = meetup.time?.toIso8601String().substring(0, 10) ==
            placement?.date.toIso8601String().substring(0, 10) &&
        meetup.time?.copyWith(
                hour: 0,
                minute: 0,
                second: 0,
                millisecond: 0,
                microsecond: 0) !=
            meetup.time;

    bool showLocation = meetup.location != null;
    // && (widget.event.placement?.isContinuation != true)

    if (showLocation) {
      String locationFull = meetup.location ?? 'Unknown';
      RegExpMatch match = RegExp(r"^(?<name>.*?)( \((?<address>.*)\))?$")
          .firstMatch(locationFull)!;

      String locationName = match.namedGroup("name")!;
      // String locationAddress = match.namedGroup("address") ?? "";

      primaryInfoLine += "@ $locationName";
    }

    if (showTime && meetupTime != null) {
      if (primaryInfoLine.isNotEmpty) {
        primaryInfoLine += ", ";
      }
      primaryInfoLine += _timeFormat.format(meetupTime);
    }

    // final format = DateFormat.EEEE(Localizations.localeOf(context).toString());
    // String? weekDay;
    // if (placement != null) {
    //   weekDay = format.format(placement.date);
    // }

    final bool isActive = ev.participate.signup.available ?? false;

    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side:
                // isActive
                //     ? BorderSide(
                //       width: 3,
                //         color: isActive
                //             ?
                //             Theme.of(context).colorScheme.onSecondary
                //             // Theme.of(context).colorScheme.primaryContainer
                //             // Theme.of(context).colorScheme.onPrimary
                //             :
                //             // null
                //             Theme.of(context).colorScheme.secondary)
                //     :
                BorderSide.none),
        color: Theme.of(context).colorScheme.primaryContainer,
        clipBehavior: Clip.antiAlias,
        child: Row(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // if (placement?.isContinuation != true)
              // Column(children: [
              //   Expanded(child:
              Container(
                  decoration: BoxDecoration(
                      color: 
                      isActive ? 
                      Theme.of(context).colorScheme.onPrimary
                      :
                      Theme.of(context).colorScheme.onPrimary,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8)),
                      border: isActive && false
                          ? 
                          // Border.all(
                          //     width: 3,
                          //     color: 
                          //     Colors.purpleAccent.withAlpha(100)
                          //     // Theme.of(context).colorScheme.primary.withAlpha(100)
                          //     )
                          Border(
                            left: BorderSide(
                              width: 3,
                              color: 
                              Colors.purpleAccent.withAlpha(100)
                              // Theme.of(context).colorScheme.primary.withAlpha(100)
                              ),
                              top: BorderSide(
                              width: 3,
                              color: 
                              Colors.purpleAccent.withAlpha(100)
                              // Theme.of(context).colorScheme.primary.withAlpha(100)
                              ),
                              bottom: BorderSide(
                              width: 3,
                              color: 
                              Colors.purpleAccent.withAlpha(100)
                              // Theme.of(context).colorScheme.primary.withAlpha(100)
                              )
                          )
                          : null),
                  // color: Theme.of(context).colorScheme.onPrimary,
                  // width: 40,
                  // constraints:
                  //     const BoxConstraints(maxWidth: 40, maxHeight: 100),
                  width: 55,
                  height: 60,
                  // height: 80,
                  child: Center(
                      child: placement?.isContinuation != true
                          ? SignupIndicator.Maybe(widget.event)
                          : const SizedBox())),
              // ]),
              Expanded(
                  child:
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   mainAxisSize: MainAxisSize.min,
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      // Container()
                      ListTile(
                          onTap: () {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              GoRouter.of(context)
                                  .push("/event/${widget.event.id}");
                            });
                          },
                          // leading:
                          // (placement?.isContinuation != true)
                          //     ? Container(
                          //         color: Colors.purple,
                          //         width: 40,
                          //         child: SignupIndicator.Maybe(widget.event))
                          //     : null,
                          title: Row(
                            children: [
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    // const SizedBox(height: 60),
                                    Text(
                                        widget.event.name.getLocalLong(
                                            Localizations.localeOf(context)),
                                        textAlign: TextAlign.left,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium),
                                    if (primaryInfoLine.isNotEmpty)
                                      Text(primaryInfoLine,
                                          // textAlign: TextAlign.right,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400],
                                              fontSize: 12))
                                  ])),
                              const SizedBox(width: 16),
                              // SizedBox(
                              //     width: 140,
                              //     child:
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (secondaryInfoLine.isNotEmpty)
                                      Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(secondaryInfoLine,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? Colors.grey[600]
                                                      : Colors.grey[400],
                                                  fontSize: 12))),
                                  ]),
                            ],
                          )))
            ]));
  }
}
