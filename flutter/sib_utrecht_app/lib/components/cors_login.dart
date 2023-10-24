import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utils.dart';
import '../globals.dart';
import '../model/login_state.dart';

import '../model/cors_fallback.dart'
  if (dart.library.html) '../model/cors_web.dart';

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

          LoginState stFut = await loginManager.completeLogin(
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
