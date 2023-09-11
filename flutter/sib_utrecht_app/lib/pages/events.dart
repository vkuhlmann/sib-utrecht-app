part of '../main.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<APIConnector>? apiConnector;

  final CachedProvider<List<Event>, Map> eventsProvider =
      CachedProvider<List<Event>, Map>(
          getCached: (c) => c.then((conn) => conn?.getCached("events")),
          getFresh: (c) => c.get("events"),
          // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("events")),
          postProcess: (eventsRes) =>
              (eventsRes["data"]["events"] as Iterable<dynamic>)
                  .map((e) => (e as Map<dynamic, dynamic>)
                      .map((key, value) => MapEntry(key as String, value)))
                  .map((e) => Event.fromJson(e))
                  .toList());

  final CachedProvider<Set<int>, Map> bookingsProvider =
      CachedProvider<Set<int>, Map>(
          getCached: (c) =>
              c.then((conn) => conn?.getCached("users/me/bookings")),
          getFresh: (c) => c.get("users/me/bookings"),
          // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("users/me/bookings")),
          postProcess: (bookingsRes) =>
              (bookingsRes["data"]["bookings"] as Iterable<dynamic>)
                  .where((v) => v["booking"]["status"] == "approved")
                  .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
                  .toSet());

  late void Function() listener;

  Set<int> _dirtyBookState = {};
  int _dirtyStateSequence = 0;

  final List<Future> _pendingMutations = [];

  @override
  void initState() {
    super.initState();

    apiConnector = null;

    listener = () {
      if (bookingsProvider.cachedId > _dirtyStateSequence) {
        _dirtyStateSequence = bookingsProvider.cachedId;
        _dirtyBookState = {};
      }

      log.fine("Doing setState from listener");
      setState(() {});
    };

    eventsProvider.addListener(listener);
    bookingsProvider.addListener(listener);
  }

  @override
  void dispose() {
    eventsProvider.removeListener(listener);
    bookingsProvider.removeListener(listener);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      log.fine(
          "[EventsPage] API connector changed from ${this.apiConnector} to $apiConnector");
      this.apiConnector = apiConnector;
      eventsProvider.setConnector(apiConnector);
      bookingsProvider.setConnector(apiConnector);
    }
  }

  void popupDialog(String text) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => createDialog(text));
  }

  Widget createDialog(String text) {
    return AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          Builder(
              builder: (context) => TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })),
        ]);
  }

  void sendToast(String text) {
    // Based on https://stackoverflow.com/questions/45948168/how-to-create-toast-in-flutter
    // answer by https://stackoverflow.com/users/8394265/r%c3%a9mi-rousselet
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void scheduleEventRegistration(int eventId, bool value, {bool initiateRefresh = true}) {
    setState(() {
      _dirtyStateSequence = bookingsProvider.firstValidId;
      _dirtyBookState.add(eventId);
    });

    var fut = _setEventRegistration(eventId, value);
    _pendingMutations.add(fut);

    if (!initiateRefresh) {
      fut.then((value) {
        setState(() {
          _pendingMutations.remove(fut);
          _dirtyBookState.remove(eventId);
        });
      });
      return;
    }
    
    fut.whenComplete(() {
      setState(() {
        _pendingMutations.remove(fut);
        _dirtyStateSequence = bookingsProvider.firstValidId;

        bookingsProvider.invalidate(doRefresh: true);
      });
    });
  }

  Future<void> _setEventRegistration(int eventId, bool value) async {
    var api = await apiConnector;

    if (value) {
      Map res;
      try {
        res = await api!
            .post("users/me/bookings/?event_id=$eventId&consent=true");

        bool isSuccess = res["status"] == "success";
        assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

        if (isSuccess) {
          sendToast("Registered for event $eventId");
        }
      } catch (e) {
        popupDialog("Failed to register for event $eventId: \n$e");
      }
    }

    if (!value) {
      Map res;
      try {
        res = await api!.delete("users/me/bookings/by-event-id/$eventId");

        bool isSuccess = res["status"] == "success";
        assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

        if (isSuccess) {
          sendToast("Cancelled registration for event $eventId");
        }
      } catch (e) {
        popupDialog("Failed to cancel registration for event $eventId: $e");
      }
    }
  }

  Widget? buildError(Object? eventsError, Object? bookingsError) {
    String? errorMsg = eventsError?.toString() ?? bookingsError?.toString();

    if (errorMsg?.contains("Sorry, you are not allowed to do that") == true) {
      return FilledButton(
          onPressed: () {
            router.go("/login?immediate=true");
          },
          child: const Text("Please log in"));
    }

    if (eventsError != null) {
      return formatError(eventsError);
    }

    if (bookingsError != null) {
      return formatError(bookingsError);
    }

    return null;
  }

  Iterable<AnnotatedEvent> buildEventsItem(Event e) sync* {
    if (e.end != null && e.end!.difference(e.start).inDays > 10) {
      yield EventOngoing(
      key: ValueKey(("eventsItem", e.eventId)),
        event: e,
        isParticipating:
            bookingsProvider.cached?.contains(e.eventId) == true,
        isDirty: bookingsProvider.cached == null ||
            _dirtyBookState.contains(e.eventId),
        setParticipating: (value) =>
            scheduleEventRegistration(e.eventId, value));
      return;
    }

    // var startDay = e.start.subtract(const Duration(hours: 3));
    // startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);

    var startDay = e.start;
    startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);
    var endDay = e.end ?? e.start;
    if (!startDay.isBefore(endDay)) {
      endDay = startDay.add(const Duration(hours: 1));
    }

    for (
      var i = startDay;
      i.isBefore(endDay);
      i = i.add(const Duration(days: 1))
    ) {
      yield EventTile(date: i,
        key: ValueKey(("eventsItem", e.eventId, i)),
        event: e,
        isParticipating:
            bookingsProvider.cached?.contains(e.eventId) == true,
        isDirty: bookingsProvider.cached == null ||
            _dirtyBookState.contains(e.eventId),
        isConinuation: i != startDay,
        setParticipating: (value) =>
            scheduleEventRegistration(e.eventId, value));
    }

    // EventsItem(
    //   date: e.end,
    //   key: ValueKey(e.eventId),
    //   event: e,
    //   isParticipating:
    //       bookingsProvider.cached?.contains(e.eventId) == true,
    //   isDirty: bookingsProvider.cached == null ||
    //       _dirtyBookState.contains(e.eventId),
    //   setParticipating: (value) =>
    //       scheduleEventRegistration(e.eventId, value));
  }

  List<Widget> buildEvents({group = true}) {
    var events = eventsProvider.cached;
    if (events == null) {
      return [];
    }

    events = [...events, 
    /*Event(data: {
      "name": "Septemberkamp",
      "start": "2023-09-21 22:00:00",
      "end": "2023-09-24 21:59:59",
      "event_all_day": "1",
      "event_id": 5001,
      "signup": {
        "url": "https://forms.gle/bnzubocmcC91yY4R6"
      }
    }),
    Event(data: {
      "name": "Meet the Sibbers drink",
      "start": "2023-09-12 18:00:00",
      "end": "2023-09-12 21:59:59",
      "event_id": 5002,
      "signup": {
        "type": "none"
      }
    }),
    Event(data: {
      "name": "Talk on Cold War Espionage",
      "start": "2023-09-19 18:00:00",
      "end": "2023-09-19 21:59:59",
      "event_id": 5003,
      "signup": {
        "type": "none"
      }
    }),   */
    ];

    /*

    */

    var eventsItems = events.map(buildEventsItem).flattened.sortedBy(
        (AnnotatedEvent e) => e.date ?? e.event.end ?? e.event.start
      ).toList();

    if (!group) {
      return eventsItems;
    }


    return groupBy(eventsItems,
      // (Event e) => formatWeekNumber(e.start).substring(0, 7)
      (AnnotatedEvent e) => 
        // formatWeekNumber(e.date ?? DateTime.now().add(const Duration(days: 7)))
      (e.date ?? DateTime.now().add(const Duration(days: 30)))
      .toIso8601String().substring(0, 7)
    ).entries
    .sortedBy((element) => element.key)
        // .map((e) => Column(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        //           child: Text(
        //             e.key,
        //             style: const TextStyle(fontSize: 20),
        //           ),
        //         ),
        //         ...e.value.map(buildEventsItem).toList()
        //       ],
        //     ))
        .map((e) => EventsGroup(
              key: ValueKey(("EventsGroup", e.key)),
              title: e.key,
              // children: e.value.map<EventsItem>(buildEventsItem).toList(),
              children: e.value
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    log.fine("Doing events page build");
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
              child: ListView(reverse: true,
              shrinkWrap: true, children: [
                FutureBuilderPatched(
              future: eventsProvider.loading,
              builder: (eventsContext, eventsSnapshot) {
                if (eventsSnapshot.hasError) {
                  return const SizedBox();
                }
                if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: CircularProgressIndicator()));
                }

                return FutureBuilderPatched(
                  future: bookingsProvider.loading,
                  builder: (bookingsContext, bookingsSnapshot) {
                    if (bookingsSnapshot.hasError) {
                      return const SizedBox();
                    }
                    if (bookingsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.green)));
                    }

                    return const SizedBox();
                  },
                );
              },
            ),
            // ...(eventsProvider.cached ?? [])
            //     .map<Widget>(buildEventsItem)
            //     .toList().reversed,
            ...buildEvents().reversed,            
          ])),

          FutureBuilderPatched(
              future: eventsProvider.loading,
              builder: (eventsContext, eventsSnapshot) => FutureBuilderPatched(
                  future: bookingsProvider.loading,
                  builder: (bookingsContext, bookingsSnapshot) {
                    Widget? errorObj = buildError(
                        eventsSnapshot.error,
                        bookingsSnapshot.error
                      );
                    if (errorObj == null) {
                      return const SizedBox();
                    }

                    return Padding(
                        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                        child: Card(
                            child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Container(
                                          alignment:
                                              eventsProvider.cached == null
                                                  ? Alignment.center
                                                  : Alignment.topCenter,
                                          child:
                                              errorObj)
                                    ]))))
                        );
                  }))
        ]));
  }
}
