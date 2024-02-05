import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DescriptionFuzzyExtract {
  static final RegExp extractHeaderLine = RegExp(
    '^\\s*(<strong>|[*])?(?<header>([^|<]+?\\s*\\|\\s*){2,10}[^|<]+?)\\s*(\\r?\\n?\\s*(</strong>|[*])|(\\r?\\n){1,10}\\s*)');

  static String? markdownToHtml(String text) {
    text = text.replaceAll("\n", "\n<br/>");

    text = text.replaceAllMapped(RegExp(r"\*(.*?)\*"), (match) {
      return "<strong>${match.group(1)}</strong>";
    });
    text = text.replaceAllMapped(RegExp(r"_(.*?)_"), (match) => 
      "<i>${match.group(1)}</i>"
    );
    text = text.replaceAllMapped(
      RegExp(r"([^a-zA-Z0-9_-])(https?://[^\s]+?)(\.?\)?\.?\s)"),
      (match) => 
        "${match.group(1)}<a href=\"${match.group(2)!}\">${match.group(2)}</a>${match.group(3)}"
      );

    return text;
  }

  static Future<DateTime?> tryExtractDate(String dateComponent,
      {DateTime? anchor}) async {
    const List<String> locales = ["en_US", "en_GB", "nl_NL"];
    const List<String> dateFormats = ["MMMMEEEEd", "MMMMd"];

    dateComponent = dateComponent.replaceAll(RegExp(
      " of |monday|tuesday|wednesday|thursday|friday|saturday|sunday", caseSensitive: false,), " ");
    dateComponent = dateComponent.replaceAllMapped(RegExp(
      r"(\d+)(th|st|nd|rd)(\s|$)", caseSensitive: false,), (match) => "${match.group(1)}${match.group(3)}");


    // log.info("Date component: $dateComponent");

    final anchorVal = anchor ?? DateTime.now();

    for (final loc in locales) {
      await initializeDateFormatting(loc, null);
    }
    RegExp exp = RegExp(r"^(?<main>.*?)(th|st|nd|rd)?\s*$");
    dateComponent = exp.firstMatch(dateComponent)!.namedGroup("main")!;

    for (final loc in locales) {
      for (final form in dateFormats) {
        try {
          DateTime dt = DateFormat(form, loc).parseLoose(dateComponent);

          final positionedDt = [
            dt.copyWith(year: anchorVal.year - 1),
            dt.copyWith(year: anchorVal.year),
            dt.copyWith(year: anchorVal.year + 1)
          ].sortedBy((element) => element.difference(anchorVal).abs()).first;

          return positionedDt;
        } on FormatException catch (_) {
          continue;
        }
      }
    }

    return null;
  }

  // "<strong>Ice Skating | Vechtsebanen (Mississippidreef 151) | Tuesday January 9th | 20:00 | Max \u20ac5,50\r\n<\/strong>\r\n\r\nIt\u2019s
  // a new year and start the year we\u2019re
  static Future<Map> extractFieldsFromDescription(String desc, {DateTime? anchor}) async {
    // RegExp('^\\s*(<strong>)?(?<title>[^|<]+?)\\s+\\|\\s+');

    final match = extractHeaderLine.firstMatch(desc);
    if (match == null) {
      return {};
    }

    final header = match.namedGroup("header")!;
    final fields = header
        .split("|")
        .map((s) => s.trim())
        .where((element) => element.isNotEmpty)
        .toList(growable: true);

    fields.removeWhere((element) => element.contains(RegExp(
          "${RegExp.escape("!!")}|${RegExp.escape("‼️")}",
        )));

    if (fields.isEmpty) {
      return {};
    }

    DateTime? start;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    DateTime? end;

    String? price;
    String? maxPrice;
    String? location;

    // fields = fields.sublist(1);

    // var unsortedFields = [];

    int firstRecognizedIndex = fields.length;

    for (int i = 0; i < fields.length; i++) {
      start = await tryExtractDate(fields[i], anchor: anchor);
      if (start == null) {
        // fields.add(fields.removeAt(i));
        continue;
      }

      fields.removeAt(i);
      firstRecognizedIndex = min(firstRecognizedIndex, i);
      break;
    }

    for (int i = 0; i < fields.length; i++) {
      RegExp timeExp =
          RegExp(r"^((?<startHour>\d{1,2})[:.](?<startMinute>\d{2}))\s*"
              r"(?:-\s*((?<endHour>\d{1,2})[:.](?<endMinute>\d{2})))?$");
      final timeMatch = timeExp.firstMatch(fields[i]);
      // if (timeMatch != null) {
      //   fields.removeAt(i);
      // }

      if (timeMatch == null) {
        continue;
      }

      // if (timeMatch != null) {
      // start = start.copyWith(
      //   hour: int.parse(timeMatch.namedGroup("startHour")!),
      //   minute: int.parse(timeMatch.namedGroup("startMinute")!),
      // );

      startTime = TimeOfDay(
          hour: int.parse(timeMatch.namedGroup("startHour")!),
          minute: int.parse(timeMatch.namedGroup("startMinute")!));

      if (timeMatch.namedGroup("endHour") != null) {
        endTime = TimeOfDay(
          hour: int.parse(timeMatch.namedGroup("endHour")!),
          minute: int.parse(timeMatch.namedGroup("endMinute")!),
        );
      }
      // }

      fields.removeAt(i);
      firstRecognizedIndex = min(firstRecognizedIndex, i);
      break;
    }

    if (start != null && startTime != null) {
      start = start.copyWith(
        hour: startTime.hour,
        minute: startTime.minute,
      );
    }

    if (start != null && endTime != null) {
      end = start.copyWith(
        hour: endTime.hour,
        minute: endTime.minute,
      );
    }

    if (fields.lastOrNull?.contains("€") == true) {
      price = fields.removeLast();
      firstRecognizedIndex = min(firstRecognizedIndex, fields.length);

      RegExp priceExp = RegExp(
          r"^[a-zA-Z _-]{0,10}\s*(€\d*[.,]?\d{1,2}[a-zA-Z]{0,10} -\s+)?"
          r"(Max\.?)?\s*€\s*(?<price>\d{1,6}(?:[.,]\d{1,2})?)(,-)?(max\.?)?$",
          caseSensitive: false);

      final match = priceExp.firstMatch(price);
      if (match != null) {
        price = match.namedGroup("price")!;
        // maxPrice = double.tryParse(price.replaceAll(",", "."));
        maxPrice = "€${price.replaceAll(',', '.')}";
      }
    }

    if (fields.length == 2) {
      location = fields.removeAt(1);
    }
    if (fields.length > 2) {
      final res = fields
          .mapIndexed<(int, String)>(
            (index, element) => (index, element),
          )
          .lastWhereOrNull((element) => element.$2.contains(
              RegExp("caf[ée]|cervantes|laan|straat", caseSensitive: false)));

      if (res != null) {
        location = res.$2;
        firstRecognizedIndex = min(firstRecognizedIndex, res.$1);
        fields.removeAt(res.$1);
      }
    }

    String title = fields[0];
    // return {
    //   "fields": fields
    // };

    if (fields.length == 2 && firstRecognizedIndex >= 2) {
      title = fields.sublist(0, 2).join(" | ");
    }

    // final String? date = fields.elementAtOrNull(2);
    // final String? time = fields.elementAtOrNull(3);
    // final date = fields[2];
    // final time = fields[3];

    // final DateTime? start = DateTime.tryParse("$date $time");
    // final startDateFormat = DateFormat("MMMMEEEEd");
    // DateTime d = startDateFormat.parse(date);

    String formatTimeOfDay(TimeOfDay time) {
      return "${time.hour.toString().padLeft(2, '0')}"
          ":${time.minute.toString().padLeft(2, '0')}";
    }

    return {
      "name.long": title,
      if (location != null) "location": location,
      if (start != null) "date.start": start,
      if (end != null) "date.end": end,
      if (startTime != null && start == null)
        "date.start_time": formatTimeOfDay(startTime),
      if (endTime != null && end == null)
        "date.end_time": formatTimeOfDay(endTime),
      if (maxPrice != null) "participate.price.max": maxPrice,
      // "firstRecognizedIndex": firstRecognizedIndex,
    };
  }

}