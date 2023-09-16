part of '../main.dart';

class AlertsPanelStatusMessage {
  final String component;
  final String status;
  final Object? data;

  const AlertsPanelStatusMessage(
      {required this.component, required this.status, required this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsPanelStatusMessage &&
          runtimeType == other.runtimeType &&
          component == other.component &&
          status == other.status &&
          data == other.data;

  @override
  int get hashCode => component.hashCode ^ status.hashCode ^ data.hashCode;
}

class AlertsPanel extends StatefulWidget {
  final List<(String, Future, bool isRefreshing)> loadingFutures;

  // final Map<String, Widget Function AlertsPanelStatusMessage> cardBuilder = {
  //   "error":
  // }

  const AlertsPanel({Key? key, required this.loadingFutures}) : super(key: key);

  @override
  State<AlertsPanel> createState() => _AlertsPanelState();
}

class _AlertsPanelState extends State<AlertsPanel> {
  final log = Logger("AlertsPanel");

  // Set<(String, String, Object?)> dismissedMessages = {};
  Set<AlertsPanelStatusMessage> dismissedMessages = {};
  Set<Future> seenFutures = {};

  @override
  void initState() {
    super.initState();

    // loadingFutures = widget.loadingFutures;
    log.info("Doing init state");
  }

  void scheduleMessageDismissals() {
    // return;
    for (var fut in widget.loadingFutures) {
      if (seenFutures.contains(fut.$2)) {
        continue;
      }

      log.info("Scheduling success dismissal");

      seenFutures.add(fut.$2);

      var msg = AlertsPanelStatusMessage(
          component: fut.$1, status: "done", data: null);

      // if (scheduledMessageDismissals.contains(msg)) {
      //   continue;
      // }

      // try {
      fut.$2.then((_) {
        // if (scheduledMessageDismissals.contains(msg)) {
        //   return Future.value();
        // }

        // scheduledMessageDismissals.add(msg);
        return Future.delayed(const Duration(seconds: 2)).then(
            (_) {
              log.info("Adding dismissed message");
              setState(() => dismissedMessages.add(msg));

              log.info("Dismissed messages: $dismissedMessages");
            }
        );
      });
      
      // .then((_) => Future.delayed(const Duration(seconds: 2))).then((_) {
      //   setState(() {
      //     log.info("Adding dismissed message");

      //     // dismissedMessages.add((fut.$1, "done", null));
      //     dismissedMessages.add(AlertsPanelStatusMessage(
      //         component: fut.$1, status: "done", data: null));
      //   });
      // });
      // } catch (e) {
      //   log.warning("Error scheduling success dismissal: $e");
      // }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    log.info("Dependencies changed");
  }

  final Map<String, (Widget, Widget) Function(AlertsPanelStatusMessage)>
      makeStatusCardContent = {
    "error": (msg) => (
          const Icon(Icons.error, color: Colors.red),
          Wrap(children: [
            Text("Could not load ${msg.component}:"),
            const SizedBox(width: 8),
            formatError(msg.data)
          ])
        ),
    "loading": (msg) => (
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  // color: Colors.green,
                  )),
          (msg.data as Map)["isRefreshing"] == true
              ? Text("Refreshing ${msg.component}...")
              : Text("Loading ${msg.component}...")
        ),
    "done": (msg) => (
          const Icon(Icons.done, color: Colors.green),
          Text("Loaded ${msg.component}")
        ),
  };

  Widget buildStatusCard(BuildContext context, AlertsPanelStatusMessage msg) {
    var makeFunc = makeStatusCardContent[msg.status];
    if (makeFunc == null) {
      log.warning("Unknown status ${msg.status}");

      return const SizedBox();
      // throw Exception("Unknown status ${msg.status}");
    }

    Widget icon;
    Widget title;
    (icon, title) = makeFunc(msg);

    return Card(child: ListTile(leading: icon, title: title));
  }

  Iterable<Widget> getBuildAlerts(BuildContext context,
      List<(String, AsyncSnapshot, bool isRefreshing)> snapshots) sync* {
    // var byState = snapshots.groupListsBy((element) {
    //   if (element.$2.hasError) {
    //     return "error";
    //   }
    //   if (element.$2.connectionState == ConnectionState.waiting) {
    //     return "loading";
    //   }
    //   if (element.$2.connectionState == ConnectionState.done) {
    //     return "done";
    //   }
    // });
    var msgs = snapshots.map((element) {
      if (element.$2.hasError) {
        // var cont = APIAccess.of(context);
        // if (cont.key)

        return AlertsPanelStatusMessage(
            component: element.$1, status: "error", data: element.$2.error);
      }
      if (element.$2.connectionState == ConnectionState.waiting) {
        return AlertsPanelStatusMessage(
            component: element.$1,
            status: "loading",
            data: {"isRefreshing": element.$3});
      }
      if (element.$2.connectionState == ConnectionState.done) {
        // return (element.$1, "done", null);
        return AlertsPanelStatusMessage(
            component: element.$1, status: "done", data: null);
      }
      // return (element.$1, "unknown", null);
      return AlertsPanelStatusMessage(
          component: element.$1, status: "unknown", data: null);
    }).toList();

    msgs = msgs.where((element) => !dismissedMessages.contains(element)).toList();

    var msgs2 = msgs
        .groupListsBy((element) => element.status)
        .entries
        .sortedBy<num>(
            (element) => ["done", "loading", "error"].indexOf(element.key))
        .map<List<AlertsPanelStatusMessage>>((e) => e.value)
        .flattened;

    for (var msg in msgs2) {
      yield buildStatusCard(context, msg);
    }
    // )
    // .map<List<AlertsPanelStatusMessage>>((e) => e.value)
    // .flattened;

    // yield Padding(
    //   padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
    //   child: Text(
    //     "Er is een fout opgetreden bij het ophalen van de gegevens.",
    //     style: Theme.of(context).textTheme.titleLarge,
    //   ),
    // );

    // var errorMsgs = byState

    // snapshots.fold(null, (previousValue, element) => previousValue ?? )
    // snapshots.groupListsBy((element) => element.$1.)
  }

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //     padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
    //     child:
    //     FutureBuilder(
    //   future: Future.wait(widget.loadingFutures.map((e) => e.$2.then((v) => (e.$1, v)))),
    //   builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       var alerts = widget.loadingFutures
    //         .map((e) => (e.item1, e.item2, snapshot.data!.firstWhere((element) => element is List<dynamic> && element.length > 0)))
    //         .toList();

    //       return Column(children: getBuildAlerts(context, alerts));
    //     }

    //     return const SizedBox();
    //   }
    // ));

    scheduleMessageDismissals();

    log.info("Building alerts panel");

    Widget Function(
            BuildContext, List<(String, AsyncSnapshot, bool isRefreshing)>)
        innerWidget = (context, snapshots) =>
            Column(children: getBuildAlerts(context, snapshots).toList());

    for (var a in widget.loadingFutures.reversed) {
      var capturedInnerWidg = innerWidget;
      innerWidget = (context, snapshots) => FutureBuilderPatched(
          future: a.$2,
          builder: (context, snapshot) =>
              capturedInnerWidg(context, snapshots + [(a.$1, snapshot, a.$3)])
          // if (snapshot.connectionState == ConnectionState.done) {
          //   return innerWidget(context, snapshots + [(a.$1, snapshot)]);
          // }

          // return const SizedBox();
          // }
          );
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        child: innerWidget(context, []));

    // return Container();
    // return

    //     Column(children: items));
  }
}
