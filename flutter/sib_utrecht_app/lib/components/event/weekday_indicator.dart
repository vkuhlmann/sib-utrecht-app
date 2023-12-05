import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../view_model/event/annotated_event.dart';

class WeekdayIndicator extends StatelessWidget {
  final AnnotatedEvent event;

  const WeekdayIndicator({Key? key, required this.event}) : super(key: key);

  // static Color otherColor = const HSLColor.fromAHSL(1.0, 291, 0.39, 0.49).toColor();
  static const Color otherColor = Color.fromRGBO(159, 76, 174, 1); 
  //Color.fromRGBO(156, 39, 176, 1);

  static final List<Color> weekdayColorsOrig = [
    otherColor, // Monday
    Colors.blue, 
    // const Color.fromRGBO(76, 130, 174, 1),
    // Tuesday
    otherColor, // Wednesday
    Colors.green, // Thursday
    otherColor, // Friday
    otherColor, // Saturday
    otherColor // Sunday
  ];

  static final List<Color> weekdayColors = [
    otherColor, // Monday
    // const Color.fromRGBO(76, 130, 174, 1), // Tuesday
    Colors.blue,
    otherColor, // Wednesday
    otherColor, // Thursday
    Colors.green, // Friday
    otherColor, // Saturday
    otherColor // Sunday
  ];
  
   //.map((e) => HSLColor.fromColor(e).withLightness(0.4).toColor()).toList();

  // final Map<String, List<String>> WeekDays = {
  //   "en_GB": ["mo", "tu", "we", "th", "fr", "sa", "su"],
  //   "nl_NL": ["ma", "di", "wo", "do", "vr", "za", "zo"],
  // };

  (Color, Color?) getColor(BuildContext context) {
    var date = event.placement?.date;
    HSLColor color = HSLColor.fromColor(otherColor);

    if (date != null) {
      List<Color> weekdayColors = WeekdayIndicator.weekdayColors;

      if (date.isBefore(DateTime(2023, 10, 21))) {
        weekdayColors = WeekdayIndicator.weekdayColorsOrig;
      }

      color = HSLColor.fromColor(weekdayColors[date.weekday - 1]);
    }

    color = color.withLightness(0.47);

    var placement = event.placement;
    if (placement != null && placement.isContinuation == true) {
      color =
          HSLColor.fromColor(Colors.orangeAccent).withLightness(0.4);
    }

    HSLColor activeColor = color.withLightness(0.7);

    if (Theme.of(context).brightness == Brightness.light) {
      color = color.withLightness(0.8);
      activeColor = activeColor.withLightness(0.6);
    }

    // if (event.participation?.isActive == true) {
    //   return activeColor;
    // }

    return (color.toColor(), event.participation?.isActive == true ? activeColor.toColor() : null);
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
              ? Text(DateFormat.E(Localizations.localeOf(context).toString()).format(placement.date))
              : const SizedBox()),
      // child: Text(WeekDays[Preferences.of(context).locale.toString()]![widget.event.start.weekday - 1])
    );

    // return Container(
    //   decoration: BoxDecoration(
    //       color: EventTile.weekdayColors[event.date.weekday - 1],
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
