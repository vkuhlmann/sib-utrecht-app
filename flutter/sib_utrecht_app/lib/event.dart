part of '../main.dart';

class Event {
  final Map<String, dynamic> data;
  final DateTime start;
  final DateTime end;

  int get eventId => data["event_id"];
  String get eventName => data["event_name"];

  Event({required this.data})
  : start = DateTime.parse('${data["event_start"]}Z').toLocal(),
    end = DateTime.parse('${data["event_end"]}Z').toLocal();

  static Event fromJson(Map<String, dynamic> json) {
    return Event(data: json);
  }
}
