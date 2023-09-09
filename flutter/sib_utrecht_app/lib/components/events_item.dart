part of '../main.dart';

class EventsItem extends StatefulWidget {
  final Event event;

  final bool isParticipating;
  final ValueSetter<bool> setParticipating;
  final bool isDirty;
  final DateTime date;

  static const List<Color> weekDayColors = [
    Colors.pink, // Monday
    Colors.blueAccent, // Tuesday
    Colors.pink, // Wednesday
    Colors.green, // Thursday
    Colors.pink, // Friday
    Colors.pink, // Saturday
    Colors.pink  // Sunday
  ];

  const EventsItem(
      {Key? key,
      required this.event,
      required this.isParticipating,
      required this.setParticipating,
      required this.isDirty,
      required this.date
      })
      : super(key: key);

  @override
  State<EventsItem> createState() => _EventsItemState();
}

class _EventsItemState extends State<EventsItem> {
  final _timeFormat = DateFormat("HH:mm");

  // final Map<String, List<String>> WeekDays = {
  //   "en_GB": ["mo", "tu", "we", "th", "fr", "sa", "su"],
  //   "nl_NL": ["ma", "di", "wo", "do", "vr", "za", "zo"],
  // };

  @override
  Widget build(BuildContext context) {
    bool isActive = widget.event.data["tickets"] != null && widget.event.data["tickets"].length > 0;
    Color color = EventsItem.weekDayColors[widget.event.start.weekday - 1];

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
                      color: HSLColor.fromColor(color).withLightness(0.7).toColor(),
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
                    child: LocaleDateFormat(
                        format: "E", date: widget.event.start)),
                    // child: Text(WeekDays[Preferences.of(context).locale.toString()]![widget.event.start.weekday - 1])
              ),
              SizedBox(
                  width: 80,
                  child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: LocaleDateFormat(
                          format: "d MMM", date: widget.event.start))),
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
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_timeFormat.format(widget.event.start)),
                        // Text(_timeFormat.format(widget.end)),
                        // Text(start_time.format(context)),
                        // Text(end_time.format(context))
                        // Text('${widget.start.hour:2d}:${widget.start.minute}'),
                        // Text('${widget.end.hour}:${widget.end.minute}'),
                      ]))
            ])));
  }
}
