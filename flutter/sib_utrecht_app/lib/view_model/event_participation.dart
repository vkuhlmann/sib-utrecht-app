
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../model/event.dart';

class EventParticipation {
  // final Event event;
  final bool? isParticipating;
  final ValueSetter<bool>? setParticipating;
  final bool isDirty;
  final bool isActive;

  // DateTime? get date;

  // bool get isActive => data["tickets"] != null &&
  //       data["tickets"].length > 0;

  EventParticipation({
    required this.isParticipating,
    required this.setParticipating,
    required this.isDirty,
    required this.isActive,
  });

  static EventParticipation fromEvent(Event e,
      {ValueSetter<bool>? setParticipating,
      bool? isParticipating,
      bool isDirty = false}) {
    return EventParticipation(
      isParticipating: isParticipating,
      setParticipating: setParticipating,
      isDirty: isDirty,
      isActive: e.data["tickets"] != null && e.data["tickets"].length > 0,
    );
  }
}
