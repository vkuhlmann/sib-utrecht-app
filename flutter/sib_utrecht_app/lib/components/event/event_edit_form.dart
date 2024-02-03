import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/fragments_bundle.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';

class EventEditForm extends StatefulWidget {
  final Event? originalEvent;
  final ValueSetter<AsyncSnapshot<FragmentsBundle>> setPayload;

  const EventEditForm(
      {required this.originalEvent, required this.setPayload, Key? key})
      : super(key: key);

  @override
  State<EventEditForm> createState() => _EventEditFormState();
}

class _EventEditFormState extends State<EventEditForm> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _nameNLController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _signupLinkController = TextEditingController();

  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  // final DateFormat _apiDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  bool acceptBeta = true;

  Map<String, dynamic> getUpdates() {
    var origEvent = widget.originalEvent;

    // final eventId = origEvent?.id;

    dynamic signup = origEvent?.participate.signup.toJson()
      ?? "none";
    var newSignupLink = _signupLinkController.text.trim();

    if (newSignupLink.isNotEmpty) {
      if (signup == "none" || signup is! Map) {
        signup = {"method": "url"};
      }

      signup["url"] = newSignupLink;
    }

    if (newSignupLink.isEmpty && signup is Map && signup["method"] == "url") {
      signup = "none";
    }

    String? location = _locationController.text.trim();
    if (location.isEmpty) {
      location = null;
    }

    String? startDate = _startController.text.trim();
    startDate = dateInputToCanonical(startDate);
    if (startDate == null) {
      throw Exception("Start date is required");
    }

    String? endDate = _endController.text.trim();
    endDate = dateInputToCanonical(endDate);

    return {
      "name.long": _nameController.text,
      "location": location,
      "date.start": startDate,
      "date.end": endDate,
      "body.description": {
        "html": _descriptionController.text,
      },
      "participate.signup": signup
    };
  }


  // FragmentsBundle getPayloadJson() {
  //   Event newEvent = getUpdatedEvent();
  //   return newEvent.toFragments(includeBody: true);
  // }

  // String getPayload() {
  //   return const JsonEncoder.withIndent("  ").convert(getPayloadJson());
  // }

  @override
  void initState() {
    super.initState();
    setFields();
  }

  AsyncSnapshot<FragmentsBundle> getPayloadSnapshot() {
    FragmentsBundle payload;
    try {
      payload = FragmentsBundle.fromMap(getUpdates());
    } catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
    return AsyncSnapshot.withData(ConnectionState.done, payload);
  }

  void onFieldChanged(_) {
    // setState(() {
    widget.setPayload(getPayloadSnapshot());
    // });
  }

  @override
  void didUpdateWidget(covariant EventEditForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.originalEvent != widget.originalEvent) {
      setFields();
    }
  }

  void setFields() {
    Event? event = widget.originalEvent;
    if (event == null) {
      return;
    }

    var endDate = event.date.end?.toLocal();

    _nameController.text = event.name.long;
    _locationController.text = event.location ?? "";
    _startController.text = _dateFormat.format(event.date.start.toLocal());
    _endController.text = "";
    if (endDate != null) {
      _endController.text = _dateFormat.format(endDate);
    }
    _descriptionController.text =
        event.body?.extractDescriptionAndThumbnail().$1 ?? "";
    _signupLinkController.text = event.participate.signup.url ?? "";
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        // Card(
        //     child:
        ListTile(
            title: TextField(
          controller: _nameController,
          onChanged: onFieldChanged,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Event name'),
        )),
        // ListTile(
        //     title: TextField(
        //   controller: _nameNLController,
        //   onChanged: onFieldChanged,
        //   decoration: const InputDecoration(
        //       border: OutlineInputBorder(), labelText: 'Event name NL'),
        // )),
        const SizedBox(height: 16),
        ListTile(
            title: TextField(
          controller: _locationController,
          onChanged: onFieldChanged,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Event location (optional)'),
        )),
        const SizedBox(height: 16),
        ListTile(
          subtitle: TextField(
            controller: _startController,
            onChanged: onFieldChanged,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Event start (e.g. "2024-01-01 00:00:00")'),
          ),
        ),
        ListTile(
          subtitle: TextField(
            controller: _endController,
            onChanged: onFieldChanged,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Event end (optional)'),
          ),
        ),
        const SizedBox(height: 32),
        ListTile(
            // title: Text(AppLocalizations.of(context)!.eventDescription),
            subtitle: TextField(
                controller: _descriptionController,
                onChanged: onFieldChanged,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Description'),
                maxLines: null)),
        const SizedBox(height: 32),
        ListTile(
            title: TextField(
          controller: _signupLinkController,
          onChanged: onFieldChanged,
          decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Sign-up link (optional)'),
        )),

        // if (!acceptBeta || eventId == null)
        //   ListTile(
        //       leading: Checkbox(
        //           value: acceptBeta,
        //           onChanged: (val) {
        //             setState(() {
        //               acceptBeta = val ?? false;
        //             });
        //           }),
        //       title: const Text(
        //           "I understand this event will only show in the app, not on the website.")),

        const SizedBox(
          height: 32,
        ),
      ]);

  // Event getUpdatedEvent() {
  //   var origEvent = widget.originalEvent;

  //   var startDateInput = _startController.text;

  //   if (startDateInput.isEmpty) {
  //     throw Exception("Start date is required");
  //   }

  //   final eventId = origEvent?.id;

  //   var data = {
  //     if (origEvent != null) ...origEvent.toJson(includeBody: true),
  //     if (origEvent == null) ...{
  //       "status": "published",
  //       "signup": {"type": "none"}
  //     },
  //     if (eventId != null) ...{"id": eventId},
  //     "name": _nameController.text,
  //     "nameNL": _nameNLController.text,
  //     "location": _locationController.text,
  //     "start": dateInputToCanonical(startDateInput),
  //     "end": dateInputToCanonical(_endController.text),
  //     // "description": _descriptionController.text,
  //   };
  //   data["body"] ??= {};
  //   data["body"]["description"] = _descriptionController.text;
  //   // data.remove("description");

  //   var newSignupLink = _signupLinkController.text.trim();

  //   if (newSignupLink.isNotEmpty) {
  //     if (data["signup"]?["url"] == null) {
  //       data["signup"] = {"type": "url"};
  //     }
  //     data["signup"]["url"] = newSignupLink;
  //   }
  //   if (newSignupLink.isEmpty && data["signup"]?["url"] != null) {
  //     data["signup"] = {"type": "none"};
  //   }

  //   data.remove("details");

  //   return Event.fromJson(data, DirectUnpacker());
  // }

  String? dateInputToCanonical(String input) {
    if (input.isEmpty) {
      return null;
    }
    DateTime date;
    try {
      date = _dateFormat.parse(input);
    } catch (e) {
      throw Exception("Invalid date format, expected yyyy-MM-dd HH:mm:ss.");
    }
    return date.toUtc().toIso8601String();
    // return _apiDateFormat.format(date.toUtc());
  }
}
