part of '../main.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key, required this.eventId}) : super(key: key);

  final int? eventId;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return
    // ConstrainedBox(
      // constraints: const BoxConstraints.expand(),
        // child:
        Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
        // child: ListView(
        //   shrinkWrap: true,
        //   children: const [
        //   Card(child: ListTile(title: const Text("Bestuur"))),
        //   Card(child: ListTile(title: const Text("Commissies"))),
        //   Card(child: ListTile(title: const Text("Sociëteiten"))),
        //   // Expanded(child: Container()),
        //   Spacer(),
        //   Divider(),
        //   Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
        //   Card(child: ListTile(title: const Text("Over SIB"))),
        //   Card(child: ListTile(title: const Text("Over app"))),
        // ])
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                // const Card(child: ListTile(title: Text("Bestuur"))),
                // const Card(child: ListTile(title: Text("Commissies"))),
                // const Card(child: ListTile(title: Text("Disputen"))),
                Card(child: ListTile(title: Text("Event id: ${widget.eventId}")))
                // Expanded(child: Container()),
                // Spacer(),
                // Divider(),
                // Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
                // Card(child: ListTile(title: const Text("Over SIB"))),
                // Card(child: ListTile(title: const Text("Over app"))),
              ])
            ),
            // const SliverFillRemaining(
            //   hasScrollBody: false,
            //   child: Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
            //   child:
            //   Column(
            //     mainAxisAlignment: MainAxisAlignment.end,
            //     children: [
            //       Divider(),
            //       Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
            //       Card(child: ListTile(title: const Text("Over SIB"))),
            //       Card(child: ListTile(title: const Text("Over app"))),
            //     ]
            //   )
            //   )
            // )
          ]
        )
        // )
        );
  }
}