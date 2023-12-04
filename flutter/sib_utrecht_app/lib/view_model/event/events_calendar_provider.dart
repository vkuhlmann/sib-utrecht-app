import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/feedback.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/view_model/event/events_calendar_list.dart';

class EventsCalendarProvider extends StatefulWidget {
  final Widget Function(BuildContext context, EventsCalendarList data) builder;

  const EventsCalendarProvider({Key? key, required this.builder})
      : super(key: key);

  @override
  State<EventsCalendarProvider> createState() => _EventsCalendarProviderState();
}

class _EventsCalendarProviderState extends State<EventsCalendarProvider> {
  late EventsCalendarList calendar;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    setState(() {
      calendar = EventsCalendarList(
          eventsProvider: ResourcePoolAccess.of(context).pool.eventsProvider,
          feedback: ActionFeedback(
            sendConfirm: (m) => ActionFeedback.sendConfirmToast(context, m),
            sendError: (m) => ActionFeedback.showErrorDialog(context, m),
          ));
    });
  }

  @override
  void dispose() {
    calendar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: calendar,
      builder: (context, _) => ActionEmitter(
          refreshFuture: calendar.loading?.then((_) => DateTime.now()),
          triggerRefresh: calendar.refresh,
          child: widget.builder(context, calendar)));
}
