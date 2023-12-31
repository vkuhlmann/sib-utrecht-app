import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:sib_utrecht_app/components/event/event_tile2.dart';
import 'package:sib_utrecht_app/components/event/event_week.dart';

import '../../utils.dart';
import '../../view_model/event/annotated_event.dart';

import '../../pages/events.dart';

class EventsGroup extends StatelessWidget {
  final bool initiallyExpanded;
  final bool isMajor;
  final bool isMultiWeek;

  const EventsGroup({
    Key? key, required this.children, required this.title,
    required this.initiallyExpanded,
    required this.isMajor,
    required this.isMultiWeek
    // required this.start, required this.end
  })
      : super(key: key);

  
  // static Widget buildItem(AnnotatedEvent event) {
  //   return EventTile2(
  //       key: ValueKey(("eventsItem", event.id, event.placement?.date)),
  //       event: event);
  // }

  final List<AnnotatedEvent> children;
  final String title;
  // final DateTime? start;
  // final DateTime? end;
  // final bool demark

  Iterable<Widget> getChildrenWeekDivided() sync* {
    var division = groupBy(children, (p0) => formatWeekNumber(p0.placement?.date ?? p0.start))
    .entries.sorted((a, b) => a.key.compareTo(b.key));

    for (var entry in division) {
      String? weekTitle;
      if (isMultiWeek) {
        // weekTitle = "Week ${entry.key}";
        weekTitle = "Week ${int.parse(entry.key.substring(6))}";
      }

      yield EventWeek(weekTitle: weekTitle, events: entry.value);

      // for (var v in entry.value.sortedBy((element) => element.placement?.date ?? element.start)) {
      //   // if (v.participation == null) {
      //   //   yield EventOngoing(event: v, );
      //   //   continue;
      //   // }
      //   // yield EventTile(event: v);

      //   yield buildItem(v);
      // }

      if (entry.key != division.last.key) {
        yield const SizedBox(height: 40);
        yield const Divider(thickness: 2,);
        yield const SizedBox(height: 20);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (start != null && end != null) {
    //   // a = children.where((element) => element.event.start.isAfter(start!) && element.event.start.isBefore(end!)).toList();
    // }

    // return Column(children: [ListTile(
    //     // onTap: _handleTap,
    //     // contentPadding: widget.tilePadding ?? expansionTileTheme.tilePadding,
    //     // leading: widget.leading ?? _buildLeadingIcon(context),
    //     title: Text(title),
    //     // subtitle: widget.subtitle,
    //     // trailing: widget.trailing ?? _buildTrailingIcon(context),
    //   ),
    //   ...getChildrenWeekDivided().toList()
    //   ]);

    // Color dividerColor = Theme.of(context).colorScheme.secondary;
    Color? headlineColor;
    Color dividerColor = Theme.of(context).colorScheme.primary;

    dividerColor = Theme.of(context).textTheme.headlineSmall?.color
    ?? dividerColor;

    if (!isMajor) {
      headlineColor = Theme.of(context).colorScheme.secondary;
      dividerColor = headlineColor.withOpacity(0.5);

      // dividerColor = Theme.of(context).colorScheme.secondaryContainer;
      // dividerColor = Theme.of(context).colorScheme.secondary;
      // headlineColor = dividerColor
      // dividerColor = dividerColor.withOpacity(0.9);
    }

    return Column(
      key: ValueKey((key, title)),
      children: [
        const SizedBox(height: 32),

        // BEGIN Based on: https://stackoverflow.com/questions/54058228/horizontal-divider-with-text-in-the-middle-in-flutter
        // answer by https://stackoverflow.com/users/10826159/jerome-escalante
        Row(
            children: <Widget>[
                const SizedBox(width: 8),
                Expanded(
                    child: Divider(color: dividerColor, thickness: isMajor ? 2 : 1.5)
                ),
                const SizedBox(width: 16,),
                Text(title, style: 
                // isMajor ?
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  // color: isMajor ? null : dividerColor
                  // color: dividerColor
                  color: headlineColor
                )
                // :
                // Theme.of(context).textTheme.titleSmall
                ),
                const SizedBox(width: 16,),
                Expanded(
                    child: Divider(color: dividerColor, thickness: isMajor ? 2 : 1.5)
                ),
                const SizedBox(width: 8)
            ]
        ),
      ...getChildrenWeekDivided().toList(),
      const SizedBox(height: 16)
    ]);

    // return ExpansionTile(
    //   key: ValueKey((key, title)),
    //   // initiallyExpanded: true,
    //   initiallyExpanded: initiallyExpanded,
    //   title: Text(title),
    //   // children: children
    //   children: [
    //     ...getChildrenWeekDivided().toList(),
    //     const SizedBox(height: 16)
    //   ]
    // );

    // return ExpansionTile(
    //     initiallyExpanded: true,
    //   title: Text(title), children:
    // children
    // // [
    // //   for (var event in events)

    // //     // ListTile(
    // //     //   title: Text(event.title),
    // //     //   subtitle: Text(event.description),
    // //     //   onTap: () {
    // //     //     router.go("/event/${event.id}");
    // //     //   },
    // //     // )
    // // ]
    // );
  }
}


