import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../model/event.dart';
import 'event_participation.dart';
import 'event_placement.dart';

@immutable
class AnnotatedEvent extends Event {
  final EventParticipation? participation;
  final EventPlacement? placement;
  
  AnnotatedEvent({
    required Event event,
    this.participation,
    this.placement,
  }) : super(data: event.data);
}
