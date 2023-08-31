part of 'main.dart';

// class Activities {}

class ActivityView extends StatefulWidget {
  final Map activity;

  const ActivityView({Key? key, required this.activity}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  @override
  Widget build(BuildContext context) {
    // return Text(jsonEncode(widget.activity));
    return Text(widget.activity["event_name"]);
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
