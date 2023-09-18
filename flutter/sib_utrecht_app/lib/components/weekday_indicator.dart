part of '../main.dart';

class WeekdayIndicator extends StatelessWidget {
  final AnnotatedEvent event;

  const WeekdayIndicator({Key? key, required this.event}) : super(key: key);

  static const Color otherColor = Colors.pink;

  static final List<Color> weekDayColors = [
    Colors.pink, // Monday
    Colors.blueAccent, // Tuesday
    Colors.pink, // Wednesday
    Colors.green, // Thursday
    Colors.pink, // Friday
    Colors.pink, // Saturday
    Colors.pink // Sunday
  ]; //.map((e) => HSLColor.fromColor(e).withLightness(0.4).toColor()).toList();

  // final Map<String, List<String>> WeekDays = {
  //   "en_GB": ["mo", "tu", "we", "th", "fr", "sa", "su"],
  //   "nl_NL": ["ma", "di", "wo", "do", "vr", "za", "zo"],
  // };

  (Color, Color?) getColor(BuildContext context) {
    var date = event.placement?.date;
    Color color = date == null ? otherColor : WeekdayIndicator
        .weekDayColors[date.weekday - 1];

    var placement = event.placement;
    if (placement != null && placement.isContinuation == true) {
      color =
          HSLColor.fromColor(Colors.orangeAccent).withLightness(0.4).toColor();
    }

    Color activeColor = HSLColor.fromColor(color).withLightness(0.7).toColor();

    if (Theme.of(context).brightness == Brightness.light) {
      color = HSLColor.fromColor(color).withLightness(0.8).toColor();
      activeColor =
          HSLColor.fromColor(activeColor).withLightness(0.6).toColor();
    }

    // if (event.participation?.isActive == true) {
    //   return activeColor;
    // }

    return (color, event.participation?.isActive == true ? activeColor : null);
  }

  @override
  Widget build(BuildContext context) {
    final (c, borderColor) = getColor(context);
    // var date = event.date;
    var placement = event.placement;

    return SizedBox(
      width: 50,
      height: 50,
      child: Container(
          decoration: BoxDecoration(
              border: borderColor == null
                  ? null
                  : Border.all(
                      // color: Colors isActive ? Colors.purple : Colors.grey,
                      color: borderColor,
                      width: 3),
              // color: Colors.grey
              color: c),
          alignment: Alignment.center,
          // padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(5),
          // color: Colors.blueAccent,
          // child: Text('${widget.event.start.day}')),
          child: placement != null
              ? LocaleDateFormat(format: "E", date: placement.date)
              : const SizedBox()),
      // child: Text(WeekDays[Preferences.of(context).locale.toString()]![widget.event.start.weekday - 1])
    );

    // return Container(
    //   decoration: BoxDecoration(
    //       color: EventTile.weekDayColors[event.date.weekday - 1],
    //       borderRadius: BorderRadius.circular(4)),
    //   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    //   child: Text(
    //     DateFormat(Platform.localeName == "nl_NL" ? "EEEEE" : "EEE")
    //         .format(event.date),
    //     style: const TextStyle(color: Colors.white),
    //   ),
    // );
  }
}
