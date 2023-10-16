part of '../main.dart';

class EventsGroup extends StatelessWidget {
  final bool initiallyExpanded;

  const EventsGroup({Key? key, required this.children, required this.title,
    required this.initiallyExpanded,
    // required this.start, required this.end
  })
      : super(key: key);

  final List<AnnotatedEvent> children;
  final String title;
  // final DateTime? start;
  // final DateTime? end;
  // final bool demark

  Iterable<Widget> getChildrenWeekDivided() sync* {
    var division = groupBy(children, (p0) => formatWeekNumber(p0.placement?.date ?? p0.start))
    .entries.sorted((a, b) => a.key.compareTo(b.key));
    
    // division.entries.sorted((a, b) => a.key.compareTo(b.key)).map((e) => )

    String currentWeek = formatWeekNumber(DateTime.now());
    String upcomingWeek = formatWeekNumber(DateTime.now().add(const Duration(days: 3)));

    for (var entry in division) {
      String weekNumber = entry.key;

      if (weekNumber == upcomingWeek) {
        String text = (weekNumber == currentWeek) ? "This week" : "Upcoming week";
        yield const SizedBox(height: 64);

        // BEGIN Based on: https://stackoverflow.com/questions/54058228/horizontal-divider-with-text-in-the-middle-in-flutter
        // answer by https://stackoverflow.com/users/10826159/jerome-escalante
        yield Builder(builder: (context) =>
        Row(
            children: <Widget>[
                Expanded(
                    child: Divider(color: Theme.of(context).colorScheme.secondary, thickness: 2)
                ),
                const SizedBox(width: 16,),
                Text(text, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(width: 16,),
                Expanded(
                    child: Divider(color: Theme.of(context).colorScheme.secondary, thickness: 2)
                ),
            ]
        ));
        // END Based on


        // yield Divider(color: Colors.red[700], thickness: 3);
        // if (weekNumber == currentWeek) {
        //   yield Builder(builder: (context) => 
        //   ListTile(title: Text("This week", style: Theme.of(context).textTheme.headlineSmall?.copyWith())));
        //   yield const SizedBox(height: 16);  
        // } else {
        //   yield const ListTile(title: Text("Upcoming week"));
        // }
      }

      for (var v in entry.value.sortedBy((element) => element.placement?.date ?? element.start)) {
        // if (v.participation == null) {
        //   yield EventOngoing(event: v, );
        //   continue;
        // }
        // yield EventTile(event: v);

        yield EventsPage.buildItem(v);
      }

      if (entry.key != division.last.key) {
        yield const SizedBox(height: 8);
        yield Divider(key: ValueKey(("divider", entry.key)));
        yield const SizedBox(height: 8);
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

    return ExpansionTile(
      key: ValueKey((key, title)),
      // initiallyExpanded: true,
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      // children: children
      children: [
        ...getChildrenWeekDivided().toList(),
        const SizedBox(height: 16)
      ]
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


