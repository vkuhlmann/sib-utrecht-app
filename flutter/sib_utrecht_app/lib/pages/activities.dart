part of '../main.dart';

// Dialog code based on https://api.flutter.dev/flutter/material/Dialog-class.html

class ActivityView extends StatefulWidget {
  final Map activity;
  final DateTime start;
  final DateTime end;

  final bool isParticipating;
  final ValueSetter<bool> setParticipating;

  ActivityView(
      {Key? key,
      required this.activity,
      required this.isParticipating,
      required this.setParticipating})
      : start = DateTime.parse('${activity["event_start"]}Z').toLocal(),
        end = DateTime.parse('${activity["event_end"]}Z').toLocal(),
        super(key: key);

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

    return Container(
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
            child: Text('${widget.start.day}'),
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(5),
              child:
                  // Text(DateFormat("MMM", "nl_NL").format(widget.start))
                  Text(DateFormat("MMM", Preferences.of(context).locale)
                      .format(widget.start))
              // Text('${widget.start.month}')
              ),
          // Text('${widget.start.day} ${widget.start.month}'),
          Expanded(
              child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(5),
                  child: Text(widget.activity["event_name"]))),
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
              child: Checkbox(
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
                    Text(_timeFormat.format(widget.start)),
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
        ]));
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
  late Future<APIConnector>? apiConnector = null;

  late Future<Map>? _apiResult;
  late Future<Set<int>>? _bookedEvents;
  // late Future<String>? _debugOutput;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      this.apiConnector = apiConnector;
     
      loadEvents();
      loadBookings();
    }
  }

  void loadEvents() {
    setState(() {
      _apiResult = apiConnector?.then((value) => value.get("events"));
    });
    // _debugOutput = _apiResult.then((value) {
    //   const encoder = JsonEncoder.withIndent("    ");
    //   return encoder.convert(value);
    // });
  }

  void loadBookings() {
    setState(() {
      _bookedEvents = apiConnector?.then((api) => api.get("my-bookings")).then((value) {
        Set<int> events = (value["data"]["bookings"] as List<dynamic>)
            .where((v) => v["booking"]["status"] == "approved")
            .map<int>((e) => e["event"]["event_id"])
            .toSet();
        return events;
      });
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

    // return Dialog(
    //     child: Padding(
    //   padding: const EdgeInsets.all(20),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: <Widget>[
    //       Text(text),
    //       // const SizedBox(height: 15),
    //       Container(
    //         margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
    //         child: TextButton(
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //           child: const Text('Close'),
    //         ),
    //       )
    //     ],
    //   ),
    // ));
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

  void setEventRegistration(int eventId, bool value) async {
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
        loadBookings();
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
        loadBookings();
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
    if (_apiResult == null || _bookedEvents == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(children: [
      FutureBuilder<(Map, Set<int>)>(
          future: Future.wait([_apiResult!, _bookedEvents!])
              .then((value) => (value[0] as Map, value[1] as Set<int>)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // return Text(jsonEncode(snapshot.data!["data"]["events"]));
              var (events_response, booked_events) = snapshot.data!;

              return Column(
                  children: events_response["data"]["events"]
                      // .map<Widget>((e) => Text(jsonEncode(e)))
                      // .map<Widget>((e) => Text("Test"))
                      .map<Widget>((e) => ActivityView(
                          activity: e,
                          isParticipating:
                              booked_events.contains(e["event_id"]),
                          setParticipating: (value) =>
                              setEventRegistration(e["event_id"], value)))
                      .toList());

              // return _buildActivities(snapshot.data!);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          }),
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
    ]);
  }
}
