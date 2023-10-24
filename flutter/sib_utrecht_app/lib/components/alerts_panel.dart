import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import "package:collection/collection.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils.dart';
import '../view_model/async_patch.dart';

class AlertsPanelStatusMessage {
  final String component;
  final String status;
  final Map data;

  const AlertsPanelStatusMessage(
      {required this.component, required this.status, required this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsPanelStatusMessage &&
          // runtimeType == other.runtimeType &&
          component == other.component &&
          status == other.status;
          //  &&
          // data == other.data;

  @override
  int get hashCode => component.hashCode ^ status.hashCode;// ^ data.hashCode;
}

class AlertsFutureStatus {
  final String component;
  final Future future;
  final Map data;  

  const AlertsFutureStatus(
      {required this.component, required this.future, required this.data});
}

class AlertsPanelController {
  Set<AlertsPanelStatusMessage> dismissedMessages = {};
}

class AlertsPanel extends StatefulWidget {
  final List<AlertsFutureStatus> loadingFutures;
  final AlertsPanelController controller;

  const AlertsPanel({Key? key, required this.loadingFutures,
  required this.controller}) : super(key: key);

  @override
  State<AlertsPanel> createState() => _AlertsPanelState();
}

class _AlertsPanelState extends State<AlertsPanel> {
  final log = Logger("AlertsPanel");
  
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
          component: fut.component, status: "done", data: fut.data);

      fut.future.then((_) {
        return Future.delayed(const Duration(seconds: 2)).then((_) {
          log.info("Adding dismissed message");
          setState(() => widget.controller.dismissedMessages.add(msg));

          log.info("Dismissed messages: ${widget.controller.dismissedMessages}");
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

  static Widget getErrorTitle(AlertsPanelStatusMessage msg) {
    Function(AlertsPanelStatusMessage)? handler = msg.data["err_msg"];
    if (handler != null) {
      return handler(msg);
    }

    return Builder(
        builder: (context) =>
            Text(AppLocalizations.of(context)!.couldNotLoad(msg.component)));
  }

  static Widget getLoadingTitle(AlertsPanelStatusMessage msg) {
    Function(AlertsPanelStatusMessage)? handler = msg.data["loading_msg"];
    if (handler != null) {
      return handler(msg);
    }

    return Builder(
        builder: (context) => msg.data["isRefreshing"] == true
            ? Text(AppLocalizations.of(context)!
                .refreshingComponent(msg.component))
            // Text("Refreshing ${msg.component}...")
            : Text(
                AppLocalizations.of(context)!.loadingComponent(msg.component)));
  }

  static Widget getDoneTitle(AlertsPanelStatusMessage msg) {
    Function(AlertsPanelStatusMessage)? handler = msg.data["done_msg"];
    if (handler != null) {
      return handler(msg);
    }

    return Builder(
        builder: (context) =>
            Text("Loaded ${msg.component}"));
  }

  final Map<
      String,
      (Widget, Widget, Widget?) Function(
          BuildContext, AlertsPanelStatusMessage)> makeStatusCardContent = {
    "error": (context, msg) => (
          const Icon(Icons.error, color: Colors.red),
          Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
            // Text("Could not load ${msg.component}:"),
            // Text(AppLocalizations.of(context)!.couldNotLoad(msg.component))
            getErrorTitle(msg)
            // const SizedBox(width: 8),
            // Padding(padding: const EdgeInsets.all(8), child: formatError(msg.data))
          ]),
          Padding(
              padding: const EdgeInsets.all(8),
              child: formatError(msg.data["error"]))
        ),
    "loading": (context, msg) => (
          const SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator()),
          getLoadingTitle(msg),
          // Text("Loading ${msg.component}..."),
          null
        ),
    "done": (context, msg) => (
          const Icon(Icons.done, color: Colors.green),
          getDoneTitle(msg),
          null
        ),
  };

  Widget buildStatusCard(BuildContext context, AlertsPanelStatusMessage msg) {
    var makeFunc = makeStatusCardContent[msg.status];
    if (makeFunc == null) {
      log.warning("Unknown status ${msg.status}");

      return const SizedBox();
    }

    // Widget icon;
    // Widget title;
    final (icon, title, subtitle) = makeFunc(context, msg);

    return Card(
        child: ListTile(
      leading: icon,
      title: title,
      subtitle: subtitle,
    ));
  }

  AlertsPanelStatusMessage getStatusMessageForSnapshot(
      (String, AsyncSnapshot, Map) snapshot) {
    if (snapshot.$2.hasError) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1, status: "error", data: {
            ...snapshot.$3,
            "error": snapshot.$2.error,
           });
    }
    if (snapshot.$2.connectionState == ConnectionState.waiting) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1,
          status: "loading",
          // data: {"isRefreshing": snapshot.$3}
          data: snapshot.$3
          );
    }
    if (snapshot.$2.connectionState == ConnectionState.done) {
      return AlertsPanelStatusMessage(
          component: snapshot.$1, status: "done", data: snapshot.$3);
    }
    return AlertsPanelStatusMessage(
        component: snapshot.$1, status: "unknown", data: snapshot.$3);
  }

  Iterable<Widget> getBuildAlerts(BuildContext context,
      List<(String, AsyncSnapshot, Map data)> snapshots) sync* {
    var msgs = snapshots.map(getStatusMessageForSnapshot).toList();

    msgs =
        msgs.where((element) => !widget.controller.dismissedMessages.contains(element)).toList();

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
            BuildContext, List<(String, AsyncSnapshot, Map)>)
        innerWidget = (context, snapshots) {
      List<Widget> alerts = getBuildAlerts(context, snapshots).toList();
      if (alerts.isEmpty) {
        return const SizedBox();
      }

      return Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(children: alerts)));
    };

    for (var a in widget.loadingFutures.reversed) {
      var capturedInnerWidg = innerWidget;
      innerWidget = (context, snapshots) => FutureBuilderPatched(
          future: a.future,
          builder: (context, snapshot) =>
              capturedInnerWidg(context, snapshots +
              [(a.component, snapshot, a.data)]));
    }

    return innerWidget(context, []);
  }
}
