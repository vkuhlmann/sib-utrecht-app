part of '../main.dart';

class EventOngoing extends StatefulWidget implements AnnotatedEvent {
  @override
  final Event event;

  @override
  final bool isParticipating;
  @override
  final ValueSetter<bool> setParticipating;
  @override
  final bool isDirty;

  @override
  DateTime? get date => null;

  const EventOngoing(
      {Key? key,
      required this.event,
      required this.isParticipating,
      required this.setParticipating,
      required this.isDirty,
      })
      : super(key: key);

  @override
  State<EventOngoing> createState() => _EventOngoingState();
}

class _EventOngoingState extends State<EventOngoing> {
  @override
  Widget build(BuildContext context) {
    bool isActive = widget.event.data["tickets"] != null && widget.event.data["tickets"].length > 0;
    Color color = EventTile.weekDayColors[widget.event.start.weekday - 1];
    Color activeColor = HSLColor.fromColor(color).withLightness(0.7).toColor();

    if (Theme.of(context).brightness == Brightness.light) {
      color = HSLColor.fromColor(color).withLightness(0.8).toColor();
      activeColor = HSLColor.fromColor(activeColor).withLightness(0.6).toColor();
    }

    return InkWell(
        onTap: () {
          GoRouter.of(context).go("/event/${widget.event.eventId}");
        },
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Row(children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Container(
                    decoration: BoxDecoration(border: 
                    isActive ? Border.all(
                      // color: Colors isActive ? Colors.purple : Colors.grey,
                      color: activeColor,
                      width: 3
                    ) : null,
                    // color: Colors.grey
                    color: color
                    ),
                    alignment: Alignment.center,
                    // padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(5),
                    // color: Colors.blueAccent,
                    // child: Text('${widget.event.start.day}')),
                    child: const SizedBox()),
                    // child: Text(WeekDays[Preferences.of(context).locale.toString()]![widget.event.start.weekday - 1])
              ),
              SizedBox(
                  width: 80,
                  child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: const SizedBox())),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: Text(widget.event.eventName))),
              Container(
                  alignment: Alignment.center,
                  child: widget.isDirty
                      ? const CircularProgressIndicator()
                      : Checkbox(
                          value: widget.isParticipating,
                          onChanged: (value) {
                            widget.setParticipating(value!);
                          },
                        )),
              // Container(
              //     alignment: Alignment.centerLeft,
              //     padding: const EdgeInsets.all(10),
              //     margin: const EdgeInsets.all(5),
              //     child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           if (widget.event.start.toIso8601String().substring(0, 10) ==
              //               widget.date?.toIso8601String().substring(0, 10))
              //           Text(_timeFormat.format(widget.event.start)),
              //           // Text(_timeFormat.format(widget.end)),
              //           // Text(start_time.format(context)),
              //           // Text(end_time.format(context))
              //           // Text('${widget.start.hour:2d}:${widget.start.minute}'),
              //           // Text('${widget.end.hour}:${widget.end.minute}'),
              //         ]))
            ])));
  }
}
