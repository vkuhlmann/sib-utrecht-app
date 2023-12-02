import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/event/event_participation.dart';
import 'package:sib_utrecht_app/view_model/event/event_placement.dart';

import '../../model/event.dart';

@immutable
class AnnotatedEvent extends Event {
  final EventParticipation? participation;
  final List<AnnotatedUser>? participants;
  final EventPlacement? placement;

  AnnotatedEvent({
    required Event event,
    this.participation,
    this.placement,
    this.participants,
  }) : super(data: event.data);
}
