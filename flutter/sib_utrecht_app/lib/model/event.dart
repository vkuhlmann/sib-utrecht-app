import 'dart:core';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/fragments_bundle.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';

final RegExp extractHeaderLine = RegExp(
    '^\\s*(<strong>|[*])?(?<header>([^|<]+?\\s*\\|\\s*){2,10}[^|<]+?)\\s*(\\r?\\n?\\s*(</strong>|[*])|(\\r?\\n){1,10}\\s*)');

class EventBody implements CacheableResource {
  @override
  final String id;

  final FragmentsBundle data;
  // final String? description;

  EventBody({required this.id, required this.data});

  factory EventBody.fromJson(Map data) {
    return EventBody(id: data["id"], data: FragmentsBundle.fromMap(data));
  }

  String? processThumbnailUrl(String? url) {
    if (url == null) {
      return null;
    }

    if (!url.startsWith("http")) {
      url = "$wordpressUrl/$url";
    }

    if (url.startsWith("http://sib-utrecht.nl/")) {
      url =
          url.replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
    }

    log.info("Processing thumbnail url: $url");
    if (url.startsWith("https://sib-utrecht.nl/wp-content/uploads/")) {
      RegExp exp = RegExp(r"-\d+x\d+(\.[a-zA-Z]{1,4})$");
      url = url.replaceFirstMapped(exp, (match) => match.group(1) ?? "");
    }

    log.info("Final thumbnail url: $url");
    return url;
  }

  (String?, String?) extractDescriptionAndThumbnail() {
    String description =
        (data.get<String>(["description.html", "description"]) ?? "")
            .replaceAll("\r\n\r\n", "<br/><br/>");
    // Map? thumbnail = data["thumbnail"] ?? data["image"];

    String? imageUrl = data.get<String>([
      "description.image.url",
      "description.image",
    ]);

    // if (thumbnail != null &&
    //     thumbnail["url"] != null &&
    //     !(thumbnail["url"] as String).startsWith("http")) {
    //   thumbnail["url"] = "$wordpressUrl/${thumbnail["url"]}";
    // }

    if (imageUrl == null && description.contains("<img")) {
      final img = RegExp("<img[^>]+src=\"(?<url>[^\"]+)\"[^>]*>")
          .firstMatch(description);

      if (img != null) {
        imageUrl = img.namedGroup("url");
        // description = description.replaceAll(img.group(0)!, "");
        description = description.replaceFirst(img.group(0)!, "");
      }
    }

    // if (thumbnail != null &&
    //     thumbnail["url"] != null &&
    //     (thumbnail["url"] as String).startsWith("http://sib-utrecht.nl/")) {
    //   thumbnail["url"] = (thumbnail["url"] as String)
    //       .replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
    // }

    if (imageUrl != null) {
      imageUrl = processThumbnailUrl(imageUrl);
    }

    description = description.replaceAll(
        RegExp("^(<strong></strong>)?(\r|\n|<br */>|<br *>)*",
            multiLine: false),
        "");

    return (description.isEmpty ? null : description, imageUrl);
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
  static Future<Map> extractFieldsFromDescription(String desc) async {
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
      start = await tryExtractDate(fields[i]);
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

  @override
  Map toJson() => data.toPayload();
}

const Map<String, String> fallbackLabels = {
  "Ice Skating": "Ice skating",
  "70’s Cantus and Party": "Cantus",
  "Study session": "Studying",
  "Talk: fighting piracy in Somalia": "Talk",
  "Piracy-themed VriMiBo": "VriMiBo",
  "Half-year GMA": "GMA",
  "Christmas Card Crafting for the elderly": "X-mas cards",
  "Cooking classes": "Cooking",
  "Christmas Village Competition": "Gingerbread houses",
  "SIB-NL talk: From Invention to Innovation": "SIB-NL talk",
  "Fall trip to Brussels": "Fall trip",
  "Guard Duty Constitutional Drinks (CoBo)": "CoBo",
  "HapHop Member Consultation Moment": "MCM",
  "Boomer Society: NPO Radio 2 Top 2000 Pubquiz": "Pubquiz",
  "Mezrab's comedy night": "Comedy night",
  "Verkiezingsdebat": "Verkiez.debat",
  "SIB NL Dinner": "SIB-NL",
  "Pooling & inauguration": "Inauguration",
  "Study Session": "Studying",
  "Talk on Peace negotiations": "Talk",
  "Oktober fest themed drinks": "Drinks",
  "Meet the Sibbers drink": "Drinks",
  "Canoening at night": "Canoening",
  "Decorate your (student)room!": "Creative night",
  "September camp": "Camp!",
  "Talk on KNMI": "Talk",
  "Talk on Cold War Espionage": "Talk",
  "Day-trip to The Hague": "Day-trip",
  "Inauguration GMA": "Inaug GMA",
  "End of year Pizza": "Pizza",
  "End of Year Party": "Party",
  "Back to the Ages Party": "Party",
  "Acapella Society Karaoke": "Karaoke",
  "IC Cantus: De Zatte Zingende Zeerovers": "Cantus",
  "Be your own hero - laser tag": "Laser tag",
  "HEIMWEEK | Give a rose": "Valentine",
  "HEIMWEEK | Candle Pot Painting": "Candle pot painting",
  "HEIMWEEK | Summer VriMiBo": "VriMiBo",
  "Wine tasting with the Tussentijd": "Wine tasting",
  "Utrecht Tour by (ex-)homeless person": "Tour",
  // "Battle of the pirates activity": ""
};

class EventName {
  final FragmentsBundle _data;

  const EventName(this._data);

  // int get eventId => data["event_id"];
  // String get eventId => data["event_id"];
  String get long =>
      _data.get<String>(["name.long.en", "name.long", "name"]) ??
      "<Missing title>";

  String get longNL => _data.get<String>(["name.long.nl"]) ?? long;

  String? get shortOrNull => _data.get<String>(["name.short.en", "name.short"]);

  String get short => shortOrNull ?? long;

  String? get labelOrNull =>
      _data.get<String>([
        "name.label.en",
        "name.label",
      ]) ??
      fallbackLabels[long];

  String get label => labelOrNull ?? short;

  String getLocalLong(Locale loc) {
    if (loc.languageCode == "nl") {
      return longNL;
    }
    return long;
  }
}

@immutable
class EventDate {
  static DateTime? parseDate(String? date) {
    if (date == null) {
      return null;
    }

    return DateTime.parse(date).toLocal();
  }

  EventDate(FragmentsBundle data)
      : start = parseDate(data.get<String>(["date.start", "date"])) ??
            DateTime(2025, 1, 1),
        end = parseDate(data.get<String>(["date.end", "date"]));

  final DateTime start;
  final DateTime? end;
}

class EventParticipateMeetup {
  final String? location;
  final DateTime? time;

  EventParticipateMeetup({required this.location, required this.time});
}

class EventParticipateSignup {
  final FragmentsBundle _data;

  String? get method =>
      _data.get<String>(["participate.signup.method", "participate.signup"]);
  String? get url => _data.get<String>(["participate.signup.url"]);
  DateTime? get end =>
      EventDate.parseDate(_data.get<String>(["participate.signup.end"]));
  bool? get available => _data.get<bool>(["participate.signup.available"]);
  int? get spaces => _data.get<int>(["participate.signup.spaces"]);
  int? get ticketCount => _data.get<int>(["participate.signup.ticket_count"]);

  Map? toJson() {
    return _data.get<Map>(["participate.signup"]);
  }

  bool doesExpectParticipants() => method == "api";

  EventParticipateSignup(this._data);
}

class EventParticipate {
  final FragmentsBundle _data;

  EventParticipateMeetup get meetup => EventParticipateMeetup(
        location:
            _data.get<String>(["participate.meetup.location", "location"]),
        time: EventDate.parseDate(_data.get<String>(
          ["participate.meetup.time", "date.start"],
        )),
      );

  EventParticipateSignup get signup => EventParticipateSignup(_data);

  EventParticipate(this._data);
}

class Event implements CacheableResource {
  final FragmentsBundle _data;

  String? get location => _data.get<String>(["location"]);

  final EventBody? body;

  @override
  String get id => getEventIdFromData(_data);

  EventName get name => EventName(_data);
  EventParticipate get participate => EventParticipate(_data);
  final EventDate date;

  String? get wpPermalink => _data.get<String>(["wp-permalink"]);
  String? get controller => _data.get<String>(["\$.controller"]);

  // String get bodyId => "$id-body";
  static String getEventIdFromData(FragmentsBundle data) =>
      data.getDynamicOrNull("id");
  // static String getBodyIdForEventId(String eventId) => "$eventId-body";

  // ?? _data["name"];
  // String get eventSlug => _data["slug"];

  // String get signupType {
  //   var signupType = _data["signup"]?["type"];
  //   if (signupType == null && _data["signup"]?["url"] != null) {
  //     signupType = "url";
  //   }

  //   if (_data["event_rsvp"] == 0) {
  //     signupType = "none";
  //   }

  //   signupType = signupType ?? "api";

  //   return signupType;
  // }

  // bool get isActive => _data["tickets"]?.isNotEmpty ?? false;

  // String? get signupUrl => _data["signup"]?["url"];

  Event({required FragmentsBundle data, required this.body})
      : _data = data,
        date = EventDate(data);

  // start = DateTime.parse('${data["start"]}Z').toLocal(),
  // end = data["end"] != null
  //     ? DateTime.parse('${data["end"]}Z').toLocal()
  //     : null,
  // location = data["location"];

  Event.copy(Event other)
      :
        // _data = jsonDecode(jsonEncode(other._data)),
        _data = FragmentsBundle.copy(other._data),
        date = other.date,
        // start = other.start,
        // end = other.end,
        // location = other.location,
        body = other.body;

  Event withBody(EventBody body) {
    return Event(data: _data, body: body);
  }

  static Event fromJson(Map dataMap, AnchoredUnpacker unpacker) {
    // data["start"] ??= data["event_start"];
    // data["end"] ??= data["event_end"];
    // data["name"] ??= data["event_name"];
    // data["slug"] ??= data["event_slug"];
    // data["publish_date"] ??= data["post_date_gmt"];
    // data["modified"] ??= data["post_modified_gmt"];

    // data["description"] ??= data["post_content"];

    final data = FragmentsBundle.fromMap(dataMap);

    final id = getEventIdFromData(data);

    // if (data["details"] != null) {
    //   for (var entry in (data["details"] as Map).entries) {
    //     if ((data[entry.key] ?? entry.value) != entry.value) {
    //       throw Exception("Event details mismatch");
    //     }
    //   }

    //   data.addAll(data["details"] as Map);
    // }
    // data.remove("details");

    // var thumbnailVal = data["thumbnail"];

    // if (thumbnailVal != null) {
    //   data["body"] ??= {};
    //   data["body"]["thumbnail"] = thumbnailVal;
    // }

    EventBody? body;
    Map? bodyVal = data.get<Map>(["body"]);
    if (bodyVal != null) {
      // bodyVal["description"] ??= data["description"];
      bodyVal["id"] = id;

      body = unpacker.parse<EventBody>(bodyVal);
    }
    // data.remove("body");

    // if (data["start"] == null) {
    //   throw Exception("Event start is null for event ${data["event_id"]}");
    // }

    return Event(data: data, body: body);
  }

  @override
  Map toJson({bool includeBody = false}) {
    var res = _data.toPayload();
    if (includeBody && body != null) {
      res["body"] = body!.toJson();
    }
    return res;
  }

  FragmentsBundle toFragments() {
    return _data;
    // var res = _data.toPayload();
    // if (includeBody && body != null) {
    //   res["body"] = body!.toJson();
    // }

    // return FragmentsBundle.fromComplete(res);
  }
}
