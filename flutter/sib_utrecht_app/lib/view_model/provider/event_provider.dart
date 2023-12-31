import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventProvider {
  static Widget Multiplexed(
          {query,
          required bool requireBody,
          required Widget Function(BuildContext, List<FetchResult<Event>>)
              builder}) =>
      MultiplexedProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataEvents),
          // changeListener: (p) =>
          //     Listenable.merge([p._events, if (requireBody) p._eventBodies]),
          obtain: (String id, c) =>
              Events(c).getEvent(eventId: id, requireBody: requireBody));

  static Widget Single({
    required String query,
    required bool requireBody,
    required Widget Function(BuildContext, Event, FetchResult<void>) builder,
  }) =>
      SingleProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataEvent),
          // changeListener: (p) =>
          //     Listenable.merge([p._events, if (requireBody) p._eventBodies]),
          obtain: (String id, c) =>
              Events(c).getEvent(eventId: id, requireBody: requireBody));
}
