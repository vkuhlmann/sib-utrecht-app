
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:sib_utrecht_app/view_model/event/event_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventParticipants extends StatelessWidget {
  final AnnotatedEvent event;
  final EventProvider eventProvider;

  const EventParticipants(this.event, {Key? key, required this.eventProvider})
      : super(key: key);

  // Widget buildParticipant(BuildContext context, AnnotatedUser participant) {
  //   return EntityTile(entity: participant);
  //   // return Card(
  //   //     child: ListTile(
  //   //         title: Text(participant.user.name),
  //   //         subtitle: Text(participant.user.email)));
  // }

  @override
  Widget build(BuildContext context) {
    // return SliverPadding(
    //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
    //     sliver: SliverList(
    //         delegate: SliverChildListDelegate([

    var participantsCached = event.participants;

    return Column(children: [
      Card(
          child: ListTile(
              title: Text(
                  "${AppLocalizations.of(context)!.eventParticipants} (${eventProvider.participants.cached?.length ?? 'n/a'}):"))),
      if (participantsCached == null)
        FutureBuilderPatched(
            future: eventProvider.participants.loading,
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
      if (participantsCached == [])
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Text(
                    AppLocalizations.of(context)!.eventNoParticipantsYet))),
      if (participantsCached != null && participantsCached.isNotEmpty)
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 32),
            child: Wrap(
                // crossAxisCount: 6,
                // shrinkWrap: true,
                runSpacing: 10,
                spacing: 2,
                children: [
                  ...participantsCached.sortedBy((element) => element.shortNameUnique).map<Widget>((e) =>
                      // Padding(
                      //       padding: const EdgeInsets.fromLTRB(32, 0, 0, 0),
                      // child:
                      //Card(child: ListTile(title: Text(e)))
                      // Card(child:
                      SizedBox(
                          width: 90, height: 100, child: 
                          Container(
                            // color: Colors.black,
                            child: EntityTile(entity: e)))),
                  const SizedBox(height: 32),
                ]))
    ]);
  }
}