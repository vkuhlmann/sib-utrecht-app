part of '../main.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: ListView(children: const [
          Card(
              child: ListTile(
                  title: Text("Next: Pimp je studentenkamer!"),
                  subtitle: Text("Trumanlaan 60 - 19:00"))),
          SizedBox(height: 16),
          Card(
              child: ListTile(
                  leading: Icon(Icons.event),
                  title: Text("Casino night - sign up now"),
                  subtitle: Text("Trumanlaan 60 - 19:00"),
                  trailing: Text("Two days ago")))
        ]));
  }
}
