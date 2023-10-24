import 'dart:async';
import 'dart:convert';
// import 'dart:math';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/sib_appbar.dart';
import 'package:sib_utrecht_app/view_model/events_calendar_list.dart';

import '../globals.dart';
import '../model/api_connector.dart';
import '../components/api_access.dart';
import '../model/event.dart';
import '../view_model/annotated_event.dart';
import '../view_model/cached_provider.dart';
import '../view_model/event_participation.dart';
import '../view_model/async_patch.dart';
import '../view_model/event_placement.dart';
import '../components/event_group.dart';
import '../components/alerts_panel.dart';
import '../components/event_tile.dart';
import '../components/action_refresh.dart';

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
  Future<APIConnector>? apiConnector;
  final AlertsPanelController alertsPanelController = AlertsPanelController();

  // final CachedProvider<List<Event>, Map> eventsProvider = CachedProvider<
  //         List<Event>, Map>(
  //     getCached: (c) => c.then((conn) => conn?.getCached("/events")),
  //     // getCached: (c) {
  //     //   throw Exception("This is a test");
  //     //   return c.then((conn) => conn?.getCached("/events"));
  //     // },
  //     getFresh: (c) => c.get("/events"),
  //     // getFresh: (c) {
  //     //   throw Exception("This is a test2");
  //     //   return c.get("/events");
  //     // },
  //     // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("events")),
  //     postProcess: (eventsRes) =>
  //         (eventsRes["data"]["events"] as Iterable<dynamic>)
  //             .map((e) => (e as Map<dynamic, dynamic>)
  //                 .map((key, value) => MapEntry(key as String, value)))
  //             .map((e) => Event.fromJson(e))
  //             .toList());

  // final CachedProvider<Set<int>, Map> bookingsProvider = CachedProvider<
  //         Set<int>, Map>(
  //     getCached: (c) => c.then((conn) => conn?.getCached("/users/me/bookings")),
  //     getFresh: (c) => c.get("/users/me/bookings"),
  //     // getFresh: (c) => Future.delayed(const Duration(seconds: 20)).then((value) => c.get("users/me/bookings")),
  //     postProcess: (bookingsRes) =>
  //         (bookingsRes["data"]["bookings"] as Iterable<dynamic>)
  //             .where((v) => v["booking"]["status"] == "approved")
  //             .map<int>((e) => int.parse(e["event"]["event_id"].toString()))
  //             .toSet());

  // late void Function() listener;

  bool forceShowEventsStatus = true;
  bool forceShowBookingsStatus = true;

  late EventsCalendarList calendar;


  @override
  void initState() {
    super.initState();

    alertsPanelController.dismissedMessages.add(
      const AlertsPanelStatusMessage(component: "calendar", status: "loading", data: {})
    );
    alertsPanelController.dismissedMessages.add(
      const AlertsPanelStatusMessage(component: "calendar", status: "done", data: {})
    );

    apiConnector = null;
    calendar = EventsCalendarList(setEventReg: _setEventRegistration);
    // calendar.addListener(() {
    //   setState(() {});
    // });

    // listener = () {
    //   if (bookingsProvider.cachedId > _dirtyStateSequence) {
    //     _dirtyStateSequence = bookingsProvider.cachedId;
    //     _dirtyBookState = {};
    //   }

    //   log.fine("Doing setState from listener");
    //   setState(() {});
    // };

    // eventsProvider.addListener(listener);
    // bookingsProvider.addListener(listener);
  }

  @override
  void dispose() {
    // eventsProvider.removeListener(listener);
    // bookingsProvider.removeListener(listener);

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

      calendar.setApiConnector(apiConnector);

      // eventsProvider.setConnector(apiConnector).then(
      //   (value) {
      //     eventsProvider.loading
      //         .then((_) => Future.delayed(const Duration(seconds: 3)))
      //         .then((_) {
      //       setState(() {
      //         forceShowEventsStatus = false;
      //       });
      //     });
      //   },
      // );
      // bookingsProvider.setConnector(apiConnector).then((value) {
      //   bookingsProvider.loading
      //       .then((_) => Future.delayed(const Duration(seconds: 3)))
      //       .then((_) {
      //     setState(() {
      //       forceShowBookingsStatus = false;
      //     });
      //   });
      // });
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

  // void scheduleEventRegistration(int eventId, bool value,
  //     {bool initiateRefresh = true}) {
  //   setState(() {
  //     _dirtyStateSequence = bookingsProvider.firstValidId;
  //     _dirtyBookState.add(eventId);
  //   });

  //   var fut = _setEventRegistration(eventId, value);
  //   _pendingMutations.add(fut);

  //   if (!initiateRefresh) {
  //     fut.then((value) {
  //       setState(() {
  //         _pendingMutations.remove(fut);
  //         _dirtyBookState.remove(eventId);
  //       });
  //     });
  //     return;
  //   }

  //   fut.whenComplete(() {
  //     setState(() {
  //       _pendingMutations.remove(fut);
  //       _dirtyStateSequence = bookingsProvider.firstValidId;

  //       bookingsProvider.invalidate(doRefresh: true);
  //     });
  //   });
  // }

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

  List<Widget> buildEvents(EventsCalendarList list, {group = true}) {
    // var events = eventsProvider.cached;
    // if (events == null) {
    //   return [];
    // }

    // events = [
    //   ...events,
    //   /*Event(data: {
    //   "name": "Septemberkamp",
    //   "start": "2023-09-21 22:00:00",
    //   "end": "2023-09-24 21:59:59",
    //   "event_all_day": "1",
    //   "event_id": 5001,
    //   "signup": {
    //     "url": "https://forms.gle/bnzubocmcC91yY4R6"
    //   }
    // }),
    // Event(data: {
    //   "name": "Meet the Sibbers drink",
    //   "start": "2023-09-12 18:00:00",
    //   "end": "2023-09-12 21:59:59",
    //   "event_id": 5002,
    //   "signup": {
    //     "type": "none"
    //   }
    // }),
    // Event(data: {
    //   "name": "Talk on Cold War Espionage",
    //   "start": "2023-09-19 18:00:00",
    //   "end": "2023-09-19 21:59:59",
    //   "event_id": 5003,
    //   "signup": {
    //     "type": "none"
    //   }
    // }),   */
    // ];

    // var eventsItems = events
    //     .map(placeEvent)
    //     .flattened
    //     .sortedBy((AnnotatedEvent e) => e.placement?.date ?? e.end ?? e.start)
    //     // .map(buildItem)
    //     .toList();

    var eventsItems = list.events;

    if (!group) {
      return eventsItems.map(EventsPage.buildItem).toList();
    }

    String keyToTitle(String key) {
      if (key == "ongoing") {
        return AppLocalizations.of(context)!.eventCategoryOngoing;
      }

      DateTime d;
      try {
        d = DateFormat("y-M").parse(key);
      } on FormatException catch (_) {
        return key;
      }

      return DateFormat("yMMMM", Localizations.localeOf(context).toString())
          .format(d);

      // if (key == AppLocalizations.of(context)!.eventCategoryOngoing) {
      //   return AppLocalizations.of(context)!.eventCategoryOngoing;
      // }
      // return formatWeekNumber(DateTime.parse(key));
    }

    return groupBy(eventsItems,
            // (Event e) => formatWeekNumber(e.start).substring(0, 7)
            (AnnotatedEvent e) {
      // formatWeekNumber(e.date ?? DateTime.now().add(const Duration(days: 7)))
      var date = e.placement?.date;
      if (date == null) {
        // return "${DateTime.now().add(const Duration(days: 30)).toIso8601String()
        //     .substring(0, 7)}+";
        // return AppLocalizations.of(context)!.eventCategoryOngoing;
        return "ongoing";
      }
      return date.toIso8601String().substring(0, 7);
      // (e.placement?.date ?? DateTime.now().add(const Duration(days: 30)))
      //     .toIso8601String()
      //     .substring(0, 7)
    })
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
            // title: e.key,
            title: keyToTitle(e.key),
            initiallyExpanded: e.key != "ongoing",
            // children: e.value.map<EventsItem>(buildEventsItem).toList(),
            children: e.value))
        .toList();
  }

  Widget buildInProgress(
          BuildContext context, AsyncSnapshot<void> calendarLoadSnapshot) =>
      FutureBuilderPatched(
          future: apiConnector,
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
                        style: (Theme.of(context).filledButtonTheme.style ??
                                FilledButton.styleFrom())
                            .copyWith(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)))),
                        //  FilledButton.styleFrom(
                        //     primary: Theme.of(context)
                        //         .colorScheme
                        //         .primaryContainer),
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

            if (calendarLoadSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()));
            }

            return const SizedBox();
            // return const Center(child: Text("No events"));
          });

  @override
  Widget build(BuildContext context) {
    // if (eventsProvider.cached == null && apiConnector == null) {
    //   return const SizedBox();
    // }

    // if (eventsProvider.cached == null && apiConnector) {
    //   return const SizedBox();
    // }

    log.fine("Doing events page build");

    return ListenableBuilder(
        listenable: calendar,
        builder: (context, child) {
          var loading = calendar.loading;
          return WithSIBAppBar(
              showBackButton: false,
              actions: [
                ActionRefreshButton(
                  refreshFuture: loading?.then((_) => DateTime.now()),
                  triggerRefresh: () {
                    calendar.refresh();
                  },
                )
              ],
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //   if (eventsProvider.cached != null || eventsSnapshot.connectionState == ConnectionState.waiting)
                        // Expanded(
                        //     child: ListView(reverse: true, children: [
                        FutureBuilderPatched(
                          future: calendar.loading,
                          builder: (calendarLoadContext, calendarLoadSnapshot) {
                            if (calendar.events.isEmpty) {
                              return Center(child: buildInProgress(
                                  calendarLoadContext, calendarLoadSnapshot));
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
                                      reverse: true,
                                      children: buildEvents(calendar)
                                          .reversed
                                          .toList()),
                            );
                          },
                        ),
                        AlertsPanel(
                            controller: alertsPanelController,
                            loadingFutures: [
                              if (loading != null)
                                AlertsFutureStatus(
                                    component: "calendar",
                                    future: loading,
                                    data: {
                                      "isRefreshing": calendar.events.isNotEmpty
                                    })
                            ])
                      ])));
        });
  }
}
