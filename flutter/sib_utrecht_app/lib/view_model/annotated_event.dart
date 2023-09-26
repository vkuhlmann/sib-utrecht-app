part of '../../main.dart';

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
