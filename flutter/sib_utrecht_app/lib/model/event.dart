import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:core';

import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';

class EventBody implements CacheableResource {
  @override
  final String id;

  final Map data;
  // final String? description;

  EventBody({required this.id, required this.data});

  factory EventBody.fromJson(Map data) {
    return EventBody(
        id: data["id"],
        data: data);
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
    Map? thumbnail = data["thumbnail"];

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
  static String getBodyIdForEventId(String eventId) => "$eventId-body";

  // int get eventId => data["event_id"];
  // String get eventId => data["event_id"];
  String get eventName => _data["name"];
  String? get eventNameNL => _data["nameNL"];
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
      : 
      _data = data,
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
      bodyVal["id"] = getBodyIdForEventId(id);

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
}
