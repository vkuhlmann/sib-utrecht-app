import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' as flutter_html;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:sib_utrecht_app/model/description_fuzzy_extract.dart';
import 'package:sib_utrecht_app/model/event.dart';
import 'package:sib_utrecht_app/model/fragments_bundle.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sliver_tools/sliver_tools.dart';

class EventEditForm extends StatefulWidget {
  final Event? originalEvent;
  final ValueSetter<AsyncSnapshot<FragmentsBundle>> setPayload;

  const EventEditForm(
      {required this.originalEvent, required this.setPayload, Key? key})
      : super(key: key);

  @override
  State<EventEditForm> createState() => _EventEditFormState();
}

class _EventEditFormState extends State<EventEditForm>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _nameNLController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  final TextEditingController _descriptionHtmlController = TextEditingController();
  final TextEditingController _descriptionMarkdownController = TextEditingController();
  final TextEditingController _signupLinkController = TextEditingController();

  final TextEditingController _spacesController = TextEditingController();
  final TextEditingController _registerDeadlineController =
      TextEditingController();
  late TabController _tabController;

  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  // final DateFormat _apiDateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  bool wordpressControlled = true;
  bool enableSignup = true;
  int spaces = 1;
  bool get isNew => widget.originalEvent == null;
  String? descriptionHtml;
  int descriptionTab = 1;
  late ImagePicker picker;

  Future<Map> descriptionFields = Future.value({});

  Map<String, dynamic> getUpdates() {
    var origEvent = widget.originalEvent;

    // final eventId = origEvent?.id;

    dynamic signup = origEvent?.participate.signup.toJson() ??
        origEvent?.participate.signup.method ??
        "none";
    if (!wordpressControlled) {
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
    }

    if (wordpressControlled) {
      if (!enableSignup) {
        signup = "none";
      }

      if (enableSignup) {
        if (signup is! Map || signup["method"] != "api") {
          signup = <String, dynamic>{"method": "api"};
        }

        // if (_spacesController.text.isEmpty) {
        //   signup["spaces"] = 0;
        // } else {
        late int spacesVal;
        try {
          spacesVal = int.parse(_spacesController.text);
        } on FormatException catch (_) {
          throw Exception("Spaces must be a number");
        }

        setState(() {
          spaces = spacesVal;
        });
        signup["spaces"] = spacesVal;

        // int.parse(_spacesController.text);
        // }

        // signup["spaces"] =
        // int.tryParse(_spacesController.text)
        //int.tryParse(_spacesController.text) ?? 0;
        signup["end"] =
            dateInputToCanonical(_registerDeadlineController.text.trim());
      }
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
        "html": descriptionHtml,
      },
      "participate.signup": signup,
      if (isNew) "wordpress": wordpressControlled
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
    _tabController = TabController(length: 3, vsync: this, initialIndex: descriptionTab);
    _tabController.addListener(() {
      setState(() {
        descriptionTab = _tabController.index;
      });
    });
    picker = ImagePicker();
    setFields();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _startController.dispose();
    _endController.dispose();
    _descriptionHtmlController.dispose();
    _descriptionMarkdownController.dispose();
    _signupLinkController.dispose();
    _spacesController.dispose();
    _registerDeadlineController.dispose();
    _tabController.dispose();
    super.dispose();
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
    onFieldsUpdated();
    // });
  }

  void onFieldsUpdated() {
    widget.setPayload(getPayloadSnapshot());
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
    setState(() {
      wordpressControlled = (event?.controller ?? "wordpress") == "wordpress";
      enableSignup = (event?.participate.signup.method ?? "none") != "none";
    });

    if (event == null) {
      if (wordpressControlled) {
        enableSignup = true;
        _spacesController.text = "40";
      }

      return;
    }

    var endDate = event.date.end?.toLocal();
    final signupEnd = event.participate.signup.end?.toLocal();

    _nameController.text = event.name.long;
    _locationController.text = event.location ?? "";
    _startController.text = _dateFormat.format(event.date.start.toLocal());
    _endController.text = "";
    if (endDate != null) {
      _endController.text = _dateFormat.format(endDate);
    }
    final descriptionHtml = event.body?.extractDescriptionAndThumbnail().$1;
    setState(() {
      this.descriptionHtml = descriptionHtml;
    });
    _descriptionHtmlController.text = descriptionHtml ?? "";
    _descriptionMarkdownController.text = "";
    //  event.body?.description?.markdown ?? "";
    _signupLinkController.text = event.participate.signup.url ?? "";

    int? spacesVal = event.participate.signup.spaces;
    setState(() {
      spaces = spacesVal ?? 1;
    });

    _spacesController.text = spacesVal?.toString() ?? "";
    _registerDeadlineController.text = "";

    if (signupEnd != null) {
      _registerDeadlineController.text = _dateFormat.format(signupEnd);
    }
  }

  void doExtractFromDescription(String desc) {
    final anchor = DateTime.now();

    final descriptionFields =
        DescriptionFuzzyExtract.extractFieldsFromDescription(desc,
            anchor: anchor);

    setState(() {
      this.descriptionFields = descriptionFields;
    });

    descriptionFields.then((value) {
      if (!mounted) {
        return;
      }

      String? nameLong = value["name.long"];

      if (nameLong != null &&
          nameLong.isNotEmpty &&
          _nameController.text.isEmpty) {
        _nameController.text = nameLong;
      }

      String? location = value["location"];
      if (location != null &&
          location.isNotEmpty &&
          _locationController.text.isEmpty) {
        _locationController.text = location;
      }

      DateTime? startDate = value["date.start"];
      if (startDate != null && _startController.text.isEmpty) {
        _startController.text = _dateFormat.format(startDate);
      }

      DateTime? endDate = value["date.end"];
      if (endDate != null && _endController.text.isEmpty) {
        _endController.text = _dateFormat.format(endDate);
      }

      // if (value["participate.price.max"] != null) {
      //   _maxPriceController.text = value["participate.price.max"].toString();
      // }

      String? startTime = value["date.start_time"];
      if (startTime != null && _startController.text.isEmpty) {
        _startController.text = "${anchor.year}-??-?? $startTime:00";
      }

      String? endTime = value["date.end_time"];
      if (endTime != null && _endController.text.isEmpty) {
        _endController.text = "${anchor.year}-??-?? $endTime:00";
      }

      onFieldsUpdated();

      // "name.long": title,
      // if (location != null) "location": location,
      // if (start != null) "date.start": start,
      // if (end != null) "date.end": end,
      // if (startTime != null && start == null)
      //   "date.start_time": formatTimeOfDay(startTime),
      // if (endTime != null && end == null)
      //   "date.end_time": formatTimeOfDay(endTime),
      // if (maxPrice != null) "participate.price.max": maxPrice,
    });

    // var fields = extractFieldsFromDescription(desc);
    // setState(() {
    //   descriptionFields = Future.value(fields);
    // });
  }

  Future<void> uploadImage(XFile file) async {
    final bytes = await file.readAsBytes();
    if (!mounted) {
      return;
    }

    final conn = await APIAccess.of(context).connector;
    final httpConn = conn.base as HTTPApiConnector;

  }

  @override
  Widget build(BuildContext context) => MultiSliver(children: [
        // Column(children: [
        // Card(
        //     child:
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Center(
                        child: Text(
                      "Header",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
                maxCrossAxisExtent: 700,
                child: SliverToBoxAdapter(
                    child: Column(children: [
                  const SizedBox(height: 16),
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
                  if (!wordpressControlled)
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
                          labelText:
                              'Event start (e.g. "2024-01-01 00:00:00")'),
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
                  const SizedBox(height: 48),
                ])))),

        // const SizedBox(height: 32),
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Center(
                        child: Text(
                      "Body",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
              maxCrossAxisExtent: 700,
              child: MultiSliver(children: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // DefaultTabController(
                //     length: 3,
                //     child:
                // Column(children: [
                  SliverToBoxAdapter(child: TabBar(
                                controller: _tabController,
                                tabs: const [
                            Tab(text: "Preview"),
                            Tab(text: "WhatsApp Markdown"),
                            Tab(text: "HTML"),
                          ])),
                // NestedScrollView(
                //     headerSliverBuilder: ((context, innerBoxIsScrolled) => []),
                //         //   SliverAppBar(
                //         //       bottom: TabBar(
                //         //         controller: _tabController,
                //         //         tabs: const [
                //         //     Tab(text: "Preview"),
                //         //     Tab(text: "WhatsApp markdown"),
                //         //     Tab(text: "HTML"),
                //         //   ])),
                //         // ]),
                //     body: a
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(child:
                    // TabBarView(
                    //   controller: _tabController,
                    //   children: 
                      [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                          child: flutter_html.HtmlWidget(
                            // ((event.data["post_content"] ?? "") as String).replaceAll("\r\n\r\n", "<br/><br/>"),
                            descriptionHtml ?? "",
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                          )),
                       ListTile(
                          // title: Text(AppLocalizations.of(context)!.eventDescription),
                          subtitle: TextField(
                              controller: _descriptionMarkdownController,
                              onChanged: (val) {
                                final descriptionHtml = DescriptionFuzzyExtract.markdownToHtml(val);
                                if (descriptionHtml == null) {
                                  return;
                                }

                                _descriptionHtmlController.text = descriptionHtml;

                                onFieldChanged(val);
                                setState(() {
                                  this.descriptionHtml = descriptionHtml;
                                });

                                doExtractFromDescription(val);
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Description (markdown)'),
                              maxLines: null)),
                      ListTile(
                          // title: Text(AppLocalizations.of(context)!.eventDescription),
                          subtitle: TextField(
                              controller: _descriptionHtmlController,
                              onChanged: (val) {
                                onFieldChanged(val);
                                setState(() {
                                  descriptionHtml = val;
                                });

                                doExtractFromDescription(val);
                              },
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Description (html)'),
                              maxLines: null)),
                    ][descriptionTab]),
                // ])
                SliverToBoxAdapter(
                    child: Column(children: [
                  const SizedBox(height: 48),
                  Card(
                      child: FutureBuilderPatched(
                          future: descriptionFields,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final data = snapshot.data;
                            if (data == null) {
                              return const SizedBox();
                            }

                            return Text(JsonEncoder.withIndent("  ", (e) {
                              if (e is DateTime) {
                                return e.toIso8601String();
                              }
                              return e.toJson();
                            }).convert(data));
                          })),
                  const SizedBox(height: 48),
                  FilledButton(onPressed: () async {
                    
                    XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // image.mimeType
                      // image.name;

                      final bytes = await image.readAsBytes();
                      final base64 = base64Encode(bytes);
                      print(base64.substring(0, 60));
                    }
                  }, child: Text("Load image")),
                  const SizedBox(height: 48),
                ]))
              ]),
            )),
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Center(
                        child: Text(
                      "Signing up",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
                maxCrossAxisExtent: 700,
                child: SliverToBoxAdapter(
                    child: Column(children: [
                  const SizedBox(height: 16),
                  SegmentedButton(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                          label: const Text("App only"),
                          value: "store",
                          enabled: isNew || !wordpressControlled),
                      ButtonSegment(
                          label: const Text("Wordpress"),
                          value: "wordpress",
                          enabled: isNew || wordpressControlled),
                    ],
                    selected: wordpressControlled ? {"wordpress"} : {"store"},
                    onSelectionChanged:
                        // !isNew ? null :
                        (p0) {
                      setState(() {
                        wordpressControlled = p0.contains("wordpress");
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Card(
                      child: Column(children: [
                    ListTile(
                      title: const Text("WordPress controlled"),
                      trailing: Switch(
                          value: wordpressControlled,
                          onChanged: !isNew
                              ? null
                              : (val) {
                                  setState(() {
                                    wordpressControlled = val;
                                  });
                                }),
                    ),
                    const SizedBox(height: 16),
                    if (!wordpressControlled)
                      ListTile(
                          title: TextField(
                        enabled: !wordpressControlled,
                        controller: _signupLinkController,
                        onChanged: onFieldChanged,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Sign-up link (optional)'),
                      )),
                    if (wordpressControlled)
                      Column(children: [
                        if ((widget.originalEvent?.participate.signup
                                    .ticketCount ??
                                1) >
                            1)
                          const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Warning: multiple 'tickets' were attached to this event. "
                                "Limited support is available in the app, "
                                "ask Vincent about the exact behaviour or use the "
                                "WordPress interface instead.",
                                style: TextStyle(color: Colors.red),
                              )),

                        if (widget.originalEvent != null &&
                            widget.originalEvent?.participate.signup.method !=
                                "none" &&
                            (spaces == 0 || !enableSignup))
                          const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Warning: disabling signing up will remove all "
                                "participants, consider changing the register "
                                "deadline instead if you want to disallow new "
                                "signups.",
                                style: TextStyle(color: Colors.red),
                              )),
                        const SizedBox(height: 16),

                        // const SizedBox(height: 16),
                        ListTile(
                          title: const Text("Enable signing up"),
                          trailing: Switch(
                              value: enableSignup,
                              onChanged: (val) {
                                setState(() {
                                  enableSignup = val;
                                  if (val && _spacesController.text.isEmpty) {
                                    _spacesController.text = "40";
                                  }
                                });
                                onFieldsUpdated();
                              }),
                        ),
                        ListTile(
                          subtitle: TextField(
                            enabled: enableSignup,
                            controller: _spacesController,
                            onChanged: onFieldChanged,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Spaces available'),
                          ),
                        ),
                        ListTile(
                          subtitle: TextField(
                            enabled: enableSignup,
                            controller: _registerDeadlineController,
                            onChanged: onFieldChanged,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText:
                                    'Register deadline (e.g. "2024-01-01 00:00:00")'),
                          ),
                        ),
                      ]),
                    const SizedBox(height: 16)
                  ]))
                ]))))

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

        // const SizedBox(
        //   height: 32,
        // ),
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
