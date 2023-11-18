import 'package:flutter/material.dart';
import 'package:dual_screen/dual_screen.dart';
import 'package:sib_utrecht_app/pages/event.dart';
import 'package:sib_utrecht_app/pages/events.dart';

class EventsDoublePage extends StatelessWidget {
  final int? eventId;
  final bool isDetailsPriority;

  const EventsDoublePage(
      {super.key,
      required this.eventId,
      required this.isDetailsPriority});

  @override
  Widget build(BuildContext context) {
    Widget secondPane = const Center(child: Text("Select an event"));

    var evId = eventId;
    if (evId != null) {
      secondPane = EventPage(eventId: evId);
    }

    return TwoPane(
      startPane: const EventsPage(key: ValueKey("eventsPage")),
      endPane: secondPane,
      paneProportion: 0.5,
      panePriority: MediaQuery.of(context).size.width > 1000
          ? TwoPanePriority.both
          : (isDetailsPriority
          ? TwoPanePriority.end : TwoPanePriority.start),
    );
  }
}
