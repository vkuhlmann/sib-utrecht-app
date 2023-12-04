import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_T.dart';


class EventProviderNotifier with ChangeNotifier {
  final Future<CacherApiConnector>? apiConnector;

  final CachedProvider<Event> event;
  final CachedProvider<List<AnnotatedUser>> participants;

  EventProviderNotifier({
    required this.apiConnector,
    FetchResult<Event>? cachedEvent,
    required int eventId
  }) 
  : event = CachedProvider<Event>(
    cache: cachedEvent,
    obtain: (c) => Events(c).getEvent(eventId: eventId, includeImage: true),
  ),
    participants = CachedProvider<List<AnnotatedUser>>(
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


}