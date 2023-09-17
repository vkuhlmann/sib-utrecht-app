part of '../../main.dart';

abstract interface class AnnotatedEvent extends Widget {
  final Event event;
  final bool isParticipating;
  final ValueSetter<bool> setParticipating;
  final bool isDirty;

  DateTime? get date;

  const AnnotatedEvent(
      {required this.event,
      required this.isParticipating,
      required this.setParticipating,
      required this.isDirty,
      super.key});
}
