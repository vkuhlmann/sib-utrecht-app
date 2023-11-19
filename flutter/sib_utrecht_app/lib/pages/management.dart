import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';

import '../globals.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WithSIBAppBar(actions: const [], child:
    Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Card(
              child: InkWell(
                  child: const ListTile(title: Text("API requests")),
                  onTap: () {
                    router.go("/api-debug");
                  })),
          const Card(
              child: InkWell(
            onTap: null,
            child: ListTile(title: Text("Groups")),
          )),
          Card(
              child: InkWell(
                  child: const ListTile(title: Text("New event")),
                  onTap: () {
                    router.go("/event/new/edit");
                  })),
          Card(
            child: InkWell(
              child: const ListTile(title: Text("Clear cache")),
              onTap: () {
                Hive.init(null);
                Hive.openBox("api_cache").then((box) {
                  box.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Cache cleared"),
                  ));
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Error clearing cache"),
                  ));
                });
              },
            ),
          )
        ])));
  }
}
