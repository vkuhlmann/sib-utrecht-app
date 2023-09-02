part of '../main.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

class ActivityView extends StatefulWidget {
  final Event event;

  // final Map activity;
  // final DateTime start;
  // final DateTime end;

  final bool isParticipating;
  final ValueSetter<bool> setParticipating;
  final bool isDirty;

  const ActivityView(
      {Key? key,
      required this.event,
      required this.isParticipating,
      required this.setParticipating,
      required this.isDirty})
      // : start = DateTime.parse('${activity["event_start"]}Z').toLocal(),
      //   end = DateTime.parse('${activity["event_end"]}Z').toLocal(),
      : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  // final TimeOfDayFormat _timeFormat = TimeOfDayFormat.HH_colon_mm;
  final _timeFormat = DateFormat("HH:mm");
  // late Future

  _ActivitiesPageState() {
    // initializeDateFormatting("nl_NL", null);
  }

  @override
  Widget build(BuildContext context) {
    // return Text(jsonEncode(widget.activity));
    // return Text(widget.activity["event_name"]);

    // final TimeOfDay start_time = TimeOfDay.fromDateTime(widget.start);
    // final TimeOfDay end_time = TimeOfDay.fromDateTime(widget.end);

    // InkWell (
    //     onTap: () {
    //       sendToast("Hoi!!!");
    //     },
    //     child:

    return InkWell(
        onTap: () {
          // Based on https://stackoverflow.com/questions/45948168/how-to-create-toast-in-flutter
          // answer by https://stackoverflow.com/users/8394265/r%c3%a9mi-rousselet
          // final scaffold = ScaffoldMessenger.of(context);
          // scaffold.showSnackBar(
          //   SnackBar(
          //     content: const Text("Hoiii!"),
          //     // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
          //     action: SnackBarAction(
          //         label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
          //   ),
          // );

          // context.push("/event/${widget.activity["event_id"]}");
          // context
          _sectionNavigatorKey.currentContext!
              // _sectionNavigatorKey.currentContext!
              .push("/event/${widget.event.eventId}");

          // _rootNavigatorKey
          // _sectionNavigatorKey.currentContext!
          // context.push("/event/:event_id",
          //     pathParameters: {"event_id": widget.activity["event_id"].toString()});
        },
        child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
            child: Row(children: [
              // Container(
              //     width: 100,
              //     height: 100,
              //     decoration: BoxDecoration(
              //         image: DecorationImage(
              //             image: NetworkImage(widget.activity["image_url"]),
              //             fit: BoxFit.cover))),
              // Row(children: <Widget>[
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                color: Colors.lightBlueAccent,
                child: Text('${widget.event.start.day}'),
              ),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  // child: Text(
                  //     DateFormat("MMM", "nl_NL").format(widget.event.start))
                  child: LocaleDateFormat(
                      format: "MMM", date: widget.event.start)
                  // Text(DateFormat("MMM", Preferences.of(context).locale)
                  //     .format(widget.event.start))
                  // Text('${widget.start.month}')
                  ),
              // Text('${widget.start.day} ${widget.start.month}'),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: Text(widget.event.eventName))),
              Container(
                  alignment: Alignment.center,
                  // child: IconButton(
                  //   icon: const Icon(Icons.add),
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   MaterialPageRoute(builder: (context) => ActivityView(activity: widget.activity)),
                  //     // );
                  //     // Navigator.pushNamed(context, '/activity', arguments: widget.activity);
                  //   },
                  // )
                  child: widget.isDirty
                      ? const CircularProgressIndicator()
                      : Checkbox(
                          value: widget.isParticipating,
                          onChanged: (value) {
                            print("Checkbox changed to $value");
                            widget.setParticipating(value!);
                          },
                        )),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_timeFormat.format(widget.event.start)),
                        // Text(_timeFormat.format(widget.end)),
                        // Text(start_time.format(context)),
                        // Text(end_time.format(context))
                        // Text('${widget.start.hour:2d}:${widget.start.minute}'),
                        // Text('${widget.end.hour}:${widget.end.minute}'),
                      ])),
              // Text(widget.activity["event_start"]),
              // Text(widget.activity["event_time"]),
              // Text(widget.activity["event_location"]),
              // Text(widget.activity["event_description"]),
              // ])
            ])));
  }
}

// class ActivityManager extends InheritedWidget {
//   late Future<Map> events;
//   late List<int> bookedEvents;

//   ActivityManager({super.key, required super.child});

//   @override
//   void initState() {

//   }

//   static ActivityManager? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<ActivityManager>();
//   }

//   @override
//   bool updateShouldNotify(ActivityManager oldWidget) {
//     return bookedEvents != oldWidget.bookedEvents;
//   }
// }

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<APIConnector>? apiConnector;

  // late Future<Map>? _apiResult;

  int sequenceId = 0;

  (int, List<Event>, Set<int>)? _cached;
  Future<(int, List<Event>, Set<int>)?> _staging = Future.value(null);
  int? _refreshingSequence = null;

  Set<int> _dirtyBookState = {};
  int _dirtyStateSequence = 0;

  List<Future> _pendingMutations = [];

  // late Future<Set<int>>? _bookedEvents;
  // late Future<String>? _debugOutput;

  // late List<Map> _cachedEvents;
  // late Set<int> _cachedBookedEvents;

  @override
  void initState() {
    super.initState();

    apiConnector = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      print(
          "API connector changed from ${this.apiConnector} to ${apiConnector}");
      this.apiConnector = apiConnector;
      scheduleRefresh();
    }
  }

  Future<(List<Event>, Set<int>)?> _loadData() async {
    // return null;
    print("Loading activity data");
    var conn = apiConnector;
    if (conn == null) {
      return null;
    }

    var [eventsRes, bookingsRes] = await Future.wait([
      conn.then((api) => api.get("events")),
      conn.then((api) => api.get("my-bookings"))
    ]);

    // var eventsRes = await conn.then((api) => api.get("events"));
    // var bookingsRes = await conn.then((api) => api.get("my-bookings"));

    var events = (eventsRes["data"]["events"] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .map((e) => Event.fromJson(e))
        .toList();
    var bookings = (bookingsRes["data"]["bookings"] as List<dynamic>)
        .where((v) => v["booking"]["status"] == "approved")
        .map<int>((e) => e["event"]["event_id"])
        .toSet();

    return (events, bookings);
  }

  void scheduleRefresh() {
    setState(() {
      print("Refreshing");
      int thisSequence = sequenceId++;
      _refreshingSequence = thisSequence;

      var fut = _loadData().then((value) {
        if (value == null) {
          return null;
        }

        var v = (thisSequence, value.$1, value.$2);
        setState(() {
          if (thisSequence != _refreshingSequence) {
            print(
                "Discarding activity data result: sequence id was $thisSequence, now $_refreshingSequence");
            return;
          }

          _cached = v;
        });

        return v;
      });
      // .onError((e) {
      //   print("Error while loading data: $e");
      //   // popupDialog("Error while loading data: $e");
      // });

      var fut2 = fut.whenComplete(() {
        setState(() {
          if (thisSequence != _refreshingSequence) {
            return;
          }

          _refreshingSequence = null;
          if (thisSequence > _dirtyStateSequence) {
            _dirtyBookState = {};
          }
        });
      });

      _staging = fut;
    });
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
          TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ]);
  }

  void sendToast(String text) {
    // Based on https://stackoverflow.com/questions/45948168/how-to-create-toast-in-flutter
    // answer by https://stackoverflow.com/users/8394265/r%c3%a9mi-rousselet
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        // action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  void scheduleEventRegistration(int eventId, bool value) {
    setState(() {
      _dirtyStateSequence = sequenceId++;
      _dirtyBookState.add(eventId);
    });

    var fut = _setEventRegistration(eventId, value).then((value) {
      setState(() {
        _dirtyBookState.remove(eventId);
      });
      return value;
    });

    _pendingMutations.add(fut);
    fut.whenComplete(() {
      setState(() {
        _pendingMutations.remove(fut);
        _dirtyStateSequence = sequenceId++;
        _dirtyBookState.add(eventId);

        scheduleRefresh();
      });
    });
  }

  Future<void> _setEventRegistration(int eventId, bool value) async {
    // showDialog<String>(
    //     context: context,
    //     builder: (BuildContext context) => Dialog(
    //             child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: <Widget>[
    //               const Text('This is a typical dialog.'),
    //               const SizedBox(height: 15),
    //               TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context);
    //                 },
    //                 child: const Text('Close'),
    //               ),
    //             ],
    //           ),
    //         )));

    var api = await apiConnector;

    if (value) {
      Map res;
      try {
        res = await api!.post("add-booking?event_id=$eventId");

        bool isSuccess = res["status"] == "success";
        assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

        if (isSuccess) {
          sendToast("Registered for event $eventId");
        }
      } catch (e) {
        popupDialog("Failed to register for event $eventId: \n$e");
      } finally {
        // scheduleRefresh();
      }
    }

    if (!value) {
      Map res;
      try {
        res = await api!.put("cancel-booking?event_id=$eventId");

        bool isSuccess = res["status"] == "success";
        assert(isSuccess, "No success status returned: ${jsonEncode(res)}");

        if (isSuccess) {
          sendToast("Cancelled registration for event $eventId");
        }
      } catch (e) {
        popupDialog("Failed to cancel registration for event $eventId: $e");
      } finally {
        // scheduleRefresh();
      }
    }

    // popupDialog("Setting registration for event $eventId to $value");

    // print("Setting registration for event $eventId to $value");
    // var apiConnector = APIConnector();
    // apiConnector.post("bookings", {"event_id": eventId}).then((value) {
    //   print("Registered for event $eventId");
    //   setState(() {
    //     _bookedEvents = apiConnector.get("my-bookings").then((value) {
    //       List<int> events =
    //         (value["data"]["bookings"] as List<dynamic>)
    //         .where((v) => v["booking"]["status"] == "approved")
    //         .map<int>((e) => e["event"]["event_id"])
    //         .toList();
    //         return events;
    //     });
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // if (_) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return FutureBuilder(
        future: _staging,
        builder: (contextStaging, snapshotStaging) {
          return Column(children: [
            // FutureBuilder<(List<Map>, Set<int>)?>(
            //     future: _cached,
            // builder: (contextCached, snapshotCached) {
            // if (snapshotCached.hasError) {
            //   return Text("${snapshotCached.error}");
            // }
            (contextCached) {
              var data = _cached;
              if (data == null) {
                return const SizedBox();
              }

              // return Text(jsonEncode(snapshot.data!["data"]["events"]));
              var (sequenceId, events, bookedEvents) = data;

              return Column(
                  children: events
                      .map<Widget>((e) => ActivityView(
                          key: ValueKey(e.eventId),
                          event: e,
                          isParticipating: bookedEvents.contains(e.eventId),
                          isDirty: _dirtyBookState.contains(e.eventId),
                          setParticipating: (value) =>
                              scheduleEventRegistration(e.eventId, value)))
                      .toList());

              // return _buildActivities(snapshot.data!);
              // if (snapshotStaging.hasError) {
              // return Text(jsonEncode(snapshotCached.data));
              // }

              // return const CircularProgressIndicator();
            }(contextStaging),

            // if (snapshot.hasData) {
            //   return Text(jsonEncode(snapshot.data));
            // } else
            (_refreshingSequence != null)
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()))
                : ((snapshotStaging.hasError)
                    ? Text("${snapshotStaging.error}")
                    : const SizedBox()),
            // ((snapshotStaging.hasError)
            //     ? Text("${snapshotStaging.error}")
            //     : (snapshotStaging.hasData
            //         ? SizedBox()
            //         : const Center(child: CircularProgressIndicator()))),
            // Text("snapshotStaging.hasData: ${snapshotStaging.hasData}"),
            // Text("snapshotStaging.hasError: ${snapshotStaging.hasError}"),
            Text("sequence id: $sequenceId"),
            Text("refreshing sequence: $_refreshingSequence"),
          ]);
        });
    // FutureBuilder<Set<int>>(
    //     future: _bookedEvents,
    //     builder: (context, snapshot) {
    //       if (snapshot.hasData) {
    //         return Text(jsonEncode(snapshot.data!.toList()));
    //       } else if (snapshot.hasError) {
    //         return Text("${snapshot.error}");
    //       }
    //       return const CircularProgressIndicator();
    //     }),
    // ]);
  }
}
