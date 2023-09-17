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

  const AlertsPanel({Key? key, required this.loadingFutures}) : super(key: key);

  @override
  State<AlertsPanel> createState() => _AlertsPanelState();
}

class _AlertsPanelState extends State<AlertsPanel> {
  final log = Logger("AlertsPanel");

  Set<AlertsPanelStatusMessage> dismissedMessages = {};

  @override
  void initState() {
    super.initState();

    log.info("Doing init state");

    scheduleMessageDismissals();
  }

  void scheduleMessageDismissals() {
    for (var fut in widget.loadingFutures) {
      log.info("Scheduling success dismissal");

      var msg = AlertsPanelStatusMessage(
          component: fut.$1, status: "done", data: null);

      fut.$2.then((_) {
        return Future.delayed(const Duration(seconds: 2)).then((_) {
          log.info("Adding dismissed message");
          setState(() => dismissedMessages.add(msg));

          log.info("Dismissed messages: $dismissedMessages");
        });
      });
    }
  }

  @override
  void didUpdateWidget(AlertsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    log.info("Did update widget");

    scheduleMessageDismissals();
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
              width: 16, height: 16, child: CircularProgressIndicator()),
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
    }

    Widget icon;
    Widget title;
    (icon, title) = makeFunc(msg);

    return Card(child: ListTile(leading: icon, title: title));
  }

  AlertsPanelStatusMessage getStatusMessageForSnapshot(
      (String, AsyncSnapshot, bool isRefreshing) snapshot) {
    if (snapshot.$2.hasError) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1, status: "error", data: snapshot.$2.error);
    }
    if (snapshot.$2.connectionState == ConnectionState.waiting) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1,
          status: "loading",
          data: {"isRefreshing": snapshot.$3});
    }
    if (snapshot.$2.connectionState == ConnectionState.done) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1, status: "done", data: null);
    }
    return AlertsPanelStatusMessage(
        component: snapshot.$1, status: "unknown", data: null);
  }

  Iterable<Widget> getBuildAlerts(BuildContext context,
      List<(String, AsyncSnapshot, bool isRefreshing)> snapshots) sync* {
    var msgs = snapshots.map(getStatusMessageForSnapshot).toList();

    msgs =
        msgs.where((element) => !dismissedMessages.contains(element)).toList();

    var errorMsgs = msgs
        .where((msg) => msg.status == "error")
        .groupListsBy((msg) => msg.data.toString())
        .entries
        .map((e) => e.value.length == 1
            ? e.value.first
            : AlertsPanelStatusMessage(
                component:
                    // ignore: prefer_interpolation_to_compose_strings
                    e.value
                            .take(e.value.length - 1)
                            .map((e) => e.component)
                            .join(', ') +
                        " & ${e.value.last.component}",
                status: "error",
                data: e.value.first.data));

    msgs = msgs.where((element) => element.status != "error").toList();

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

    for (var msg in errorMsgs) {
      yield buildStatusCard(context, msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    log.info("Building alerts panel");

    Widget Function(
            BuildContext, List<(String, AsyncSnapshot, bool isRefreshing)>)
        innerWidget = (context, snapshots) {
      List<Widget> alerts = getBuildAlerts(context, snapshots).toList();
      if (alerts.isEmpty) {
        return const SizedBox();
      }

      return Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Column(children: alerts));
    };

    for (var a in widget.loadingFutures.reversed) {
      var capturedInnerWidg = innerWidget;
      innerWidget = (context, snapshots) => FutureBuilderPatched(
          future: a.$2,
          builder: (context, snapshot) =>
              capturedInnerWidg(context, snapshots + [(a.$1, snapshot, a.$3)]));
    }

    return innerWidget(context, []);
  }
}
