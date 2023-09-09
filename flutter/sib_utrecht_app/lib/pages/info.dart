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
    return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            const Card(child: ListTile(title: Text("Bestuur"))),
            const Card(child: ListTile(title: Text("Commissies"))),
            const Card(child: ListTile(title: Text("Genootschappen"))),
          ])),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Divider(),
                        const Card(
                            child:
                                ListTile(title: Text("Vertrouwenspersonen"))),
                        const Card(child: ListTile(title: Text("Over SIB"))),
                        Card(
                            child: InkWell(
                                onTap: () {
                                  showAboutDialog(
                                      context: context,
                                      applicationName: "SIB-Utrecht",
                                      applicationVersion: "0.1.3");
                                },
                                child: const ListTile(title: Text("Over app"))))
                      ])))
        ]));
  }
}
