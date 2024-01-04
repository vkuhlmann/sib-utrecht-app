import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

@immutable
class Month implements Comparable<Month> {
  final int year;
  final int month;

  // DateTime get _firstWeekAnchor => DateTime(year, month, 4);

  const Month(this.year, this.month);

  Month.fromDate(DateTime dt) : this(dt.year, dt.month);

  DateTime get start => DateTime(year, month, 1);

  Month get nextMonth => Month.fromDate(start.add(const Duration(days: 40)));

  // Should resolve DateTime(2024, 13, 1) to DateTime(2025, 1, 1)
  // DateTime get end => DateTime(year, month + 1, 1);
  DateTime get end => nextMonth.start;


  Week get firstWeek => Week.fromDate(DateTime(year, month, 4));

  Iterable<Week> get weeks sync* {
    Week w = firstWeek;

    Week end = nextMonth.firstWeek;
    while (w < end) {
      yield w;
      w += 1;
    }
  }

  Iterable<Week> get coveringWeeks sync* {
    Week w = Week.fromDate(start);
    Week lastWeek = Week.fromDate(end.subtract(const Duration(hours: 1)));

    while (w <= lastWeek) {
      yield w;
      w += 1;
    }
  }

  String toDisplayString(BuildContext context, {bool standalone = true})
  => toLocalString(Localizations.localeOf(context), standalone: standalone);

  String toLocalString(Locale loc, {bool standalone = true}) {
    String val = DateFormat("yMMMM", loc.toString())
        .format(DateTime(year, month, 1));
    if (standalone) {
      val = toBeginningOfSentenceCase(val, loc.toString()) ?? val;
    }

    return val;
  }
  // Week lastWeek() => Week.fromDate(DateTime(year, month + 1, 4)) + (-1);

  @override
  String toString() => "$year-${month.toString().padLeft(2, '0')}";

  @override
  int compareTo(Month other) => toString().compareTo(other.toString());

  bool operator <(Month other) => compareTo(other) < 0;
  bool operator <=(Month other) => compareTo(other) <= 0;
  bool operator >(Month other) => compareTo(other) > 0;
  bool operator >=(Month other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Month &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

@immutable
class Week implements Comparable<Week> {
  static final RegExp _weekExp =
      RegExp(r"^(?<year>\d{4})-W(?<weekNum>\d{1,2})$");

  final DateTime start;
  DateTime get end => start.add(const Duration(days: 7));
  final int year;
  final int weekNum;

  DateTime get startUTC => start.toUtc();
  DateTime get endUTC => end.toUtc();

  DateTime get anchor => start.add(const Duration(days: 3));

  Month get month => Month.fromDate(anchor);

  static DateTime toWeekday(DateTime dt, int weekday) {
    return dt.add(Duration(days: weekday - dt.weekday));
  }

  static DateTime toWeekBegin(DateTime dt) => toWeekday(dt, DateTime.monday);

  static DateTime getDay(int year, int weekNum, int weekday) => toWeekday(
      DateTime(year, 1, 4).add(Duration(days: (weekNum - 1) * 7)), weekday);

  Week._(this.year, this.weekNum)
      : start = getDay(year, weekNum, DateTime.monday);

  // Get a tuple of the ISO year and week number, e.g.:
  //   - 2023-01-01 is in 2022-W52, hence returns (2022, 52)
  //   - 2024-12-25 is in 2024-W52, hence returns (2024, 52)
  //   - 2024-12-30 is in 2025-W01, hence returns (2025, 1)
  //
  // The first week of the year contains 4 January. (majority of days in the new
  // year)
  factory Week.fromDate(DateTime dt) {
    DateTime thursday = toWeekday(dt, DateTime.thursday);
    int year = thursday.year;
    DateTime firstWeek = getDay(year, 1, DateTime.monday);

    return Week._(year, thursday.difference(firstWeek).inDays ~/ 7 + 1);
  }

  factory Week.fromYearWeek(int year, int weekNum) {
    return Week._(year, weekNum);
  }

  factory Week.parse(String s) {
    // RegExp exp = RegExp(r"(\d{4})-W(\d{2})");
    final weekNumMatch = _weekExp.firstMatch(s);
    if (weekNumMatch != null) {
      return Week.fromYearWeek(int.parse(weekNumMatch.namedGroup("year")!),
          int.parse(weekNumMatch.namedGroup("weekNum")!));
    }

    return Week.fromDate(DateTime.parse(s));
  }

  int operator -(Week other) =>
      start.add(const Duration(days: 1)).difference(other.start).inDays ~/ 7;

  Week advance(int weeks) => this + weeks;

  Week operator +(int weeks) =>
      Week.fromDate(start.add(Duration(days: weeks * 7)));

  Week get previous => advance(-1);
  Week get next => advance(1);

  // Week operator -(int weeks) => Week.fromDate(start.subtract(Duration(days: weeks * 7)));

  bool operator <(Week other) => anchor.isBefore(other.start);
  bool operator <=(Week other) =>
      (this < other) || (year == other.year && weekNum == other.weekNum);

  bool operator >(Week other) => !(this <= other);
  
  bool operator >=(Week other) => !(this < other);

  @override
  bool operator ==(Object other) =>
      other is Week && year == other.year && weekNum == other.weekNum;

  @override
  int get hashCode => toString().hashCode;
  

  @override
  String toString() {
    return "$year-W${weekNum.toString().padLeft(2, '0')}";
  }

  @override
  int compareTo(Week other) {
    if (year == other.year && weekNum == other.weekNum) {
      return 0;
    }

    if (this < other) {
      return -1;
    }

    return 1;
  }

  static Iterable<Week> range(Week minWeek, Week maxWeek) sync* {
    Week w = minWeek;
    while (w <= maxWeek) {
      yield w;
      w += 1;
    }
  }
}
