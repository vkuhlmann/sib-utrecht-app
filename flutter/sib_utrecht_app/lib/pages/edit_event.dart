import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils.dart';
import '../globals.dart';
import '../model/api_connector.dart';
import '../model/event.dart';
import '../view_model/async_patch.dart';
import '../components/alerts_panel.dart';
import '../components/api_access.dart';

class EventEditPage extends StatefulWidget {
  final int? eventId;

  const EventEditPage({Key? key, required this.eventId}) : super(key: key);

  @override
  State<EventEditPage> createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  Future<APIConnector>? connector;

  Future<Event?>? originalEvent;
  Future<String>? response;
  // int? eventId;

  int? get eventId => widget.eventId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameNLController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _signupLinkController = TextEditingController();

  final AlertsPanelController _alertsPanelController = AlertsPanelController();

  bool acceptBeta = true;

  // final TextEditingController _signupLinkController = TextEditingController();

  Future<String>? payload;
  Future<Map?>? _submission;
  Future<Map?>? _deletion;

  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final DateFormat _apiDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  void initState() {
    super.initState();

    // eventId = null;
    if (eventId == null) {
      originalEvent = Future.value(null);
    }
  }

  @override
  void didChangeDependencies() {
    final connector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.connector != connector) {
      log.fine(
          "[EventEditPage] API connector changed from ${this.connector} to $connector");
      this.connector = connector;

      if (eventId != null) {
        setState(() {
          var evFuture = connector.then((c) => c
                  .get("/events/$eventId?include_image=true")
                  .then((value) {
                setState(() {
                  payload = Future.value(
                      const JsonEncoder.withIndent("  ").convert(value));
                });
                return value;
              }).then((response) => Event.fromJson(
                      (response["data"]["event"] as Map).map<String, dynamic>(
                          (key, value) => MapEntry(key, value)))));
          // originalEvent = evFuture;
          originalEvent = evFuture.then(
            (Event value) {
              setState(() {
                var endDate = value.end;

                _nameController.text = value.eventName;
                _nameNLController.text = value.data["nameNL"] ?? "";
                _locationController.text = value.location ?? "";
                _startController.text = _dateFormat.format(
                    value.start.toLocal()); //value.start.toIso8601String();
                _endController.text = "";
                if (endDate != null) {
                  _endController.text = _dateFormat.format(endDate.toLocal());
                }
                _descriptionController.text = value.data["description"] ?? "";
                _signupLinkController.text = value.data["signup"]?["url"] ?? "";
              });
              return value;
            },
          );
        });
      }
    }

    super.didChangeDependencies();
  }

  Future<Map?> deleteEvent() async {
    var conn = connector;
    if (conn == null) {
      return null;
    }

    // await Future.delayed(const Duration(seconds: 5));

    // showDialog(context: context, builder:(context) {

    // },);

    var submission = await conn.then((c) => c.delete("/events/$eventId"));

    // router.go("/");

    return submission;
    // return {};
  }

  Future<Map?> submit() async {
    var conn = connector;
    if (conn == null) {
      return null;
    }

    var payload = await getPayloadJson();

    if (eventId == null) {
      var submission = await conn.then((c) => c.post(
          "/events?accept_beta=${acceptBeta ? 'true' : 'false'}",
          body: payload));

      int newEventId = submission["data"]["event_id"];
      router.goNamed("event_edit",
          pathParameters: {"event_id": newEventId.toString()});

      // return const JsonEncoder.withIndent("  ").convert(submission);
      return submission;
    }

    // await Future.delayed(const Duration(seconds: 4));
    // return {"status": "success", "data": {"event_id": "5555"}};

    // throw Exception("Not implemented");

    var submission =
        await conn.then((c) => c.put("/events/$eventId", body: payload));

    // conn.then((c) => c.put("/events/$eventId", body: payload));

    // String url = _urlController.text;
    // Map? body = _requestBodyJsonController.text.isNotEmpty
    //     ? jsonDecode(_requestBodyJsonController.text)
    //     : null;

    // setState(() {
    //   response = connector!.then((c) {
    //     switch (method) {
    //       case "GET":
    //         return c.get(url);
    //       case "POST":
    //         return c.post(url, body: body);
    //       case "PUT":
    //         return c.put(url, body: body);
    //       case "DELETE":
    //         return c.delete(url);
    //     }
    //     throw Exception("Unknown method $method");
    //   }).then((value) {
    //     return const JsonEncoder.withIndent("  ").convert(value);
    //   });
    // });
  }

  Future<Map> getPayloadJson() async {
    Event newEvent = await getUpdatedEvent();
    return newEvent.data;
  }

  Future<String> getPayload() async {
    return const JsonEncoder.withIndent("  ").convert(await getPayloadJson());
  }

  void onFieldChanged(_) {
    setState(() {
      payload = getPayload();
    });
  }

  String? dateInputToCanonical(String input) {
    if (input.isEmpty) {
      return null;
    }
    DateTime date;
    try{
      date = _dateFormat.parse(input);
    }catch(e){
      throw Exception("Invalid date format, expected yyyy-MM-dd HH:mm:ss.");
    }
    return _apiDateFormat.format(date.toUtc());
  }

  Future<Event> getUpdatedEvent() async {
    var origEvent = await originalEvent;

    var startDateInput = _startController.text;

    if (startDateInput.isEmpty) {
      throw Exception("Start date is required");
    }

    var data = {
      if (origEvent != null) ...origEvent.data,
      if (origEvent == null) ...{
        "status": "published",
        "signup": {"type": "none"}
      },
      if (eventId != null) ...{"id": eventId},
      "name": _nameController.text,
      "nameNL": _nameNLController.text,
      "location": _locationController.text,
      "start": dateInputToCanonical(startDateInput),
      "end": dateInputToCanonical(_endController.text),
      "description": _descriptionController.text,
      // "signup": {"url": _signupLinkController.text}
    };

    var newSignupLink = _signupLinkController.text.trim();

    if (newSignupLink.isNotEmpty) {
      if (data["signup"]?["url"] == null) {
        data["signup"] = {"type": "url"};
      }
      data["signup"]["url"] = newSignupLink;
    }
    if (newSignupLink.isEmpty && data["signup"]?["url"] != null) {
      data["signup"] = {"type": "none"};
    }

    data.remove("details");

    return Event.fromJson(data);
  }

  Widget buildEventForm() => Builder(
      builder: (context) => Column(children: [
            Card(
                child: ListTile(
                    title: TextField(
              controller: _nameController,
              onChanged: onFieldChanged,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Event name'),
            ))),
            Card(
                child: ListTile(
                    title: TextField(
              controller: _nameNLController,
              onChanged: onFieldChanged,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: 'Event name NL'),
            ))),
            Card(
                child: ListTile(
                    title: TextField(
              controller: _locationController,
              onChanged: onFieldChanged,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Event location (optional)'),
            ))),
            // if (location != null) Card(child: ListTile(title: Text(location))),
            // Card(child: ListTile(title: Text("your (student) room. \ud83e\ude84\ud83c\udfa8\r\n\r\nWe will"))),
            Card(
                child: ListTile(
              // title: Text("${AppLocalizations.of(context)!.eventStarts}: "),
              subtitle: TextField(
                controller: _startController,
                onChanged: onFieldChanged,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event start (e.g. "2024-01-01 00:00:00")'),
              ),
            )),
            Card(
                child: ListTile(
              // title: Text("${AppLocalizations.of(context)!.eventEnds}: "),
              subtitle: TextField(
                controller: _endController,
                onChanged: onFieldChanged,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Event end (optional)'),
              ),
            )),
            Card(
                child: ListTile(
                    title: Text(AppLocalizations.of(context)!.eventDescription),
                    subtitle: TextField(
                        controller: _descriptionController,
                        onChanged: onFieldChanged,
                        maxLines: null))),
            Card(
                child: ListTile(
                    title: TextField(
              controller: _signupLinkController,
              onChanged: onFieldChanged,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sign-up link (optional)'),
            ))),

            if (!acceptBeta || eventId == null)
              Card(
                  child: ListTile(
                      leading: Checkbox(
                          value: acceptBeta,
                          onChanged: (val) {
                            setState(() {
                              acceptBeta = val ?? false;
                            });
                          }),
                      title: const Text(
                          "I understand this event will only show in the app, not on the website."))),

            // Checkbox(value: value, onChanged: onChanged)
            const SizedBox(
              height: 32,
            ),

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

                  router.pushNamed("event_delete_confirm", pathParameters: {"event_id": eventId.toString()})
                  .then((ans) {
                    if (ans != "delete_confirmed") {
                      return;
                    }
                    setState(() {
                      var a = deleteEvent();
                      _deletion = a;
                      a.then((v) => Future.delayed(const Duration(seconds: 2))).then((value) {
                        router.go("/");
                      });
                    });
                  });

                  // setState(() {
                  //   _submission = delete_event();
                  // });
                },
                // child: const Wrap(children: [Icon(Icons.delete), Text("Delete")]
                child: const Text("Delete")),
            const SizedBox(
              height: 16,
            ),

            FilledButton(
                onPressed: () {
                  setState(() {
                    _submission = submit();
                  });
                },
                child: const Text("Save")),
            const SizedBox(height: 32),
            FutureBuilder(
              future: payload,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasData) {
                  return Text(snapshot.data.toString());
                }

                return const SizedBox();
              },
            )
            // buildThumbnailCard(context, event),
          ]));

  @override
  Widget build(BuildContext context) {
    var subm = _submission;
    var deleteAction = _deletion;

    return Column(children: [
      Expanded(
          child: SelectionArea(
              child: CustomScrollView(slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              // if (_eventProvider.cached == null)
              //   FutureBuilderPatched(
              //       future: _eventProvider.loading,
              //       builder: (eventContext, eventSnapshot) {
              //         if (eventSnapshot.hasError) {
              //           // return Text("${eventSnapshot.error}");
              //           return Padding(
              //               padding: const EdgeInsets.all(32),
              //               child: Center(
              //                   child: formatError(eventSnapshot.error)));
              //         }
              //         if (eventSnapshot.connectionState ==
              //             ConnectionState.waiting) {
              //           return const Padding(
              //               padding: EdgeInsets.all(32),
              //               child: Center(child: CircularProgressIndicator()));
              //         }

              //         return const SizedBox();
              //       }),

              FutureBuilderPatched(
                  future: originalEvent,
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

                    final Event? event = snapshot.data;
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

                    return buildEventForm();
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

                  // if (snapshot.connectionState == ConnectionState.none &&
                  //     !snapshot.hasData) {
                  //   return const SizedBox();
                  // }

                  var data = snapshot.data;
                  if (data == null) {
                    if (snapshot.connectionState == ConnectionState.none) {
                      return const SizedBox();
                    }
                    return const Text("No response");
                  }

                  return Text(const JsonEncoder.withIndent("  ").convert(data));
                },
              )
              // }()),
            ]))),
      ]))),
      AlertsPanel(
        controller: _alertsPanelController,
        loadingFutures: [
        if (subm != null)
          AlertsFutureStatus(
            component: "submission",
            future: subm,
            data: {
              "err_msg": (msg) => const Text("Could not submit changes:"),
              "loading_msg": (msg) => const Text("Submitting changes..."),
              "done_msg": (msg) => const Text("Submitted changes"),
            }
          ),
        if (deleteAction != null)
          AlertsFutureStatus(
            component: "deletion",
            future: deleteAction,
            data: {
              "err_msg": (msg) => const Text("Could not delete event:"),
              "loading_msg": (msg) => const Text("Deleting event..."),
              "done_msg": (msg) => const Text("Deleted event"),
            }
          )
        // ("details", _eventProvider.loading, _eventProvider.cached != null),
        // (
        //   "participants",
        //   _participantsProvider.loading,
        //   _participantsProvider.cached != null
        // )
      ])
    ]);
  }
}
