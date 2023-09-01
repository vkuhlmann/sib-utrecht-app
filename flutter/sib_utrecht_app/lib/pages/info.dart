part of '../main.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
                Card(child: ListTile(title: const Text("Bestuur"))),
                Card(child: ListTile(title: const Text("Commissies"))),
                Card(child: ListTile(title: const Text("Sociëteiten"))),
                // Expanded(child: Container()),
                // Spacer(),
                // Divider(),
                // Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
                // Card(child: ListTile(title: const Text("Over SIB"))),
                // Card(child: ListTile(title: const Text("Over app"))),
              ])
            ),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Divider(),
                  Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
                  Card(child: ListTile(title: const Text("Over SIB"))),
                  Card(child: ListTile(title: const Text("Over app"))),
                ]
              ))
              
            ),
            // SliverList(
            //   delegate: SliverChildListDelegate([
            //     // Card(child: ListTile(title: const Text("Bestuur"))),
            //     // Card(child: ListTile(title: const Text("Commissies"))),
            //     // Card(child: ListTile(title: const Text("Sociëteiten"))),
            //     // Expanded(child: Container()),
            //     // Spacer(),
            //     Divider(),
            //     Card(child: ListTile(title: const Text("Vertrouwenspersonen"))),
            //     Card(child: ListTile(title: const Text("Over SIB"))),
            //     Card(child: ListTile(title: const Text("Over app"))),
            //   ])
            // )
          ]
        )
        // )
    );
  }
}
