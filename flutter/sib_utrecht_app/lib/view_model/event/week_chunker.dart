import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum RelativeWeek {
  past,
  lastWeek,
  upcomingWeek,
  nextWeek,
  future,
  ongoing,
}

class EventsGroupInfo<T> {
  String key;
  String Function(BuildContext) title;
  List<T> elements;
  bool isMultiWeek;

  EventsGroupInfo(
      {required this.key,
      required this.title,
      required this.elements,
      required this.isMultiWeek});
}

class WeekChunked<T> {
  late bool isLookingAhead;
  late Map<RelativeWeek, List<EventsGroupInfo<T>>> superGroups;

  String keyToTitle(BuildContext context, RelativeWeek key, bool lookAhead) {
    var loc = AppLocalizations.of(context)!;
    Map<RelativeWeek, String> weekIdMap = {
      RelativeWeek.past: "Past",
      RelativeWeek.lastWeek: loc.lastWeek,
      RelativeWeek.upcomingWeek: lookAhead ? loc.upcomingWeek : loc.thisWeek,
      RelativeWeek.nextWeek:
          lookAhead ? loc.weekAfterUpcomingWeek : loc.nextWeek,
      RelativeWeek.future: loc.future,
      RelativeWeek.ongoing: loc.eventCategoryOngoing,
    };

    var a = weekIdMap[key];
    if (a != null) {
      return a;
    }

    return key.toString();
  }

  String formatMonthYear(BuildContext context, String key) {
    DateTime d;
    try {
      d = DateFormat("y-M").parse(key);
    } on FormatException catch (_) {
      return key;
    }

    String val = DateFormat("yMMMM", Localizations.localeOf(context).toString())
        .format(d);

    return toBeginningOfSentenceCase(
            val, Localizations.localeOf(context).toString()) ??
        val;
  }

  static String getMonthYear(DateTime date) {
    // return DateFormat("y-M").format(date);
    date = date.subtract(Duration(days: date.weekday - 4));
    return date.toIso8601String().substring(0, 7);
  }

  WeekChunked(List<T> items, DateTime? Function(T) getDate) {
    DateTime now = DateTime.now();

    String currentWeek = formatWeekNumber(now);

    DateTime? lastInCurrentWeek = items
        .map(getDate)
        .where((v) => v != null)
        .map((v) => v!)
        .where((v) => formatWeekNumber(v) == currentWeek)
        .sortedBy((v) => v)
        .lastOrNull;

    DateTime upcomingAnchor = now.add(const Duration(days: 3));
    DateTime? activeEnd = lastInCurrentWeek?.add(const Duration(hours: 2));

    if (activeEnd != null && activeEnd.isAfter(now) == true) {
      upcomingAnchor = now;
    }

    String upcomingWeek = formatWeekNumber(upcomingAnchor);

    String pastWeek =
        formatWeekNumber(upcomingAnchor.subtract(const Duration(days: 7)));
    String nextWeek =
        formatWeekNumber(upcomingAnchor.add(const Duration(days: 7)));

    var groups = groupBy(items, (e) {
      var date = getDate(e);
      if (date == null) {
        return RelativeWeek.ongoing;
      }

      String weekId = formatWeekNumber(date);

      if (weekId.compareTo(pastWeek) < 0) {
        return RelativeWeek.past;
      }
      if (weekId == pastWeek) {
        return RelativeWeek.lastWeek;
      }
      if (weekId == upcomingWeek) {
        return RelativeWeek.upcomingWeek;
      }
      if (weekId == nextWeek) {
        return RelativeWeek.nextWeek;
      }
      if (weekId.compareTo(nextWeek) > 0) {
        return RelativeWeek.future;
      }

      return RelativeWeek.future;
    });

    isLookingAhead = upcomingWeek != currentWeek;

    superGroups = groups.map((key, value) {
      if (key != RelativeWeek.past && key != RelativeWeek.future) {
        return MapEntry(key, [
          EventsGroupInfo(
            key: key.toString(),
            title: (context) => keyToTitle(context, key, isLookingAhead),
            elements: value,
            isMultiWeek: key == RelativeWeek.future,
          )
        ]);
      }

      var pastGroups = groupBy(value, (e) => getMonthYear(getDate(e)!))
          // .map((key, value) => MapEntry(formatMonthYear(key), value));
          .entries
          .sortedBy((element) => element.key)
          .map((element) => EventsGroupInfo(
              key: element.key,
              title: (context) => formatMonthYear(context, element.key),
              elements: element.value,
              isMultiWeek: true));

      return MapEntry(key, pastGroups.toList());
    });
  }
}
