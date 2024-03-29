import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sib_utrecht_app/components/centered_page.dart';

import '../globals.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return 
    // WithSIBAppBar(actions: const [], child:
    CenteredPage(child: 
    Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Card(
              child: InkWell(
                  child: const ListTile(title: Text("API requests")),
                  onTap: () {
                    router.push("/api-debug");
                  })),
          Card(
              child: InkWell(
            onTap: () {
              router.push("/management/groups");
            },
            child: const ListTile(title: Text("Groups")),
          )),
          Card(
              child: InkWell(
                  child: const ListTile(title: Text("New event")),
                  onTap: () {
                    router.go("/event/new");
                  })),
          Card(
            child: InkWell(
              child: const ListTile(title: Text("Clear cache")),
              onTap: () {
                Hive.init(null);
                Future.wait([Hive.openBox("api_cache"), Hive.openBox("cache")]).then<void>((boxes) {
                  for (var b in boxes) {
                    b.clear();
                  }
                  // box.then((b) => b.clear());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Cache cleared"),
                  ));
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Error clearing cache"),
                  ));
                  return;
                });
              },
            ),
          ),
          Card(
              child: InkWell(
                  child: const ListTile(title: Text("Users")),
                  onTap: () {
                    router.push("/management/users");
                  })),
        ])));
  }
}
