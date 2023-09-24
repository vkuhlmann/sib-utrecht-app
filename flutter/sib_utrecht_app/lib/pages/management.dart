part of '../main.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: ListView(
      children: [
        Card(
          child: InkWell(
            child: const ListTile(
            title: Text("API requests")),
            onTap: () {
              router.go("/api-debug");
            })),
        const Card(
          child: InkWell(
            child: const ListTile(
            title: Text("Groups")),
            onTap: null)),
      ]
    ));

    return const Scaffold(
      body: Center(child: Text("Management")),
    );
  }
}
