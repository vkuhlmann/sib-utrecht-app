import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:core';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/fragments_bundle.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';

final RegExp extractHeaderLine = RegExp(
    '^\\s*(<strong>)?(?<header>([^|<]+?\\s+\\|\\s+){2,10}[^|<]+?)\\s*(\\r?\\n?\\s*</strong>|(\\r?\\n){2,10}\\s*)');

class EventBody implements CacheableResource {
  @override
  final String id;

  final Map data;
  // final String? description;

  EventBody({required this.id, required this.data});

  factory EventBody.fromJson(Map data) {
    return EventBody(id: data["id"], data: data);
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

  (String?, Map?) extractDescriptionAndThumbnail() {
    String description =
        ((data["post_content"] ?? data["description"] ?? "") as String)
            .replaceAll("\r\n\r\n", "<br/><br/>");
    Map? thumbnail = data["thumbnail"] ?? data["image"];

    // if (thumbnail != null &&
    //     thumbnail["url"] != null &&
    //     !(thumbnail["url"] as String).startsWith("http")) {
    //   thumbnail["url"] = "$wordpressUrl/${thumbnail["url"]}";
    // }

    if (thumbnail == null && description.contains("<img")) {
      final img = RegExp("<img[^>]+src=\"(?<url>[^\"]+)\"[^>]*>")
          .firstMatch(description);

      if (img != null) {
        thumbnail = {"url": img.namedGroup("url")};
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

    if (thumbnail != null && thumbnail["url"] != null) {
      thumbnail["url"] = processThumbnailUrl(thumbnail["url"]);
    }

    description = description.replaceAll(
        RegExp("^(<strong></strong>)?(\r|\n|<br */>|<br *>)*",
            multiLine: false),
        "");

    return (description.isEmpty ? null : description, thumbnail);
  }

  Future<DateTime?> tryExtractStart(String dateComponent, String timeComponent) async {
    const List<String> locales = ["en_US", "en_GB", "nl_NL"];
    const List<String> dateFormats = ["MMMMEEEEd"];

    for (final loc in locales) {
      await initializeDateFormatting(loc, null);
    }
    RegExp exp = RegExp(r"^(?<main>.*?)(th|st|nd|rd)?\s*$");
    dateComponent = exp.firstMatch(dateComponent)!.namedGroup("main")!;

    for (final loc in locales) {
      for (final form in dateFormats) {
        try{
          DateTime dt = DateFormat(form, loc).parseLoose(dateComponent);
          return dt;

        } on FormatException catch (_) {
          continue;
        }
      }
    }

    return null;
  }

  // "<strong>Ice Skating | Vechtsebanen (Mississippidreef 151) | Tuesday January 9th | 20:00 | Max \u20ac5,50\r\n<\/strong>\r\n\r\nIt\u2019s
  // a new year and start the year we\u2019re
  Map extractFieldsFromDescription(String desc) {
    // RegExp('^\\s*(<strong>)?(?<title>[^|<]+?)\\s+\\|\\s+');

    final match = extractHeaderLine.firstMatch(desc);
    if (match == null) {
      return {};
    }

    final header = match.namedGroup("header")!;
    final fields = header.split("|").map((s) => s.trim()).toList();

    // final String? date = fields.elementAtOrNull(2);
    // final String? time = fields.elementAtOrNull(3);
    final date = fields[2];
    final time = fields[3];

    // final DateTime? start = DateTime.tryParse("$date $time");
    final startDateFormat = DateFormat("MMMMEEEEd");
    DateTime d = startDateFormat.parse(date);

    return {
      "event_name": fields[0],
      "location": fields[1],
      "date": fields[2],
    };
  }

  @override
  Map toJson() => data;
}

class Event implements CacheableResource {
  final Map _data;
  final DateTime start;
  final DateTime? end;
  final String? location;

  final EventBody? body;

  @override
  String get id => getEventIdFromData(_data);

  // String get bodyId => "$id-body";
  static String getEventIdFromData(Map data) => data["event_id"].toString();
  // static String getBodyIdForEventId(String eventId) => "$eventId-body";

  // int get eventId => data["event_id"];
  // String get eventId => data["event_id"];
  String get eventName => _data["name"];
  String? get eventNameNL => _data["nameNL"];

  String get eventLabel =>
      {
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
      }[eventName] ??
      eventName;

  // ?? _data["name"];
  String get eventSlug => _data["slug"];

  String get signupType {
    var signupType = _data["signup"]?["type"];
    if (signupType == null && _data["signup"]?["url"] != null) {
      signupType = "url";
    }

    if (_data["event_rsvp"] == 0) {
      signupType = "none";
    }

    signupType = signupType ?? "api";

    return signupType;
  }

  bool get isActive => _data["tickets"]?.isNotEmpty ?? false;

  String? get signupUrl => _data["signup"]?["url"];

  Event({required Map data, required this.body})
      : _data = data,
        start = DateTime.parse('${data["start"]}Z').toLocal(),
        end = data["end"] != null
            ? DateTime.parse('${data["end"]}Z').toLocal()
            : null,
        location = data["location"];

  Event.copy(Event other)
      : _data = jsonDecode(jsonEncode(other._data)),
        start = other.start,
        end = other.end,
        location = other.location,
        body = other.body;

  String getLocalEventName(Locale loc) {
    if (loc.languageCode == "nl") {
      return eventNameNL ?? eventName;
    }

    return eventName;
  }

  Event withBody(EventBody body) {
    return Event(data: _data, body: body);
  }

  static Event fromJson(Map data, AnchoredUnpacker unpacker) {
    data["start"] ??= data["event_start"];
    data["end"] ??= data["event_end"];
    data["name"] ??= data["event_name"];
    data["slug"] ??= data["event_slug"];
    data["publish_date"] ??= data["post_date_gmt"];
    data["modified"] ??= data["post_modified_gmt"];

    data["description"] ??= data["post_content"];

    final id = getEventIdFromData(data);

    if (data["details"] != null) {
      for (var entry in (data["details"] as Map).entries) {
        if ((data[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Event details mismatch");
        }
      }

      data.addAll(data["details"] as Map);
    }
    data.remove("details");

    var thumbnailVal = data["thumbnail"];

    if (thumbnailVal != null) {
      data["body"] ??= {};
      data["body"]["thumbnail"] = thumbnailVal;
    }

    EventBody? body;
    Map? bodyVal = data["body"];
    if (bodyVal != null) {
      bodyVal["description"] ??= data["description"];
      bodyVal["id"] = id;

      body = unpacker.parse<EventBody>(bodyVal);
    }
    data.remove("body");

    if (data["start"] == null) {
      throw Exception("Event start is null for event ${data["event_id"]}");
    }

    return Event(data: data, body: body);
  }

  bool doesExpectParticipants() => signupType == "api";

  @override
  Map toJson({bool includeBody = false}) {
    var res = _data;
    if (includeBody && body != null) {
      res["body"] = body!.toJson();
    }
    return res;
  }

  FragmentsBundle toFragments({bool includeBody = false}) {
    var res = _data;
    if (includeBody && body != null) {
      res["body"] = body!.toJson();
    }

    return FragmentsBundle.fromComplete(res);
  }
}
