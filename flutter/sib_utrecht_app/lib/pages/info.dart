import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../globals.dart';
import '../components/actions/sib_appbar.dart';

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
    return WithSIBAppBar(actions: const [], child:
     Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: CustomScrollView(slivers: [
          SliverList(
              delegate: SliverChildListDelegate([
            // const Card(child: ListTile(title: Text("Bestuur"))),
            // const Card(child: ListTile(title: Text("Commissies"))),
            // const Card(child: ListTile(title: Text("Genootschappen"))),
            Card(
                child:
                    ListTile(title: Text(AppLocalizations.of(context)!.board))),
            Card(
                child: ListTile(
                    title: Text(AppLocalizations.of(context)!.committees))),
            Card(
                child: ListTile(
                    title: Text(AppLocalizations.of(context)!.societies))),
          ])),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Divider(),
                        // const Card(
                        //     child:
                        //         ListTile(title: Text("Vertrouwenspersonen"))),
                        // const Card(child: ListTile(title: Text("Over SIB"))),
                        Card(
                            child: 
                            InkWell(
                              onTap:() {
                                router.go("/info/confidants");
                              },
                              child: ListTile(
                                title: Text(AppLocalizations.of(context)!
                                    .confidentialAdvisers)))),
                        Card(child: ListTile(title: Text(
                            // "Over SIB"
                            AppLocalizations.of(context)!.aboutSIB))),
                        Card(
                            child: InkWell(
                                onTap: () {
                                  showAboutDialog(
                                      context: context,
                                      applicationName: "SIB-Utrecht",
                                      applicationVersion: "0.1.6");
                                },
                                child: ListTile(title: Text(
                                    // "Over app"
                                    AppLocalizations.of(context)!.aboutApp)))),
                        Card(
                            child:InkWell(
                                onTap: () {
                                  // showMenu(context: context,
                                  //     position: const RelativeRect.fromLTRB(
                                  //         32, 32, 32, 32),
                                  //     items: const [
                                  //       PopupMenuItem(
                                  //           child: ListTile(
                                  //               title: Text("API requests"))),
                                  //       PopupMenuItem(
                                  //           child: ListTile(
                                  //               title: Text("Groups")))
                                  //     ]);
                                  router.go("/management");
                                },
                                child:  ListTile(
                                title: Text(AppLocalizations.of(context)!
                                    .management)))),
                      ])))
        ])));
  }
}
