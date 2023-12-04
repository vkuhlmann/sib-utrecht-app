import 'dart:ui';
import 'dart:core';

import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/log.dart';

class Event {
  final Map<String, dynamic> data;
  final DateTime start;
  final DateTime? end;
  final String? location;

  int get eventId => data["event_id"];
  String get eventName => data["name"];
  String get eventNameNL => data["nameNL"] ?? data["name"];
  String get eventSlug => data["slug"];

  String get signupType {
    var signupType = data["signup"]?["type"];
    if (signupType == null && data["signup"]?["url"] != null) {
      signupType = "url";
    }

    if (data["event_rsvp"] == 0) {
      signupType = "none";
    }

    signupType = signupType ?? "api";

    return signupType;
  }
  
  Event({required this.data})
  : start = DateTime.parse('${data["start"]}Z').toLocal(),
    end = data["end"] != null ? DateTime.parse('${data["end"]}Z').toLocal() : null,
    location = data["location"];

  String getLocalEventName(Locale loc) {
    if (loc.languageCode == "nl") {
      return eventNameNL;
    }

    return eventName;
  }

  static Event fromJson(Map<String, dynamic> json) {
    var vals = json;
    vals["start"] = vals["start"] ?? vals["event_start"];
    vals["end"] = vals["end"] ?? vals["event_end"];
    vals["name"] = vals["name"] ?? vals["event_name"];
    vals["slug"] = vals["slug"] ?? vals["event_slug"];
    vals["publish_date"] = vals["publish_date"] ?? vals["post_date_gmt"];
    vals["modified"] = vals["modified"] ?? vals["post_modified_gmt"];

    if (vals["details"] != null) {
      for (var entry in (vals["details"] as Map).entries) {
        if ((vals[entry.key] ?? entry.value) != entry.value) {
          throw Exception("Event details mismatch");
        }
      }

      vals.addAll(
        (vals["details"] as Map).map((key, value)
        => MapEntry(key as String, value))
      );
    }
    if (vals["start"] == null) {
      throw Exception("Event start is null for event ${vals["event_id"]}");
    }

    return Event(data: json);
  }

  String? processThumbnailUrl(String? url) {
    if (url == null) {
      return null;
    }

    if (!url.startsWith("http")) {
      url = "$wordpressUrl/$url";
    }

    if (url.startsWith("http://sib-utrecht.nl/")) {
      url = url.replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
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
    String description = ((data["post_content"] ??
            data["description"] ??
            "") as String)
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
        RegExp("^(<strong></strong>)?(\r|\n|<br */>|<br *>)*", multiLine: false), "");

    return (description.isEmpty ? null : description, thumbnail);
  }
}
