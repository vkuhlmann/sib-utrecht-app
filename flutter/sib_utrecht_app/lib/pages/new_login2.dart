part of '../main.dart';

class NewLogin2Page extends StatefulWidget {
  final Map<String, dynamic> params;

  const NewLogin2Page({Key? key, required this.params}) : super(key: key);

  @override
  State<NewLogin2Page> createState() => _NewLogin2PageState();
}

class _NewLogin2PageState extends State<NewLogin2Page> {
  late Future<Map?> userIdentity;

  @override
  void initState() {
    super.initState();

    // userIdentity = http.get(Uri.parse("https://sib-utrecht.nl/cors-authorize-app"), );

    // http.Client client = http.Client();
    // client.send(http.BaseRequest())

    // HttpRequest.request();

    // userIdentity = Future.value(
    //     Future.value(

    // );
    userIdentity = getUserIdentity();
  }

  Future<Map?> getUserIdentity() async {
    var client = getCorsClient(withCredentials: true);

    if (client == null) {
      return null;
    }

    http.Response res;
    try {
      res = await client
          .get(Uri.parse("https://sib-utrecht.nl/cors-authorize-app"));
    } catch (ex) {
      client = getCorsClient(withCredentials: false);
      if (client == null) {
        return null;
      }
      res = await client
          .get(Uri.parse("https://sib-utrecht.nl/cors-authorize-app"));
    }

    if (res.statusCode != 200) {
      String a;
      try {
        a = jsonDecode(res.body)["error"];
      } catch (ex) {
        throw Exception("Failed to load user identity: ${res.body}");
      }
      throw Exception(a);
    }

    Map body = jsonDecode(res.body);

    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(children: [
        const Text('NewLogin2Page'),
        const SizedBox(height: 20),
        FutureBuilder(
            future: userIdentity,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text('userIdentity: ${jsonEncode(snapshot.data)}');
              } else if (snapshot.hasError) {
                return Text('Error for userIdentity: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            }),
        // Text('userIdentity: ${jsonEncode(userIdentity)}'),
      ])),
    );
  }
}
