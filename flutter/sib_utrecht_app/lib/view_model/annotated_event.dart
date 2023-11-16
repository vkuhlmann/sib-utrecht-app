import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../model/event.dart';
import 'event_participation.dart';
import 'event_placement.dart';

@immutable
class AnnotatedEvent extends Event {
  final EventParticipation? participation;
  final List<String>? participants;
  final EventPlacement? placement;
  
  AnnotatedEvent({
    required Event event,
    this.participation,
    this.placement,
    this.participants,
  }) : super(data: event.data);
}
