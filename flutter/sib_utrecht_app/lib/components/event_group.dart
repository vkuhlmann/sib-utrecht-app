part of '../main.dart';

class EventsGroup extends StatelessWidget {
  const EventsGroup({Key? key, required this.children, required this.title,
    // required this.start, required this.end
  })
      : super(key: key);

  final List<AnnotatedEvent> children;
  final String title;
  // final DateTime? start;
  // final DateTime? end;
  // final bool demark

  Iterable<Widget> getChildrenWeekDivided() sync* {
    var division = groupBy(children, (p0) => formatWeekNumber(p0.event.start))
    .entries.sorted((a, b) => a.key.compareTo(b.key));
    
    // division.entries.sorted((a, b) => a.key.compareTo(b.key)).map((e) => )

    for (var entry in division) {
      for (var v in entry.value.sortedBy((element) => element.event.start)) {
        yield v;
      }
      yield Divider(key: ValueKey(("divider", entry.key)));
    }
  }

  @override
  Widget build(BuildContext context) {
    var a = children;
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

    return ExpansionTile(
      key: ValueKey((key, title)),
      initiallyExpanded: true,
      title: Text(title),
      // children: children
      children: getChildrenWeekDivided().toList()
    );

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


