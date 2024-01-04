import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/event/calendar.dart';
import 'package:sib_utrecht_app/components/event/event_week.dart';
import 'package:sib_utrecht_app/components/flutter_sticky_header-0.6.5/lib/flutter_sticky_header.dart';
import 'package:sib_utrecht_app/week.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../view_model/event/annotated_event.dart';

typedef WeekBuilder = Widget Function(
    {required Week week, required List<AnnotatedEvent> events});

Widget EventGroup(
        {Key? key,
        required Widget sliver,
        required String title,
        required bool isMajor}) =>
    SliverStickyHeader.builder(
        builder: (context, state) =>
            SolidHeader(title: title, isMajor: isMajor),
        sliver: SliverCrossAxisConstrained(
            maxCrossAxisExtent: 700,
            child: SliverPadding(
                padding: const EdgeInsets.only(top: 40), sliver: sliver)));

Widget EventMonth({
  Key? key,
  required List<MapEntry<Week, List<AnnotatedEvent>>> children,
  required String title,
  required bool initiallyExpanded,
  required bool isMajor,
  required Month month,
  WeekBuilder? weekBuilder,
  // required bool isMultiWeek,
  // required bool divideEvents,
  // required List<Week> weeks,
  // required this.start, required this.end
}) {
  return
      // MultiSliver(
      //   key: ValueKey((key, title)),
      //   children: [

      //   ]);
      EventGroup(
          title: title,
          isMajor: isMajor,
          sliver: SliverToBoxAdapter(
              child: Column(children: [
                const SizedBox(height: 16),
                Calendar(month: month, events: children),
                const SizedBox(height: 16),
                const Divider(thickness: 5),
                const SizedBox(height: 32),
                EventMonthContent(
            children: children,
            // title: title,
            initiallyExpanded: initiallyExpanded,
            isMajor: isMajor,
            isMultiWeek: true,
            buildWeek: weekBuilder ?? EventWeek.new,
            // weeks: weeks,
            // divideEvents: divideEvents
          )])));
}

class SolidHeader extends StatelessWidget {
  final String title;
  final bool isMajor;

  const SolidHeader({Key? key, required this.title, required this.isMajor})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Center(
              child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ))));
}

class FancyHeader extends StatelessWidget {
  final String title;
  final bool isMajor;

  const FancyHeader({Key? key, required this.title, required this.isMajor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color? headlineColor;
    Color dividerColor = Theme.of(context).colorScheme.primary;

    dividerColor =
        Theme.of(context).textTheme.headlineSmall?.color ?? dividerColor;

    if (!isMajor) {
      headlineColor = Theme.of(context).colorScheme.secondary;
      dividerColor = headlineColor.withOpacity(0.5);

      // dividerColor = Theme.of(context).colorScheme.secondaryContainer;
      // dividerColor = Theme.of(context).colorScheme.secondary;
      // headlineColor = dividerColor
      // dividerColor = dividerColor.withOpacity(0.9);
    }

    return
        // BEGIN Based on: https://stackoverflow.com/questions/54058228/horizontal-divider-with-text-in-the-middle-in-flutter
        // answer by https://stackoverflow.com/users/10826159/jerome-escalante
        Row(children: <Widget>[
      const SizedBox(width: 8),
      Expanded(
          child: Divider(color: dividerColor, thickness: isMajor ? 2 : 1.5)),
      const SizedBox(
        width: 16,
      ),
      Text(title,
          style:
              // isMajor ?
              Theme.of(context).textTheme.headlineSmall?.copyWith(
                  // color: isMajor ? null : dividerColor
                  // color: dividerColor
                  color: headlineColor)
          // :
          // Theme.of(context).textTheme.titleSmall
          ),
      const SizedBox(
        width: 16,
      ),
      Expanded(
          child: Divider(color: dividerColor, thickness: isMajor ? 2 : 1.5)),
      const SizedBox(width: 8)
    ]);
  }
}

class EventMonthContent extends StatelessWidget {
  final bool initiallyExpanded;
  final bool isMajor;
  final bool isMultiWeek;
  // final bool divideEvents;
  // final List<Week> weeks;

  final WeekBuilder buildWeek;

  const EventMonthContent(
      {Key? key,
      required this.children,
      required this.initiallyExpanded,
      required this.isMajor,
      required this.isMultiWeek,
      this.buildWeek = EventWeek.new
      // required this.divideEvents,
      // required this.weeks
      // required this.start, required this.end
      })
      : super(key: key);

  // static Widget defaultBuildWeek = EventWeek;

  // static Widget buildItem(AnnotatedEvent event) {
  //   return EventTile2(
  //       key: ValueKey(("eventsItem", event.id, event.placement?.date)),
  //       event: event);
  // }

  final List<MapEntry<Week, List<AnnotatedEvent>>> children;
  // final DateTime? start;
  // final DateTime? end;
  // final bool demark

  Iterable<Widget> getChildrenWeekDivided() sync* {
    // var grouped = groupBy(
    //     children, (p0) => Week.fromDate(p0.placement?.date ?? p0.start));
    // for (var l in weeks) {
    //   // grouped.putIfAbsent(l, () => []);
    //   grouped[l] ??= [];
    // }

    // var division = grouped.entries.sorted((a, b) => a.key.compareTo(b.key));
    // final division = children;

    for (var entry in children) {
      if (isMultiWeek) {
        yield const SizedBox(height: 20);
      }

      // String? weekTitle;
      // if (isMultiWeek) {
      //   // weekTitle = "Week ${entry.key}";
      //   weekTitle = "Week ${entry.key.weekNum}";
      // }

      yield KeyedSubtree(
          key: ValueKey(entry.key),
          child: buildWeek(week: entry.key, events: entry.value));

      // yield EventWeekCore(
      //     key: ValueKey(entry.key), week: entry.key, events: entry.value);

      // for (var v in entry.value.sortedBy((element) => element.placement?.date ?? element.start)) {
      //   // if (v.participation == null) {
      //   //   yield EventOngoing(event: v, );
      //   //   continue;
      //   // }
      //   // yield EventTile(event: v);

      //   yield buildItem(v);
      // }

      if (entry.key != children.last.key || true) {
        yield const SizedBox(height: 40);
        yield const Divider(
          thickness: 2,
        );
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

    return Column(children: [
      // const SizedBox(height: 32),
      // FancyHeader(title: title, isMajor: isMajor),
      // const SizedBox(height: 16),
      // if (divideEvents)
      ...getChildrenWeekDivided().toList(),
      // else
      //   for (var event in children)
      //     EventTile2(
      //         key: ValueKey(("eventsItem", event.id, event.placement?.date)),
      //         event: event),
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
