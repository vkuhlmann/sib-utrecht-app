part of '../main.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();


  static Widget buildItem(AnnotatedEvent event) {
    // if (event.placement == null) {
    //   return EventOngoing(
    //       key: ValueKey(("eventsItem", event.eventId)), event: event);
    // }

    return EventTile(
        key: ValueKey(("eventsItem", event.eventId, event.placement?.date)),
        event: event);
  }
}

class _EventsPageState extends State<EventsPage> {
  late Future<APIConnector>? apiConnector;

  final CachedProvider<List<Event>, Map> eventsProvider = CachedProvider<
          List<Event>, Map>(
      getCached: (c) => c.then((conn) => conn?.getCached("/events")),
      // getCached: (c) {
      //   throw Exception("This is a test");
      //   return c.then((conn) => conn?.getCached("/events"));
      // },
      getFresh: (c) => c.get("/events"),
      // getFresh: (c) {
      //   throw Exception("This is a test2");
      //   return c.get("/events");
      // },
      // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("events")),
      postProcess: (eventsRes) =>
          (eventsRes["data"]["events"] as Iterable<dynamic>)
              .map((e) => (e as Map<dynamic, dynamic>)
                  .map((key, value) => MapEntry(key as String, value)))
              .map((e) => Event.fromJson(e))
              .toList());

  final CachedProvider<Set<int>, Map> bookingsProvider = CachedProvider<
          Set<int>, Map>(
      getCached: (c) => c.then((conn) => conn?.getCached("/users/me/bookings")),
      getFresh: (c) => c.get("/users/me/bookings"),
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

  bool forceShowEventsStatus = true;
  bool forceShowBookingsStatus = true;

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
      eventsProvider.setConnector(apiConnector).then(
        (value) {
          eventsProvider.loading
              .then((_) => Future.delayed(const Duration(seconds: 3)))
              .then((_) {
            setState(() {
              forceShowEventsStatus = false;
            });
          });
        },
      );
      bookingsProvider.setConnector(apiConnector).then((value) {
        bookingsProvider.loading
            .then((_) => Future.delayed(const Duration(seconds: 3)))
            .then((_) {
          setState(() {
            forceShowBookingsStatus = false;
          });
        });
      });
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

  void scheduleEventRegistration(int eventId, bool value,
      {bool initiateRefresh = true}) {
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
            .post("/users/me/bookings/?event_id=$eventId&consent=true");

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
        res = await api!.delete("/users/me/bookings/by-event-id/$eventId");

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


  // Iterable<Widget> buildEventsItem(Event basicEvent) {
  //   return getPlacedEvents(basicEvent).map((event) {
  //     if (event.placement == null) {
  //       return EventOngoing(
  //           key: ValueKey(("eventsItem", basicEvent.eventId)),
  //           event: event);
  //     }

  //     return EventTile(
  //         key: ValueKey(("eventsItem", event.eventId, event.placement?.date)),
  //         event: event);
  //   });
  // }

  Iterable<AnnotatedEvent> placeEvent(Event event) sync* {
    var participation = EventParticipation.fromEvent(event,
        isParticipating:
            bookingsProvider.cached?.contains(event.eventId) == true,
        setParticipating: (value) =>
            scheduleEventRegistration(event.eventId, value),
        isDirty: bookingsProvider.cached == null ||
            _dirtyBookState.contains(event.eventId));

    if (event.end != null && event.end!.difference(event.start).inDays > 10) {
      yield AnnotatedEvent(
          event: event, participation: participation, placement: null);

      // yield EventOngoing(
      //     key: ValueKey(("eventsItem", event.eventId)),
      //     event: event,
      //     isParticipating: ,
      //     isDirty: ,
      //     setParticipating: );
      return;
    }

    // var startDay = e.start.subtract(const Duration(hours: 3));
    // startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);

    var startDay = event.start;
    startDay = DateTime(startDay.year, startDay.month, startDay.day, 3, 0, 0);
    var endDay = event.end ?? event.start;
    if (!startDay.isBefore(endDay)) {
      endDay = startDay.add(const Duration(hours: 1));
    }

    for (var i = startDay;
        i.isBefore(endDay);
        i = i.add(const Duration(days: 1))) {
      var placement = EventPlacement(
          date: i == startDay ? event.start : i, isContinuation: i != startDay);
      yield AnnotatedEvent(
          event: event, participation: participation, placement: placement
          // ValueKey(("eventsItem", event.eventId, i)),
          );
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

    events = [
      ...events,
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

    var eventsItems = events
        .map(placeEvent)
        .flattened
        .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
        // .map(buildItem)
        .toList();

    if (!group) {
      return eventsItems.map(EventsPage.buildItem).toList();
    }

    return groupBy(
            eventsItems,
            // (Event e) => formatWeekNumber(e.start).substring(0, 7)
            (AnnotatedEvent e) =>
                // formatWeekNumber(e.date ?? DateTime.now().add(const Duration(days: 7)))
                (e.placement?.date ?? DateTime.now().add(const Duration(days: 30)))
                    .toIso8601String()
                    .substring(0, 7))
        .entries
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
            children: e.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // if (eventsProvider.cached == null && apiConnector == null) {
    //   return const SizedBox();
    // }

    // if (eventsProvider.cached == null && apiConnector) {
    //   return const SizedBox();
    // }

    log.fine("Doing events page build");
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          //   if (eventsProvider.cached != null || eventsSnapshot.connectionState == ConnectionState.waiting)
          // Expanded(
          //     child: ListView(reverse: true, children: [
          FutureBuilderPatched(
            future: eventsProvider.loading,
            builder: (eventsContext, eventsSnapshot) {
              // if (eventsSnapshot.hasError) {
              //   return const SizedBox();
              // }

              if (eventsProvider.cached == null) {
                return FutureBuilderPatched(
                    future: eventsProvider.connector,
                    builder: (context, snapshot) {
                      var data = snapshot.data;

                      if (data != null && data.user == null) {
                        return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(children: [
                              // IconButton(
                              //   onPressed: () {
                              //   router.go("/login?immediate=true");
                              // }, icon: Icon(Icons.login, size: 64,
                              // color: Theme.of(context).colorScheme.primary,),
                              // // color: Theme.of(context).colorScheme.primaryContainer
                              // ),
                              FilledButton(
                                  onPressed: () {
                                    router.go("/login?immediate=true");
                                  },
                                  child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text("Log in",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ))))
                            ]));
                      }

                      if (eventsSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          eventsProvider.cached == null) {
                        return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()));
                      }

                      return const SizedBox();
                    });
                // if (eventsProvider.connector != null)

                // return const SizedBox();
              }

              return Expanded(
                child: 
                // RefreshIndicator(
                //   onRefresh: () async {
                //     eventsProvider.invalidate();
                //     bookingsProvider.invalidate();
                //     await Future.wait([eventsProvider.loading, bookingsProvider.loading]);
                //   },
                //   child:
                ListView(
                    reverse: true, children: buildEvents().reversed.toList()),
              );
            },
          ),
          AlertsPanel(loadingFutures: [
            ("events", eventsProvider.loading, eventsProvider.cached != null),
            (
              "bookings",
              bookingsProvider.loading,
              bookingsProvider.cached != null
            ),
          ])
        ]));
  }
}
