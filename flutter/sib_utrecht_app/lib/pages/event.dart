part of '../main.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.eventId}) : super(key: key);

  final int? eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

// class PromoImageView<T> extends Page<T> {
//   const PromoImageView({Key? key, required this.url}) : super(key: key);
// }

class ThumbnailImageDialog extends StatelessWidget {
  const ThumbnailImageDialog({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    // return DialogPage(
    //     builder: (_) => Center(
    //           child: Image.network(url),
    //         ));

    return
        // Dialog(
        //     alignment: AlignmentDirectional.center,
        //     // insetPadding: const EdgeInsets.fromLTRB(
        //     //     16, 70, 16, 16),
        //     insetPadding: const EdgeInsets.all(0),
        //     child:
        //   Stack(alignment: AlignmentDirectional.center,
        //   children: [
        //  Container(
        //     constraints: const BoxConstraints.expand(),
        //     child: GestureDetector(
        //     // padding: const EdgeInsets.fromLTRB(
        //     //     16, 16, 16, 32),
        //     // width: 200,
        //     onTap: () => Navigator.pop(context)
        //     )),
        //   Center(child: InteractiveViewer(
        //       clipBehavior: Clip.none,
        //         child: GestureDetector(
        //           child: Image.network(
        //             "$wordpressUrl/${event.data["thumbnail"]["url"]}"))
        //     ))
        //   ])
        Center(
            child: Builder(
                builder: (context) => InteractiveViewer(
                    minScale: 0.1,
                    // clipBehavior: Clip.none,
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                            constraints: const BoxConstraints.expand(),
                            child: GestureDetector(
                                // padding: const EdgeInsets.fromLTRB(
                                //     16, 16, 16, 32),
                                // width: 200,
                                onTap: () => Navigator.pop(context))),
                        Container(
                            constraints: const BoxConstraints.expand(),
                            child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Image.network(url,
                                        fit: BoxFit.contain))))
                      ],
                    ))));
  }
}

class _EventPageState extends State<EventPage> {
  Future<APIConnector>? apiConnector;

  late CachedProvider<Event, Map> _eventProvider;
  late CachedProvider<List<String>, Map> _participantsProvider;

  late void Function() listener;
  @override
  void initState() {
    super.initState();

    _eventProvider = CachedProvider<Event, Map>(
        getCached: (c) => c.then((conn) =>
            conn?.getCached("events/${widget.eventId}?include_image=true")),
        getFresh: (c) => c.get("events/${widget.eventId}?include_image=true"),
        postProcess: (response) => Event.fromJson(
            (response["data"]["event"] as Map)
                .map<String, dynamic>((key, value) => MapEntry(key, value))));

    _participantsProvider = CachedProvider<List<String>, Map>(
        getCached: (c) => c.then(
            (conn) => conn?.getCached("events/${widget.eventId}/participants")),
        getFresh: (c) => c.get("events/${widget.eventId}/participants"),
        postProcess: (response) =>
            (response["data"]["participants"] as Iterable<dynamic>)
                .map((e) => e["name"] as String)
                .toList());

    listener = () {
      log.fine("[EventPage] Doing setState from listener");
      setState(() {});
    };

    _eventProvider.addListener(listener);
    _participantsProvider.addListener(listener);

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
  void dispose() {
    _eventProvider.removeListener(listener);
    _participantsProvider.removeListener(listener);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (this.apiConnector != apiConnector) {
      log.fine(
          "[EventPage] API connector changed from ${this.apiConnector} to $apiConnector");
      this.apiConnector = apiConnector;
      _eventProvider.setConnector(apiConnector);
      _participantsProvider.setConnector(apiConnector);
    }

    super.didChangeDependencies();
  }

  (String?, Map?) extractDescriptionAndThumbnail(Event event) {
    String description = ((event.data["post_content"] ?? event.data["description"] ?? "") as String)
        .replaceAll("\r\n\r\n", "<br/><br/>");
    Map? thumbnail = event.data["thumbnail"];

    if (thumbnail != null &&
        thumbnail["url"] != null &&
        !(thumbnail["url"] as String).startsWith("http")) {
      thumbnail["url"] = "$wordpressUrl/${thumbnail["url"]}";
    }

    if (thumbnail == null && description.contains("<img")) {
      final img = RegExp("<img[^>]+src=\"(?<url>[^\"]+)\"[^>]*>")
          .firstMatch(description);

      if (img != null) {
        thumbnail = {"url": img.namedGroup("url")};
        // description = description.replaceAll(img.group(0)!, "");
        description = description.replaceFirst(img.group(0)!, "");
      }
    }

    if (thumbnail != null &&
        thumbnail["url"] != null &&
        (thumbnail["url"] as String).startsWith("http://sib-utrecht.nl/")) {
      thumbnail["url"] = (thumbnail["url"] as String)
          .replaceFirst("http://sib-utrecht.nl/", "https://sib-utrecht.nl/");
    }

    description = description.replaceAll(
        RegExp("^(\r|\n|<br */>|<br *>)*", multiLine: false), "");

    return (description.isEmpty ? null : description, thumbnail);
  }

  Widget buildDescription(BuildContext context, Event event) {
    // return const SizedBox();

    final (description, _) = extractDescriptionAndThumbnail(event);

    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: HtmlWidget(
          // ((event.data["post_content"] ?? "") as String).replaceAll("\r\n\r\n", "<br/><br/>"),
          description ?? "",
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ));
  }

  Widget openThumbnailView(BuildContext context, Map thumbnail) {
    return ThumbnailImageDialog(url: thumbnail["url"] as String);
    // return Dialog(
    //     alignment: AlignmentDirectional.center,
    //     // insetPadding: const EdgeInsets.fromLTRB(
    //     //     16, 70, 16, 16),
    //     insetPadding: const EdgeInsets.all(0),
    //     child:
    //         //   Stack(alignment: AlignmentDirectional.center,
    //         //   children: [
    //         //  Container(
    //         //     constraints: const BoxConstraints.expand(),
    //         //     child: GestureDetector(
    //         //     // padding: const EdgeInsets.fromLTRB(
    //         //     //     16, 16, 16, 32),
    //         //     // width: 200,
    //         //     onTap: () => Navigator.pop(context)
    //         //     )),
    //         //   Center(child: InteractiveViewer(
    //         //       clipBehavior: Clip.none,
    //         //         child: GestureDetector(
    //         //           child: Image.network(
    //         //             "$wordpressUrl/${event.data["thumbnail"]["url"]}"))
    //         //     ))
    //         //   ])
    //         Center(
    //             child: Builder(
    //                 builder: (context) => InteractiveViewer(
    //                         // clipBehavior: Clip.none,
    //                         child: Stack(
    //                       alignment: AlignmentDirectional.center,
    //                       children: [
    //                         Container(
    //                             constraints: const BoxConstraints.expand(),
    //                             child: GestureDetector(
    //                                 // padding: const EdgeInsets.fromLTRB(
    //                                 //     16, 16, 16, 32),
    //                                 // width: 200,
    //                                 onTap: () => Navigator.pop(context))),
    //                         GestureDetector(
    //                             onTap: () => Navigator.pop(context),
    //                             child: Image.network(thumbnail["url"]))
    //                       ],
    //                     )))));
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
  }

  Widget buildThumbnailCard(BuildContext context, Event event) {
    final (_, thumbnail) = extractDescriptionAndThumbnail(event);

    return Card(
        child: WillPopScope(
            onWillPop: () async {
              log.info("Received onWillPop");
              Navigator.pop(context);
              return false;
            },
            child: ListTile(
                title: Text(AppLocalizations.of(context)!.eventImage),
                subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                    child: Builder(builder: (context) {
                      if (thumbnail == null) {
                        return Text(AppLocalizations.of(context)!.eventNoImage);
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

                        return Center(
                            child: InkWell(
                                onTap: () {
                                  // showDialog(
                                  //     context: context,
                                  //     builder: (BuildContext context) {
                                  //       return openThumbnailView(
                                  //           context, thumbnail);
                                  //     });
                                  // router.push(GoRouterState.of(context).matchedLocation + "#");
                                  // router.push("/#/event/96#");

                                  // router.push("/event/96/image", extra: {"url": thumbnail["url"]});
                                  router.pushNamed("event_image_dialog",
                                      pathParameters: {
                                        "event_id": widget.eventId.toString()
                                      },
                                      queryParameters: {
                                        "url": thumbnail["url"]
                                      });
                                  return;

                                  final CapturedThemes themes =
                                      InheritedTheme.capture(
                                    from: context,
                                    to: Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).context,
                                  );

                                  // GoRouterState.of(context)
                                  //     .push(DialogRoute(
                                  //   context: context,
                                  //   builder: (context) =>
                                  //       openThumbnailView(context, thumbnail),
                                  //   themes: themes,
                                  //   traversalEdgeBehavior:
                                  //       TraversalEdgeBehavior.closedLoop,
                                  // ));

                                  // Navigator.of(context, rootNavigator: true)
                                  //     .push(DialogRoute(
                                  //   context: context,
                                  //   builder: (context) =>
                                  //       openThumbnailView(context, thumbnail),
                                  //   themes: themes,
                                  //   traversalEdgeBehavior:
                                  //       TraversalEdgeBehavior.closedLoop,
                                  // ));

                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => InteractiveViewer(
                                  //             child: Image.network(
                                  //                 "$wordpressUrl/${event.data["thumbnail"]["url"]}"))));
                                },
                                child: Container(
                                    constraints: const BoxConstraints(
                                        maxWidth: 400, maxHeight: 500),
                                    child: Image.network(thumbnail["url"]))));

                        // return InteractiveViewer(clipBehavior: Clip.none, child: Image.network("https://sib-utrecht.nl/wp-content/uploads/2022/10/IMG_2588-1536x1024.jpg"));
                      } catch (e) {
                        try {
                          return Text("Error: ${thumbnail["error"]}");
                        } catch (_) {
                          return const Text("Error");
                        }
                      }
                    })))));
  }

  @override
  Widget build(BuildContext context) {
    log.fine("Building event page for event id ${widget.eventId}");
    bool expectParticipants = false;

    Event? event = _eventProvider.cached;

    if (event != null) {
      var signupType = event.signupType;

      if (signupType == "api") {
        expectParticipants = true;
      }
    }

    var cachedParticipants = _participantsProvider.cached;

    if (cachedParticipants != null && cachedParticipants.isNotEmpty) {
      expectParticipants = true;
    }

    return Column(children: [
      Expanded(
          child: SelectionArea(
              child: CustomScrollView(slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              const SizedBox(height: 20),
              if (_eventProvider.cached == null)
                FutureBuilderPatched(
                    future: _eventProvider.loading,
                    builder: (eventContext, eventSnapshot) {
                      if (eventSnapshot.hasError) {
                        // return Text("${eventSnapshot.error}");
                        return Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                                child: formatError(eventSnapshot.error)));
                      }
                      if (eventSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()));
                      }

                      return const SizedBox();
                    }),
              ...(() {
                final Event? event = _eventProvider.cached;
                if (event == null) {
                  return [];
                }
                var eventEnd = event.end;
                var location = event.location;

                return [
                  Row(children: [
                    // Expanded(
                    //     child: Card(
                    //         child: ListTile(title: Text(event.eventName)))),
                    Expanded(
                        child: Card(
                            child: ListTile(title: Text(event.getLocalEventName(context))))),
                    // SignupIndicator(event: event),
                    IconButton(
                        onPressed: () {
                          router.goNamed("event_edit", pathParameters: {
                            "event_id": widget.eventId.toString()
                          });
                        },
                        icon: const Icon(Icons.edit))
                  ]),
                  if (location != null)
                    Card(child: ListTile(title: Text("Location: $location"))),
                  // Card(child: ListTile(title: Text("your (student) room. \ud83e\ude84\ud83c\udfa8\r\n\r\nWe will"))),
                  Card(
                      child: ListTile(
                          title: Wrap(children: [
                    SizedBox(
                        width: 80,
                        child: Text(
                            "${AppLocalizations.of(context)!.eventStarts}: ")),
                    Wrap(children: [
                      SizedBox(
                          width: 260,
                          child: LocaleDateFormat(
                              date: event.start, format: "yMMMMEEEEd")),
                      // const SizedBox(width: 20),
                      LocaleDateFormat(date: event.start, format: "Hm")
                    ])
                  ]))),
                  if (eventEnd != null)
                    Card(
                        child: ListTile(
                            title: Wrap(children: [
                      SizedBox(
                          width: 80,
                          child: Text(
                              "${AppLocalizations.of(context)!.eventEnds}: ")),
                      Wrap(children: [
                        SizedBox(
                            width: 260,
                            child: LocaleDateFormat(
                                date: eventEnd, format: "yMMMMEEEEd")),
                        // const SizedBox(width: 20),
                        LocaleDateFormat(date: eventEnd, format: "Hm")
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
                          title: Text(
                              AppLocalizations.of(context)!.eventDescription),
                          subtitle: buildDescription(context, event))),

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
              }()),
              const SizedBox(height: 32),
              if (expectParticipants)
              Card(
                  child: ListTile(
                      title: Text(
                          "${AppLocalizations.of(context)!.eventParticipants} (${_participantsProvider.cached?.length ?? 'n/a'}):"))),
            ]))),
        if (expectParticipants)
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              if (_participantsProvider.cached == null)
                FutureBuilderPatched(
                    future: _participantsProvider.loading,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(child: formatError(snapshot.error)));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return const SizedBox();
                    }),
              ...(_participantsProvider.cached ?? []).map<Widget>((e) =>
                  Padding(
                      padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                      child: Card(child: ListTile(title: Text(e))))),
              const SizedBox(height: 32),
            ])))
      ]))),
      AlertsPanel(loadingFutures: [
        (
          "details",
          _eventProvider.loading,
          {"isRefreshing": _eventProvider.cached != null}
        ),
        if (expectParticipants)
        (
          "participants",
          _participantsProvider.loading,
          {"isRefreshing": _participantsProvider.cached != null}
        )
      ])
    ]);
  }
}
