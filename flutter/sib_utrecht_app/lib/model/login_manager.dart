
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

import '../log.dart';
import '../constants.dart';
import '../model/login_state.dart';
import 'api_connector.dart';


class LoginManager extends ChangeNotifier {
  late FlutterSecureStorage storage;
  Future<LoginState>? _loadingState;
  late Future<void> initiatedLogin;

  late bool canLoginByRedirect;

  LoginManager() {
    storage = const FlutterSecureStorage();

    canLoginByRedirect = Uri.base.isScheme("https");
  }

  Future<LoginState> _loadState() async {
    var profilesContent = await storage.read(key: 'profiles');
    String? activeProfileName = await storage.read(key: 'activeProfileName');

    Map<String, dynamic> profiles = {};
    if (profilesContent != null) {
      profiles = jsonDecode(profilesContent);
    }

    if (!profiles.keys.contains(activeProfileName)) {
      activeProfileName = null;
    }

    if (profiles.isEmpty || activeProfileName == null) {
      log.info("Returning LoginState not logged in");

      return LoginState(
          connector: APIConnector(apiAddress: defaultApiUrl),
          profiles: profiles.map(
              (key, value) => MapEntry(key, value as Map<String, dynamic>)),
          activeProfileName: null,
          activeProfile: null);
    }

    var activeProfile = profiles[activeProfileName]!;

    log.info("Returning LoginState logged in with $activeProfileName");

    return LoginState(
        connector: APIConnector(
            apiAddress: activeProfile["api"]?["url"] ?? defaultApiUrl,
            user: activeProfile["user"],
            apiSecret: activeProfile["apiSecret"]),
        profiles: profiles
            .map((key, value) => MapEntry(key, value as Map<String, dynamic>)),
        activeProfileName: activeProfileName,
        activeProfile: activeProfile);
  }

  Future<LoginState> setActiveProfile(String? name) async {
    var a = _loadingState;
    if (a != null) {
      var _ = await a;
    }

    await storage.write(key: 'activeProfileName', value: name);
    return refreshLoginState();
  }

  void removeProfile(String? name) async {
    var a = _loadingState;
    if (a != null) {
      var _ = await a;
    }

    // await storage.write(key: 'activeProfileName', value: name);

    var profilesContent = await storage.read(key: 'profiles');

    Map<String, dynamic> profiles = {};
    if (profilesContent != null) {
      profiles = jsonDecode(profilesContent);
    }

    profiles.remove(name);
    await storage.write(key: 'profiles', value: jsonEncode(profiles));

    refreshLoginState();
  }

  Future<LoginState> assureLoginState() {
    var a = _loadingState;
    if (a != null) {
      return a;
    }

    return refreshLoginState();
  }

  Future<LoginState> refreshLoginState() {
    Future<LoginState> b = _loadState();
    _loadingState = b;
    b.catchError((e) {
      log.severe("Error loading profile: $e");
      throw e;
    });
    b.then((res) {
      notifyListeners();
    });
    return b;
  }

  Future<LoginState> completeLogin({
    required String user,
    required String apiSecret,
    required String apiAddress,
    bool fillIdentity = true,
  }) async {
    var prof = (await assureLoginState()).profiles;

    String profileName = user;
    int i = 1;
    while (prof.containsKey(profileName)) {
      profileName = "$user ($i)";
      i++;
    }

    assert(!prof.containsKey(profileName));

    var profile = {
      "app_name": null,
      "user": user,
      "apiSecret": apiSecret,
      "name": profileName,
      "api": {
        "channel": "latest",
        "url": apiAddress,
      },
      "identity": null,
    };

    prof[profileName] = profile;

    if (fillIdentity) {
      var conn = APIConnector(
          apiAddress: apiAddress, user: user, apiSecret: apiSecret);
      var res = await conn.get("/auth");
      var identity = res["data"]?["identity"];
      profile["identity"] = identity;
      if (identity == null) {
        log.severe("Login returned no identity from API");
      }
    }

    String a = jsonEncode(prof);
    await storage.write(key: 'profiles', value: a);
    await storage.write(key: 'activeProfileName', value: profileName);

    return refreshLoginState();
  }

  String getAuthRedirectTarget() {
    return Uri.base.replace(fragment: "/new-login").toString();
  }

  (String, Uri) getAuthorizationUrl({required bool withRedirect}) {
    if (!withRedirect || !canLoginByRedirect) {
      // return (
      //   "https://sib-utrecht.nl/app",
      //   Uri.parse("https://sib-utrecht.nl/app")
      // );
      return (
        "https://sib-utrecht.nl/en/authorize-app",
        Uri.parse("https://sib-utrecht.nl/en/authorize-app")
            .replace(queryParameters: {
          "redirect_url": getAuthRedirectTarget(),
        })
      );
    }

    var uuid = const Uuid();
    final String appName = "sib-utrecht-app_${uuid.v4().substring(0, 6)}";

    // Uri authorize_url = Uri.parse(
    //     "$AUTHORIZE_APP_URL?app_name=$appName"
    //     "&success_url=https%3A%2F%2Fvkuhlmann.com"
    // );

    Map<String, dynamic> queryParams = {
      "app_name": appName,
    };

    if (canLoginByRedirect && withRedirect) {
      queryParams["success_url"] =
          Uri.base.replace(fragment: "/new-login").toString();

      // queryParams["success_url"] = Uri.https("vkuhlmann.com", "/").toString();
    }

    Uri authorizeUrl = Uri.https(Uri.parse(authorizeAppUrl).authority,
        Uri.parse(authorizeAppUrl).path, queryParams);
    return (
      Uri.https(Uri.parse(authorizeAppUrl).authority,
              Uri.parse(authorizeAppUrl).path)
          .toString(),
      authorizeUrl
    );
  }

  // Future<void> _initiateLogin() async {
  //   var uuid = const Uuid();
  //   final String appName = "sib-utrecht-app_${uuid.v4().substring(0, 6)}";

  //   // Uri authorize_url = Uri.parse(
  //   //     "$AUTHORIZE_APP_URL?app_name=$appName"
  //   //     "&success_url=https%3A%2F%2Fvkuhlmann.com"
  //   // );

  //   Map<String, dynamic> queryParams = {
  //     "app_name": appName,
  //   };

  //   if (canLoginByRedirect) {
  //     queryParams["success_url"] =
  //         Uri.base.replace(fragment: "/authorize").toString();
  //   }

  //   Uri authorizeUrl = Uri.https(Uri.parse(authorizeAppUrl).authority,
  //       Uri.parse(authorizeAppUrl).path, queryParams);

  //   log.info("Authorize url: $authorizeUrl");

  //   if (!await launchUrl(authorizeUrl)) {
  //     throw Exception("Could not launch url");
  //   }
  // }

  Future<LoginState> logout() {
    return setActiveProfile(null);
  }
}
