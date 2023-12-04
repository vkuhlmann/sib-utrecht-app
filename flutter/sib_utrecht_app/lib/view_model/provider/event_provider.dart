import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/constants.dart';
import 'package:sib_utrecht_app/model/api/events.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';
import 'package:sib_utrecht_app/view_model/single_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventProvider {
  static Widget Multiplexed({query, builder}) => MultiplexedProvider(
      query: query,
      builder: builder,
      errorTitle: (loc) => loc.couldNotLoad(loc.dataEvents),
      obtainProvider: (int id) => CachedProvider(
            obtain: (c) => Events(c).getEvent(eventId: id, includeImage: true),
          ));

  static Widget Single(
          {required int query,
          required Widget Function(BuildContext, Event) builder}) =>
      SingleProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataEvent),
          obtainProvider: (int id) => CachedProvider(
                obtain: (c) =>
                    Events(c).getEvent(eventId: id, includeImage: true),
              ));



  static bool doesExpectParticipants(
    Event? event, List? participants) {

    if (event != null) {
      var signupType = event.signupType;

      if (signupType == "api") {
        return true;
      }
    }

    if (participants != null && participants.isNotEmpty) {
      return true;
    }

    return false;
  }

}
