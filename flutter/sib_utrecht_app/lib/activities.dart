part of 'main.dart';

// class Activities {}

class ActivityView extends StatefulWidget {
  final Map activity;
  final DateTime start;
  final DateTime end;

  ActivityView({Key? key, required this.activity}) :
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
              child: Text('${widget.start.day}'),
              color: Colors.lightBlueAccent,
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

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({Key? key}) : super(key: key);

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late Future<Map> _apiResult;
  late Future<String>? _debugOutput;

  @override
  void initState() {
    super.initState();
    _apiResult = APIConnector().get("events");

    _debugOutput = _apiResult.then((value) {
      const encoder = JsonEncoder.withIndent("    ");
      return encoder.convert(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: _apiResult,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // return Text(jsonEncode(snapshot.data!["data"]["events"]));

            return Column(
                children: snapshot.data!["data"]["events"]
                    // .map<Widget>((e) => Text(jsonEncode(e)))
                    // .map<Widget>((e) => Text("Test"))
                    .map<Widget>((e) => ActivityView(activity: e))
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
        });

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
