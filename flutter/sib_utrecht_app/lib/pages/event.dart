part of '../main.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.eventId}) : super(key: key);

  final int? eventId;
  // final Map<String, dynamic> details;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  Future<APIConnector>? apiConnector;

  (int, Event)? _cached;
  Future<(int, Event)?> _staging = Future.value(null);
  // late Future<http.Response> _image;

  late Future<List<String>> participants;

  int sequenceId = 0;
  int? _refreshingSequence = null;

  @override
  void initState() {
    super.initState();

    // Uri download_url = Uri.parse("https://sib-utrecht.nl/wp-content/uploads/2022/02/cropped-cropped-cropped-cropped-20210919_135253-scaled-2-1.jpg");

    // _image = http.get(
    //   Uri.parse("http://192.168.50.200/wordpress/wp-content/uploads/"
    //   + "2023/06/cropped-cropped-cropped-cropped-cropped-"
    //   + "20210919_135253-scaled-2-1.jpg"),
    //   // download_url,
    //   headers: {
    //     // "Authorization": "Basic dmluY2VudDpsN3c3IGd4WkEgandXQSAwRE1lIEhEM20gRVg4bg==",
    //     "Origin": "*",
    //     // "X-test": "Hoi"
    //   }
    //   ).then((reponse) {
    //   print("Got response ${reponse.statusCode} with length ${reponse.body.length}");
    //   return reponse;
    // }).onError((error, stackTrace) {
    //   print("Got error $error");
    //   // print("Got error $error");
    //   return http.Response("Error", 500);

    //   // return error;
    // },);
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      log.fine(
          "[EventPage] API connector changed from ${this.apiConnector} to ${apiConnector}");
      this.apiConnector = apiConnector;
      scheduleRefresh();

      setState(() {
        participants = apiConnector.then((conn) =>
            conn.get("events/${widget.eventId}/participants").then((response) {
              return (response["data"]["participants"] as List<dynamic>)
                  .map((e) => e["name"] as String)
                  .toList();
            }));
      });
    }

    super.didChangeDependencies();
  }

  Future<Event?> _loadData() async {
    // return null;
    log.fine("Loading single event data");
    var conn = apiConnector;
    if (conn == null) {
      return null;
    }

    return Event.fromJson((await (await conn)
            .get("events/${widget.eventId}?include_image=true"))["data"]
        ["event"] as Map<String, dynamic>);
  }

  void scheduleRefresh() {
    setState(() {
      log.fine("Refreshing");
      int thisSequence = sequenceId++;
      _refreshingSequence = thisSequence;

      var fut = _loadData().then((value) {
        if (value == null) {
          return null;
        }

        var v = (thisSequence, value);
        setState(() {
          if (thisSequence != _refreshingSequence) {
            log.info(
                "Discarding activity data result: sequence id was $thisSequence, now $_refreshingSequence");
            return;
          }

          _cached = v;
        });

        return v;
      });
      // .onError((e) {
      //   print("Error while loading data: $e");
      //   // popupDialog("Error while loading data: $e");
      // });

      var fut2 = fut.whenComplete(() {
        setState(() {
          if (thisSequence != _refreshingSequence) {
            return;
          }

          _refreshingSequence = null;
          // if (thisSequence > _dirtyStateSequence) {
          //   _dirtyBookState = {};
          // }
        });
      });

      _staging = fut;
    });
  }

  Widget buildThumbnailCard(BuildContext context, Event event) {
    return Card(
        child: ListTile(
            title: const Text("Thumbnail"),
            subtitle: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Builder(builder: (context) {
                  if (event.data["thumbnail"] == null) {
                    return const Text("Geen thumbnail");
                  }
                  try {
                    // return Text(jsonEncode(event.data["thumbnail"]));
                    // return Image.network("$wordpressUrl/wp-content/uploads/" +
                    //     event.data["thumbnail"]["path"] +
                    //     "?width=200")
                    // return Image.network("$wordpressUrl/${event.data["thumbnail"]["url"]}");
                    // return InteractiveViewer(child:
                    //  Image.network("$wordpressUrl/${event.data["thumbnail"]["url"]}")
                    // );

                    // return PhotoView(
                    //   imageProvider: NetworkImage("$wordpressUrl/${event.data["thumbnail"]["url"]}"),
                    // );

                    return InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                    alignment: AlignmentDirectional.center,
                                    // insetPadding: const EdgeInsets.fromLTRB(
                                    //     16, 70, 16, 16),
                                    insetPadding: const EdgeInsets.all(0),
                                    child:
//                                     Stack(alignment: AlignmentDirectional.center,
//                                     children: [
// Container(
//                                       constraints: const BoxConstraints.expand(),
//                                       child: GestureDetector(
//                                       // padding: const EdgeInsets.fromLTRB(
//                                       //     16, 16, 16, 32),
//                                       // width: 200,
//                                       onTap: () => Navigator.pop(context)
//                                       )),
//                                     Center(child: InteractiveViewer(
//                                         clipBehavior: Clip.none,
//                                           child: GestureDetector(
//                                             child: Image.network(
//                                               "$wordpressUrl/${event.data["thumbnail"]["url"]}"))
//                                       ))
//                                     ])
                                        Center(
                                            child: Builder(
                                                builder: (context) =>
                                                    InteractiveViewer(
                                                        // clipBehavior: Clip.none,
                                                        child: Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .center,
                                                      children: [
                                                        Container(
                                                            constraints:
                                                                const BoxConstraints
                                                                    .expand(),
                                                            child:
                                                                GestureDetector(
                                                                    // padding: const EdgeInsets.fromLTRB(
                                                                    //     16, 16, 16, 32),
                                                                    // width: 200,
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                            context))),
                                                        Image.network(
                                                            "$wordpressUrl/${event.data["thumbnail"]["url"]}")
                                                      ],
                                                    )))));
                                // return Dialog(
                                //     alignment: AlignmentDirectional.center,
                                //     // insetPadding: const EdgeInsets.fromLTRB(
                                //     //     16, 70, 16, 16),
                                //     insetPadding: const EdgeInsets.all(0),
                                //     child: Container(
                                //       constraints: const BoxConstraints.expand(),
                                //       child: GestureDetector(
                                //       // padding: const EdgeInsets.fromLTRB(
                                //       //     16, 16, 16, 32),
                                //       // width: 200,
                                //       onTap: () => Navigator.pop(context),
                                //       child: Center(child: InteractiveViewer(
                                //         clipBehavior: Clip.none,
                                //           child: GestureDetector(
                                //             child: Image.network(
                                //               "$wordpressUrl/${event.data["thumbnail"]["url"]}"))))),
                                //     ));
                              });

                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => InteractiveViewer(
                          //             child: Image.network(
                          //                 "$wordpressUrl/${event.data["thumbnail"]["url"]}"))));
                        },
                        child: Container(constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),child: Image.network(
                            "$wordpressUrl/${event.data["thumbnail"]["url"]}")));

                    // return InteractiveViewer(clipBehavior: Clip.none, child: Image.network("https://sib-utrecht.nl/wp-content/uploads/2022/10/IMG_2588-1536x1024.jpg"));
                  } catch (e) {
                    try {
                      return Text("Error: ${event.data["thumbnail"]["error"]}");
                    } catch (_) {
                      return const Text("Error");
                    }
                  }
                }))));
  }

  @override
  Widget build(BuildContext context) {
    print("Building event page for event id ${widget.eventId}");
    return FutureBuilder(
        future: _staging,
        builder: (contextStaging, snapshotStaging) =>
            // ConstrainedBox(
            // constraints: const BoxConstraints.expand(),
            // child:
            Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                // child: ListView(
                //   shrinkWrap: true,
                //   children: const [
                //   Card(child: ListTile(title: const Text("Bestuur"))),
                //   Card(child: ListTile(title: const Text("Commissies"))),
                //   Card(child: ListTile(title: const Text("Sociëteiten"))),
                //   // Expanded(child: Container()),
                //   Spacer(),
                //   Divider(),
                //   Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
                //   Card(child: ListTile(title: const Text("Over SIB"))),
                //   Card(child: ListTile(title: const Text("Over app"))),
                // ])
                child: CustomScrollView(slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    // const Card(child: ListTile(title: Text("Bestuur"))),
                    // const Card(child: ListTile(title: Text("Commissies"))),
                    // const Card(child: ListTile(title: Text("Disputen"))),
                    // Card(
                    //     child: ListTile(
                    //         title: Text("Event id: ${widget.eventId}"))),
                    ...((contextCached) {
                      var data = _cached;
                      if (data == null) {
                        return [];
                      }

                      // return Text(jsonEncode(snapshot.data!["data"]["events"]));
                      var (sequenceId, event) = data;

                      return [
                        Card(child: ListTile(title: Text(event.eventName))),
                        // Card(child: ListTile(title: Text(event.start)))
                        // Card(
                        //     child:
                        //         ListTile(title: Text(event.start.toString()))),
                        Card(
                            child: ListTile(
                                title: Wrap(children: [
                          const SizedBox(width: 80, child: Text("Start: ")),
                          Wrap(children: [
                            SizedBox(
                                width: 260,
                                child: LocaleDateFormat(
                                    date: event.start, format: "yMMMMEEEEd")),
                            // const SizedBox(width: 20),
                            LocaleDateFormat(date: event.start, format: "Hm")
                          ])
                        ]))),
                        Card(
                            child: ListTile(
                                title: Wrap(children: [
                          const SizedBox(width: 80, child: Text("Eindigt: ")),
                          Wrap(children: [
                            SizedBox(
                                width: 260,
                                child: LocaleDateFormat(
                                    date: event.end, format: "yMMMMEEEEd")),
                            // const SizedBox(width: 20),
                            LocaleDateFormat(date: event.end, format: "Hm")
                          ])
                        ]))),
                        // Table(columnWidths: const {
                        //   0: IntrinsicColumnWidth(),
                        //   1: FlexColumnWidth(),
                        //   2: IntrinsicColumnWidth(),
                        //   3: FlexColumnWidth()
                        // }, children: <TableRow>[
                        //   TableRow(children: <Widget>[
                        //     const Text("Start: "),
                        //     LocaleDateFormat(
                        //         date: event.start, format: "yMMMMEEEEd"),
                        //     const SizedBox(width: 30),
                        //     LocaleDateFormat(date: event.start, format: "Hm")
                        //   ]),
                        //   TableRow(children: <Widget>[
                        //     const Text("Eindigt: "),
                        //     LocaleDateFormat(
                        //         date: event.end, format: "yMMMMEEEEd"),
                        //     const SizedBox(width: 30),
                        //     LocaleDateFormat(date: event.end, format: "Hm")
                        //   ])
                        // ]),
                        Card(
                            child: ListTile(
                                title: const Text("Beschrijving"),
                                subtitle: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 16, 8, 16),
                                    child: HtmlWidget(
                                        event.data["post_content"] ?? "")))),

                        buildThumbnailCard(context, event),
                        // Card(child:
                        // FutureBuilder(future: _image, builder: (context, snapshot) {
                        //   if (snapshot.hasData) {
                        //     return Image.memory(snapshot.data!.bodyBytes);
                        //   } else {
                        //     return const Text("Loading...");
                        //   }
                        // })),
                        // ListTile(title: const Text("aa")),)
                      ];

                      // FutureBuilder(
                      //   future: dateFormattingInitialization,
                      //   builder: (context, snapshot) {
                      //     if (snapshot.hasData) {
                      //       return Text(
                      //     DateFormat("yMMMMEEEEd", Preferences.of(context).locale)
                      //             .format(event.start));
                      //     } else {
                      //       return Text(event.start.toString());
                      //     }
                      //   }
                      // )

                      // return Column(
                      //     children: events
                      //         .map<Widget>((e) => ActivityView(
                      //             key: ValueKey(e["event_id"]),
                      //             activity: e,
                      //             isParticipating: bookedEvents.contains(e["event_id"]),
                      //             isDirty: _dirtyBookState.contains(e["event_id"]),
                      //             setParticipating: (value) =>
                      //                 scheduleEventRegistration(e["event_id"], value)))
                      //         .toList());

                      // return _buildActivities(snapshot.data!);
                      // if (snapshotStaging.hasError) {
                      // return Text(jsonEncode(snapshotCached.data));
                      // }

                      // return const CircularProgressIndicator();
                    }(contextStaging)),

                    // if (snapshot.hasData) {
                    //   return Text(jsonEncode(snapshot.data));
                    // } else
                    (_refreshingSequence != null)
                        ? const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()))
                        : ((snapshotStaging.hasError)
                            ? Text("${snapshotStaging.error}")
                            : const SizedBox()),

                    const SizedBox(height: 32),
                    const Card(child: ListTile(title: Text("Participants:"))),
                  ])),
                  // const SliverFillRemaining(
                  //   hasScrollBody: false,
                  //   child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  //   child:
                  //   Column(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       Divider(),
                  //       Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
                  //       Card(child: ListTile(title: const Text("Over SIB"))),
                  //       Card(child: ListTile(title: const Text("Over app"))),
                  //     ]
                  //   )
                  //   )
                  // )
                  FutureBuilder(
                      future: participants,
                      builder: (context, snapshot) =>
                          // return
                          SliverList(
                              delegate: SliverChildListDelegate(
                                  //   [const Text("AAA"), const Text("BBB")]
                                  // ),);
                                  // const Text(
                                  //   "Hoi"
                                  // )
                                  [
                                if (snapshot.hasError)
                                  Text(
                                      "Error loading participants: ${snapshot.error}"),
                                if (!snapshot.hasError && !snapshot.hasData)
                                  const Center(
                                      child: CircularProgressIndicator()),
                                if (snapshot.hasData)
                                  ...snapshot.data!.map<Widget>((e) => Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          32, 0, 0, 0),
                                      child: Card(
                                          child: ListTile(
                                        title: Text(e),
                                      )))),

                                const SizedBox(height: 32),
                              ]

                                  // if (!snapshot.hasData || true) {
                                  //   return const CircularProgressIndicator();
                                  // }

                                  // return SliverList(
                                  //     delegate: SliverChildListDelegate(
                                  //       snapshot.data!.map<Widget>((e) => Card(
                                  //                 child: ListTile(
                                  //               title: Text(e),
                                  //             )))
                                  //         .toList()));
                                  )))
                ])
                // )
                ));
  }
}
