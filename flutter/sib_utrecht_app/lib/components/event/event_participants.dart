
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventParticipants extends StatelessWidget {
  final AnnotatedEvent event;
  final List<AnnotatedUser> participants;

  const EventParticipants(this.event, {Key? key, required this.participants})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
          child: ListTile(
              title: Text(
                  "${AppLocalizations.of(context)!.eventParticipants} (${participants.length}):"))),
      if (participants == [])
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Text(
                    AppLocalizations.of(context)!.eventNoParticipantsYet))),
      if (participants.isNotEmpty)
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 32),
            child: Wrap(
                runSpacing: 10,
                spacing: 2,
                children: [
                  ...participants.sortedBy((element) => element.shortNameUnique).map<Widget>((e) =>
                      EntityTile(entity: e)),
                  const SizedBox(height: 32),
                ]))
    ]);
  }
}