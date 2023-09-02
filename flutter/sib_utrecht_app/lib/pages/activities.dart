part of '../main.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

class ActivityView extends StatefulWidget {
  final Event event;

  final bool isParticipating;
  final ValueSetter<bool> setParticipating;
  final bool isDirty;

  const ActivityView(
      {Key? key,
      required this.event,
      required this.isParticipating,
      required this.setParticipating,
      required this.isDirty})
      : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final _timeFormat = DateFormat("HH:mm");

  @override
  Widget build(BuildContext context) {
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
                  child: LocaleDateFormat(
                      format: "MMM", date: widget.event.start)
                  ),
              Expanded(
                  child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      child: Text(widget.event.eventName))),
              Container(
                  alignment: Alignment.center,
                  child: widget.isDirty
                      ? const CircularProgressIndicator()
                      : Checkbox(
                          value: widget.isParticipating,
                          onChanged: (value) {
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
            ])));
  }
}

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<APIConnector>? apiConnector;

  int sequenceId = 0;

  (int, List<Event>, Set<int>)? _cached;
  Future<(int, List<Event>, Set<int>)?> _staging = Future.value(null);
  int? _refreshingSequence = null;

  Set<int> _dirtyBookState = {};
  int _dirtyStateSequence = 0;

  List<Future> _pendingMutations = [];

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
      log.fine(
          "API connector changed from ${this.apiConnector} to ${apiConnector}");
      this.apiConnector = apiConnector;
      scheduleRefresh();
    }
  }

  Future<(List<Event>, Set<int>)?> _loadData() async {
    log.fine("Loading activity data");
    var conn = apiConnector;
    if (conn == null) {
      return null;
    }

    var [eventsRes, bookingsRes] = await Future.wait([
      conn.then((api) => api.get("events")),
      conn.then((api) => api.get("users/me/bookings"))
    ]);

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
      log.fine("Refreshing");
      int thisSequence = sequenceId++;
      _refreshingSequence = thisSequence;

      var fut = _loadData().then((value) {
        if (value == null) {
          return null;
        }

        var v = (thisSequence, value.$1, value.$2);
        setState(() {
          if (thisSequence != _refreshingSequence) {
            log.fine(
                "Discarding activity data result: sequence id was $thisSequence, now $_refreshingSequence");
            return;
          }

          _cached = v;
        });

        return v;
      });

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
    var api = await apiConnector;

    if (value) {
      Map res;
      try {
        res = await api!.post("users/me/bookings/?event_id=$eventId");

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

  @override
  Widget build(BuildContext context) {
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

            (_refreshingSequence != null)
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()))
                : ((snapshotStaging.hasError)
                    ? Text("${snapshotStaging.error}")
                    : const SizedBox()),
            
            // Text("sequence id: $sequenceId"),
            // Text("refreshing sequence: $_refreshingSequence"),
          ]);
        });
  }
}
