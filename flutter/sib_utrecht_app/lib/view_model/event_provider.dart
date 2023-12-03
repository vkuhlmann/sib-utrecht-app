import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';

class EventProvider {
  static Widget Multiplexed({query, builder}) => MultiplexedProvider(
      query: query,
      builder: builder,
      obtainProvider: (int id) => CachedProvider(
            obtain: (c) => Events(c).getEvent(eventId: id, includeImage: true),
          ));

  static Widget Single(
          {required int query,
          required Widget Function(BuildContext, Event) builder}) =>
      SingleProvider(
          query: query,
          builder: builder,
          obtainProvider: (int id) => CachedProvider(
                obtain: (c) => Events(c).getEvent(eventId: id, includeImage: true),
              ));
}
