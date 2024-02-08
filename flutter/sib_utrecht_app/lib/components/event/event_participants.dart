
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:sib_utrecht_app/view_model/event/annotated_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventParticipants extends StatelessWidget {
  final AnnotatedEvent event;
  final List<AnnotatedUser> participants;

  const EventParticipants(this.event, {super.key, required this.participants});

  @override
  Widget build(BuildContext context) {
    log.fine("Building EventParticipants");

    final loc = AppLocalizations.of(context);
    if (loc == null) {
      throw Exception("No localization found");
    }

    return Column(children: [
      Card(
          child: ListTile(
              title: Text(
                  "${loc.eventParticipants} (${participants.length}):"))),
      if (participants == [])
        Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
                child: Text(
                    loc.eventNoParticipantsYet))),
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