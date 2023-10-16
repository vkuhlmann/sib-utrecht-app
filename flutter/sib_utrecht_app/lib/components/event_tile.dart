part of '../main.dart';

class EventTile extends StatefulWidget {
  // final DateTime date;
  final AnnotatedEvent event;

  // @override
  // final Event event;

  // @override
  // final bool isParticipating;
  // @override
  // final ValueSetter<bool> setParticipating;
  // @override
  // final bool isDirty;
  // @override
  // final DateTime date;

  // final bool isContinuation;

  const EventTile(
      {Key? key,
      required this.event,
      // required this.isParticipating,
      // required this.setParticipating,
      // required this.isDirty,
      // required this.date,
    })
      : super(key: key);

  @override
  State<EventTile> createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  final _timeFormat = DateFormat("HH:mm");

  // Widget buildSignupInteraction() => Builder(builder: (context) {
  //       if (widget.event.data["signup"]?["type"] == "none") {
  //         return const SizedBox();
  //       }

  //       if (widget.event.data["signup"] == null) {
  //         if (widget.event?.participation?.isDirty) {
  //           return const CircularProgressIndicator();
  //         }

  //         return Checkbox(
  //           value: widget.isParticipating,
  //           onChanged: widget.isContinuation
  //               ? null
  //               : (value) {
  //                   widget.setParticipating(value!);
  //                 },
  //         );
  //       }

  //       if (widget.event.data["signup"]["url"] != null) {
  //         if (widget.isContinuation) {
  //           return const SizedBox();
  //         }

  //         return IconButton(
  //             onPressed: () {
  //               launchUrl(Uri.parse(widget.event.data["signup"]["url"]))
  //                   .catchError((e) {
  //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //                     content: Text(
  //                         "Failed to open signup link: ${widget.event.data["signup"]["url"]}")));
  //               });
  //             },
  //             icon: const Icon(Icons.open_in_browser));
  //       }

  //       return const SizedBox();
  //     });

  @override
  Widget build(BuildContext context) {
    // bool isActive = widget.event.data["tickets"] != null &&
    //     widget.event.data["tickets"].length > 0;
    // Color color = EventTile.weekDayColors[widget.date.weekday - 1];
    // if (widget.isConinuation) {
    //   color =
    //       HSLColor.fromColor(Colors.orangeAccent).withLightness(0.4).toColor();
    // }

    // Color activeColor = HSLColor.fromColor(color).withLightness(0.7).toColor();

    // if (Theme.of(context).brightness == Brightness.light) {
    //   color = HSLColor.fromColor(color).withLightness(0.8).toColor();
    //   activeColor =
    //       HSLColor.fromColor(activeColor).withLightness(0.6).toColor();
    // }

    var placement = widget.event.placement;
    String? dayMonth;
    if (placement != null) {
      dayMonth = DateFormat.MMMd(Localizations.localeOf(context).toString())
                            .format(placement.date);
      dayMonth = dayMonth.replaceFirst(RegExp("\\.\$"), "");
    }

    String infoLine = "";
    bool showLocation = widget.event.location != null;
    bool showTime = widget.event.start.toIso8601String().substring(0, 10)
      == placement?.date.toIso8601String().substring(0, 10)
      && widget.event.start.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0)
      != widget.event.start;

    if (showLocation) {
      infoLine += "@ ${widget.event.location ?? 'Unknown'}";
    }

    if (showTime) {
      if (infoLine.isNotEmpty) {
        infoLine += ", ";
      }
      infoLine += _timeFormat.format(widget.event.start);
    }

    return InkWell(
        // onTap: (false && widget.event.data["post_id"] == null)
        //     ? null
        //     : () {
        //         GoRouter.of(context).go("/event/${widget.event.eventId}");
        //       },
        onTap: () {
          GoRouter.of(context).go("/event/${widget.event.eventId}");
        },
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Row(children: [
              WeekdayIndicator(event: widget.event),
              SizedBox(
                  width: 80,
                  child: dayMonth == null
                      ? const SizedBox()
                      : Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(0),
                          margin: const EdgeInsets.all(5),
                          child: 
                          Text(dayMonth)
                          // LocaleDateFormat(
                          //     format: "d MMM", date: placement.date)
                              )),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.all(5),
                      // child: Text(widget.event.eventName)
                      child: 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(widget.event.getLocalEventName(context)),
                        if (infoLine.isNotEmpty)
                          Text(infoLine, style: const TextStyle(color: Colors.grey, fontSize: 12))
                        // Row(mainAxisSize: MainAxisSize.min, children: [
                        //   if (widget.event.location != null)
                        //     Text("@ ${widget.event.location ?? ''}")
                          
                        // ],)
                        // Text(widget.event.getLocalEventLocation(context))
                      ])
                      )),
              if (placement?.isContinuation != true)
                SignupIndicator(event: widget.event),
              // if (widget.event.start.toIso8601String().substring(0, 10) ==
              //     placement?.date.toIso8601String().substring(0, 10))
              //   Container(
              //     alignment: Alignment.centerLeft,
              //     padding: const EdgeInsets.all(10),
              //     margin: const EdgeInsets.all(5),
              //     child: Text(_timeFormat.format(widget.event.start)),
              //     // Text(_timeFormat.format(widget.end)),
              //     // Text(start_time.format(context)),
              //     // Text(end_time.format(context))
              //     // Text('${widget.start.hour:2d}:${widget.start.minute}'),
              //     // Text('${widget.end.hour}:${widget.end.minute}'),
              //   )
            ])));
  }
}
