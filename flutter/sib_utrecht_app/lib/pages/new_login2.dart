part of '../main.dart';

class NewLogin2Page extends StatefulWidget {
  final Map<String, dynamic> params;

  const NewLogin2Page({Key? key, required this.params}) : super(key: key);

  @override
  State<NewLogin2Page> createState() => _NewLogin2PageState();
}

Future<Map?> getUserIdentity(
    {required bool doAuthorize, String? userLogin}) async {
  var dummyRes = {
    "identity": {
      "user_id": "6001",
      // "user_login": "me@example.org",
      "user_login": "vincent-test1",
      "user_email": "me@example.org",
      "user_display_name": "Vincent Kuhlmann",
      "user_firstname": "Vincent",
    },
    // "request_origin": $_SERVER['HTTP_ORIGIN'],
    "authorization": {
      // "user_login": "me@example.org",
      "user_login": "vincent-test1",
      "app_name": "sib-utrecht-app-0a0a0",
      "password": "aaaaaa",
      "api_url": 'https://sib-utrecht.nl/wp-json/sib-utrecht-wp-plugin/v1',
    }
  };

  // return dummyRes;

  var client = getCorsClient(withCredentials: true);

  if (client == null) {
    return null;
  }

  http.Response res;
  try {
    var url = Uri.parse("https://sib-utrecht.nl/cors-authorize-app");
    Map<String, dynamic> params = {};

    if (userLogin != null) {
      params["user_login"] = userLogin;
    }

    if (doAuthorize) {
      params["action"] = "authorize";
    }
    url = url.replace(queryParameters: params);

    res = await client.get(url);
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

Widget buildCorsLogin(BuildContext context, Map data) {
  // return Text('userIdentity: ${jsonEncode(snapshot.data)}');
  var userLogin = data["identity"]["user_login"];
  if (userLogin == false || userLogin == null) {
    return const SizedBox();
    // return const ListTile(
    //   title: Text("Direct login is not available"),
    //   subtitle: Text("Not logged in on website"),
    // );
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Continue as '),
    const SizedBox(height: 4),
    Card(
        // child: InkWell(
        child: ListTile(
      title: Text(data["identity"]["user_display_name"]),
      subtitle: Text(data["identity"]["user_email"]),
      trailing: const Icon(Icons.chevron_right),
      leading: const Icon(Icons.add, color: Colors.green),
      onTap: () {
        var corsAuth = getUserIdentity(
            doAuthorize: true, userLogin: data["identity"]["user_login"]);
        // authorizingUserIdentity = corsAuth;

        corsAuth.then((value) async {
          if (value == null) {
            throw Exception("CORS authorization is unavailable");
          }

          if (value["error"] != null) {
            throw Exception(value["error"]);
          }

          var auth = value["authorization"];

          if (auth?["password"] == null) {
            throw Exception("Failed to authorize");
          }

          LoginState stFut = await loginManager._completeLogin(
            user: auth["user_login"],
            apiSecret: auth["password"],
            apiAddress: auth["api_url"],
          );

          router.go("/");
        }).catchError((err) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: formatError(err)));
        });
      },
    )),
  ]);
}

Future<Widget?> getCorsLoginPrompt({bool Function(String)? predicate}) async {
  Map? userIdentity;

  try {
    userIdentity = await getUserIdentity(doAuthorize: false);
  } catch (e) {
    return ListTile(
      leading: const Icon(Icons.error),
      title: const Text("Direct login is not available"),
      subtitle: formatError(e),
    );
  }

  predicate = predicate ?? ((String userLogin) => true);

  var userLogin = userIdentity?["identity"]["user_login"] ?? false;

  if (userIdentity == null || userLogin == false) {
    return null;
  }

  if (!predicate(userLogin)) {
    return null;
  }

  var a = userIdentity;
  return Builder(builder: (context) => buildCorsLogin(context, a));
}

class _NewLogin2PageState extends State<NewLogin2Page> {
  late Future<Map?> userIdentity;
  // Future<Map?>? authorizingUserIdentity;

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
    userIdentity = getUserIdentity(doAuthorize: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // const Text('NewLogin2Page'),
                        const SizedBox(height: 20),
                        FutureBuilder(
                            future: userIdentity,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return ListTile(
                                    leading: const Icon(Icons.error),
                                    title: const Text(
                                        "Direct login is not available"),
                                    subtitle: formatError(snapshot.error));
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              var data = snapshot.data;

                              if (data == null) {
                                return const SizedBox();
                                // return const ListTile(
                                //   title: const Text("Login via website unavailable"),
                                //   // subtitle: const Text("Failed to load user identity")
                                // );
                              }

                              return buildCorsLogin(context, data);
                            }),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final (_, url) = loginManager.getAuthorizationUrl(
                                withRedirect: false);

                            launchUrl(url).then((v) {
                              if (!v) {
                                throw Exception("Failed to launch url");
                              }
                            }).catchError((err) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: formatError(err)));
                            });
                          },
                          child: const Text("Log in via browser redirect"),
                        )
                        // Text('userIdentity: ${jsonEncode(userIdentity)}'),
                      ])))),
    );
  }
}
