import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/model/event.dart';

import 'package:sib_utrecht_app/router.dart';

class EventThumbnail extends StatelessWidget {
  final Event event;

  const EventThumbnail(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (_, imageUrl) = event.body!.extractDescriptionAndThumbnail();

    return Card(
        // child: WillPopScope(
        //     onWillPop: () async {
        //       log.info("Received onWillPop");
        //       // Navigator.pop(context);
        //       router.pop();
        //       return false;
        //     },
        child: ListTile(
            title: Text(AppLocalizations.of(context)!.eventImage),
            subtitle: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                child: Builder(builder: (context) {
                  if (imageUrl == null) {
                    return Text(AppLocalizations.of(context)!.eventNoImage);
                  }
                  try {
                    return Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                            onTap: () {
                              router.pushNamed("event_image_dialog",
                                  pathParameters: {
                                    "event_id": event.id.toString()
                                  },
                                  queryParameters: {
                                    "url": imageUrl
                                  });
                            },
                            child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 400, maxHeight: 500),
                                child: Image.network(imageUrl))));

                    // return InteractiveViewer(clipBehavior: Clip.none, child: Image.network("https://sib-utrecht.nl/wp-content/uploads/2022/10/IMG_2588-1536x1024.jpg"));
                  } catch (e) {
                    // try {
                    //   return Text("Error: ${thumbnail["error"]}");
                    // } catch (_) {
                    return Text("Error: $e");
                    // }
                  }
                }))));
  }
}

class ThumbnailImageDialog extends StatelessWidget {
  const ThumbnailImageDialog({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Builder(
            builder: (context) => InteractiveViewer(
                minScale: 0.1,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Container(
                        constraints: const BoxConstraints.expand(),
                        child: GestureDetector(onTap: () => router.pop())),
                    Container(
                        constraints: const BoxConstraints.expand(),
                        child: GestureDetector(
                            onTap: () => router.pop(),
                            child: Padding(
                                padding: const EdgeInsets.all(32),
                                child:
                                    Image.network(url, fit: BoxFit.contain))))
                  ],
                ))));
  }
}

// class EventPromo extends StatelessWidget {
//   final AnnotatedEvent event;

//   const EventPromo(this.event, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Card(
//             child: ListTile(
//                 title: Text(AppLocalizations.of(context)!.eventDescription),
//                 subtitle: buildDescription(context, event))),
//         buildThumbnailCard(context, event),
//       ],
//     );
//   }
// }
