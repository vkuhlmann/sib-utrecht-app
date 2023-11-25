import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';

import '../constants.dart';

class EventProvider with ChangeNotifier {
  final Future<CacherApiConnector>? apiConnector;

  final CachedProvider<Event> event;
  final CachedProvider<List<String>> participants;

  EventProvider({
    required this.apiConnector,
    Event? cachedEvent,
    required int eventId
  }) 
  : event = CachedProvider<Event>(
    cache: cachedEvent,
    obtain: (c) => Events(c).getEvent(eventId: eventId, includeImage: true),
  ),
    participants = CachedProvider<List<String>>(
    obtain: (c) => Events(c).listParticipants(eventId: eventId),
  )
  {
    event.addListener(_reprocessCached);
    participants.addListener(_reprocessCached);

    var conn = apiConnector;

    if (conn != null) {
      event.setConnector(conn);
      participants.setConnector(conn);
    }
  }

  @override
  void dispose() {
    event.removeListener(_reprocessCached);
    participants.removeListener(_reprocessCached);
    super.dispose();
  }

  void refresh() {
    event.invalidate();
    participants.invalidate();
  }

  void _reprocessCached() {
    notifyListeners();
  }


  bool doesExpectParticipants() {
    Event? eventCached = event.cached;

    if (eventCached != null) {
      var signupType = eventCached.signupType;

      if (signupType == "api") {
        return true;
      }
    }

    var cachedParticipants = participants.cached;

    if (cachedParticipants != null && cachedParticipants.isNotEmpty) {
      return true;
    }

    return false;
  }

  static (String?, Map?) extractDescriptionAndThumbnail(Event event) {
    String description = ((event.data["post_content"] ??
            event.data["description"] ??
            "") as String)
        .replaceAll("\r\n\r\n", "<br/><br/>");
    Map? thumbnail = event.data["thumbnail"];

    if (thumbnail != null &&
        thumbnail["url"] != null &&
        !(thumbnail["url"] as String).startsWith("http")) {
      thumbnail["url"] = "$wordpressUrl/${thumbnail["url"]}";
    }

    if (thumbnail == null && description.contains("<img")) {
      final img = RegExp("<img[^>]+src=\"(?<url>[^\"]+)\"[^>]*>")
          .firstMatch(description);

      if (img != null) {
        thumbnail = {"url": img.namedGroup("url")};
        // description = description.replaceAll(img.group(0)!, "");
        description = description.replaceFirst(img.group(0)!, "");
      }
    }

    if (thumbnail != null &&
        thumbnail["url"] != null &&
        (thumbnail["url"] as String).startsWith("http://sib-utrecht.nl/")) {
      thumbnail["url"] = (thumbnail["url"] as String)
          .replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
    }

    description = description.replaceAll(
        RegExp("^(\r|\n|<br */>|<br *>)*", multiLine: false), "");

    return (description.isEmpty ? null : description, thumbnail);
  }
}