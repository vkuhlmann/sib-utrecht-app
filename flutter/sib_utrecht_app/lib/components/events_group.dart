part of '../main.dart';

class EventsGroup extends StatelessWidget {
  const EventsGroup({Key? key, required this.children, required this.title,
    // required this.start, required this.end
  })
      : super(key: key);

  final List<EventsItem> children;
  final String title;
  // final DateTime start;
  // final DateTime end;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      title: Text(title),
      children: children
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


