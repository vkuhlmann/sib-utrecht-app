import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_provider_notifier.dart';

import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/router.dart';


class EventThumbnail extends StatelessWidget {
  final AnnotatedEvent event;

  const EventThumbnail(this.event, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final (_, thumbnail) = event.extractDescriptionAndThumbnail();

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
                        return Center(
                            child: InkWell(
                                onTap: () {
                                  router.pushNamed("event_image_dialog",
                                      pathParameters: {
                                        "event_id": event.eventId.toString()
                                      },
                                      queryParameters: {
                                        "url": thumbnail["url"]
                                      });
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
                        child: GestureDetector(
                            onTap: () => Navigator.pop(context))),
                    Container(
                        constraints: const BoxConstraints.expand(),
                        child: GestureDetector(
                            onTap: () => Navigator.pop(context),
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
