part of 'main.dart';

// class Activities {}

class ActivityView extends StatefulWidget {
  final Map activity;
  final DateTime start;
  final DateTime end;

  final bool isParticipating;
  final ValueSetter<bool> setParticipating;

  ActivityView(
    {
      Key? key, required this.activity,
      required this.isParticipating,
      required this.setParticipating
    }
  ) :
    start=DateTime.parse('${activity["event_start"]}Z').toLocal(),
    end=DateTime.parse('${activity["event_end"]}Z').toLocal(),
    super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  // final TimeOfDayFormat _timeFormat = TimeOfDayFormat.HH_colon_mm;
  final  _timeFormat = DateFormat("HH:mm");
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
              Text(DateFormat("MMM", Preferences.of(context).locale).format(widget.start))
              // Text('${widget.start.month}')
            ),
            // Text('${widget.start.day} ${widget.start.month}'),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(5),
                child: Text(widget.activity["event_name"])
              )
            ),
            Container(alignment: Alignment.center,
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
              )
            ),
            Container(alignment: Alignment.centerLeft,
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
              ])
            ),
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
  late Future<Map> _apiResult;
  late Future<Set<int>> _bookedEvents;
  late Future<String>? _debugOutput;

  @override
  void initState() {
    super.initState();
    
    var apiConnector = APIConnector();

    _apiResult = apiConnector.get("events");

    _debugOutput = _apiResult.then((value) {
      const encoder = JsonEncoder.withIndent("    ");
      return encoder.convert(value);
    });

    _bookedEvents = apiConnector.get("my-bookings").then((value) {
      Set<int> events =
        (value["data"]["bookings"] as List<dynamic>)
        .where((v) => v["booking"]["status"] == "approved")
        .map<int>((e) => e["event"]["event_id"])
        .toSet();
        return events;
    });
  }

  void setEventRegistration(int eventId, bool value) {
    print("Setting registration for event $eventId to $value");
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
    return Column(children: [
    FutureBuilder<(Map, Set<int>)>(
        future: Future.wait([_apiResult, _bookedEvents])
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
                      isParticipating: booked_events.contains(e["event_id"]),
                      setParticipating:
                        (value) => setEventRegistration(e["event_id"], value)
                    ))
                    .toList()
                // const <Widget>[
                //   Text("Activity 1"),
                //   Text("Activity 2"),
                // ]
                );

            // return _buildActivities(snapshot.data!);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        }),
        FutureBuilder<Set<int>>(
          future: _bookedEvents,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(jsonEncode(snapshot.data!.toList()));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          }
        ),
    ]);

    // return Column(children: const <Widget>[
    //   Text("Activity 1"),
    //   Text("Activity 2"),

    //   // Center(
    //   //     child: FutureBuilder<String>(
    //   //   future: _debugOutput,
    //   //   builder: (context, snapshot) {
    //   //     if (snapshot.hasData) {
    //   //       return Text(snapshot.data!);
    //   //     } else if (snapshot.hasError) {
    //   //       return Text("${snapshot.error}");
    //   //     }
    //   //     return const CircularProgressIndicator();
    //   //   },
    //   // )),
    // ]);
  }
}
