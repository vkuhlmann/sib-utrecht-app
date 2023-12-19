import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/event_edit_form.dart';
import 'package:sib_utrecht_app/components/resource_pool_access.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';

import '../utils.dart';
import '../globals.dart';
import '../model/api_connector.dart';
import '../model/event.dart';
import '../view_model/async_patch.dart';
import '../components/actions/alerts_panel.dart';
import '../components/api_access.dart';

class EventEditPage extends StatefulWidget {
  final String? eventId;

  const EventEditPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  Future<APIConnector>? connector;

  // Future<Event?>? originalEvent;
  Future<String>? response;

  late Future<Event?> startEditResponse;

  String? get eventId => widget.eventId;

  // Future<String>? payload;
  Future<Map?>? _submission;
  Future<Map?>? _deletion;

  final ValueNotifier<AsyncSnapshot<Map>> payload =
      ValueNotifier(const AsyncSnapshot.nothing());
  final AlertsPanelController _alertsPanelController = AlertsPanelController();

  late ValueSetter<AsyncSnapshot<Map>> setPayload;

  @override
  void initState() {
    super.initState();

    setPayload = (v) => payload.value = v;

    // ValueSetter<String?> a = (v) => _payloadNotifier.value = v;

    // _payloadNotifier.value = "test";

    // if (eventId == null) {
    //   originalEvent = Future.value(null);
    // }

    // startEditResponse = _startEdit();
  }

  Future<Event?> _startEdit() async {
    final eventId = this.eventId;
    if (eventId == null) {
      return null;
    }

    final connector = this.connector;
    if (connector == null) {
      throw StateError("No API connector available");
    }

    final conn = await connector;
    final response = await conn.post("/events/$eventId/edit");
    final event =
        Event.fromJson((response["data"]["event"] as Map), DirectUnpacker());

    return event;
  }

  @override
  void didChangeDependencies() {
    final connector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.connector != connector) {
      log.fine(
          "[EventEditPage] API connector changed from ${this.connector} to $connector");
      this.connector = connector;

      setState(() {
        startEditResponse = _startEdit();
      });

      // if (eventId != null) {
      //   setState(() {
      //     var evFuture = connector.then((c) => c
      //             .post("/events/$eventId/edit")
      //             .then((value) {
      //           if (!mounted) {
      //             return null;
      //           }
      //           setState(() {
      //             payload = Future.value(
      //                 const JsonEncoder.withIndent("  ").convert(value));
      //           });
      //           return value;
      //         }).then((response) => Event.fromJson(
      //                 (response["data"]["event"] as Map), DirectUnpacker())));

      //     originalEvent = evFuture.then(
      //       (Event value) {
      //         setState(() {

      //         });
      //         return value;
      //       },
      //     );
      //   });
      // }
    }

    super.didChangeDependencies();
  }

  Future<Map?> deleteEvent() async {
    var conn = connector;
    if (conn == null) {
      return null;
    }

    var submission = await conn.then((c) => c.delete("/events/$eventId"));
    return submission;
  }

  Future<Map?> submit() async {
    var conn = connector;
    if (conn == null) {
      return null;
    }

    final payload = this.payload.value;

    if (payload.hasError) {
      throw StateError("Cannot submit event: ${payload.error}");
    }

    final data = payload.data;
    if (data == null) {
      throw StateError("Cannot submit event: payload is null");
    }

    final eventId = this.eventId;
    if (eventId == null) {
      var response = await conn.then((c) => c.post("/events",
          // "/events?accept_beta=${acceptBeta ? 'true' : 'false'}",
          body: data));

      int newEventId = response["data"]["event_id"];
      router.goNamed("event_edit",
          pathParameters: {"event_id": newEventId.toString()});

      return response;
    }

    var response =
        await conn.then((c) => c.put("/events/$eventId", body: data));


    if (mounted) {
      final pool = ResourcePoolAccess.maybeOf(context)?.pool;
      
      pool?.eventBodies.invalidateId(
        Event.getBodyIdForEventId(eventId));
      pool?.events.invalidateId(eventId);
    }

    return response;
  }

  // void onFieldChanged(_) {
  //   setState(() {
  //     payload = getPayload();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var subm = _submission;
    var deleteAction = _deletion;

    return WithSIBAppBar(
        actions: const [],
        child: Column(children: [
          Expanded(
              child: SelectionArea(
                  child: CustomScrollView(slivers: [
            SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  FutureBuilderPatched(
                      future: startEditResponse,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                              padding: const EdgeInsets.all(32),
                              child:
                                  Center(child: formatError(snapshot.error)));
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                              padding: EdgeInsets.all(32),
                              child:
                                  Center(child: CircularProgressIndicator()));
                        }

                        final data = snapshot.data;
                        // if (data == null) {
                        //   return const Text("Data missing");
                        // }

                        // final Event? event = snapshot.data;
                        // if (event == null) {
                        //   return const SizedBox();
                        // }

                        // return Card(
                        //     child: ListTile(
                        //         title: Text(event.eventName),
                        //         subtitle: Text(event.location ?? "")));

                        // ...(() {
                        // final Event? event = _eventProvider.cached;
                        // var eventEnd = event.end;
                        // var location = event.location;

                        return Column(children: [
                          EventEditForm(
                              originalEvent: data, setPayload: setPayload),
                          if (eventId != null)
                            ElevatedButton(
                                onPressed: () {
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (BuildContext ctx) {
                                  //       return AlertDialog(
                                  //         title: const Text('Event deletion'),
                                  //         content: const Text(
                                  //             'Are you sure you want to delete the event?'),
                                  //         actions: [
                                  //           // The "Yes" button
                                  //           TextButton(
                                  //               onPressed: () {
                                  //                 // // Remove the box
                                  //                 // setState(() {
                                  //                 //   _isShown = false;
                                  //                 // });

                                  //                 // Close the dialog
                                  //                 Navigator.of(context).pop();
                                  //               },
                                  //               child: const Text('Delete')),
                                  //           TextButton(
                                  //               onPressed: () {
                                  //                 // Close the dialog
                                  //                 Navigator.of(context).pop();
                                  //               },
                                  //               child: const Text('Cancel'))
                                  //         ],
                                  //       );
                                  //     });

                                  router.pushNamed("event_delete_confirm",
                                      pathParameters: {
                                        "event_id": eventId.toString()
                                      }).then((ans) {
                                    if (ans != "delete_confirmed") {
                                      return;
                                    }
                                    setState(() {
                                      var a = deleteEvent();
                                      _deletion = a;
                                      a
                                          .then((v) => Future.delayed(
                                              const Duration(seconds: 2)))
                                          .then((value) {
                                        router.go("/");
                                      });
                                    });
                                  });
                                },
                                child:
                                    Text(AppLocalizations.of(context)!.delete)),
                          const SizedBox(
                            height: 16,
                          ),
                          FilledButton(
                              onPressed: () {
                                setState(() {
                                  _submission = submit();
                                });
                              },
                              child: Text(AppLocalizations.of(context)!.save)),
                          const SizedBox(height: 32),
                          ValueListenableBuilder(
                            valueListenable: payload,
                            builder: (context, snapshot, _) {
                              if (snapshot.hasError) {
                                return Text(snapshot.error.toString());
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              // if (snapshot.hasData) {
                              //   return Text(snapshot.data.toString());
                              // }

                              return const SizedBox();
                            },
                          )
                        ]);
                      }),
                  FutureBuilderPatched(
                    future: _submission,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(child: formatError(snapshot.error)));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()));
                      }

                      var data = snapshot.data;
                      if (data == null) {
                        if (snapshot.connectionState == ConnectionState.none) {
                          return const SizedBox();
                        }
                        return const Text("No response");
                      }

                      return Text(
                          const JsonEncoder.withIndent("  ").convert(data));
                    },
                  )
                ]))),
          ]))),
          AlertsPanel(controller: _alertsPanelController, loadingFutures: [
            if (subm != null)
              AlertsFutureStatus(component: "submission", future: subm, data: {
                "err_msg": (msg) => const Text("Could not submit changes:"),
                "loading_msg": (msg) => const Text("Submitting changes..."),
                "done_msg": (msg) => const Text("Submitted changes"),
              }),
            if (deleteAction != null)
              AlertsFutureStatus(
                  component: "deletion",
                  future: deleteAction,
                  data: {
                    "err_msg": (msg) => const Text("Could not delete event:"),
                    "loading_msg": (msg) => const Text("Deleting event..."),
                    "done_msg": (msg) => const Text("Deleted event"),
                  })
          ])
        ]));
  }
}
