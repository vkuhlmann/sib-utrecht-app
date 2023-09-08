part of 'main.dart';

// class Login

// class LoginContext extends StatefulWidget {
//   const LoginContext({Key? key, required this.child}) : super(key: key);

//   final Widget child;

//   @override
//   State<LoginContext> createState() => _LoginContextState();
// }

// class _LoginContextState extends State<LoginContext> {

class LoginState {
  final APIConnector connector;
  final Map<String, Map<String, dynamic>> profiles;

  final String? activeProfileName;
  final Map<String, dynamic>? activeProfile;

  const LoginState(
      {required this.connector,
      required this.profiles,
      required this.activeProfileName,
      required this.activeProfile});
}

class LoginManager extends ChangeNotifier {
  // late Future<APIConnector> connector;
  // late Future<Map<String, Map<String, dynamic>>> _profiles;

  // late Future<String?> activeProfileName;
  // late Future<Map<String, dynamic>?> _activeProfileFull;

  // late Future<Map<String, dynamic>?> activeProfile;

  late FlutterSecureStorage storage;
  Future<LoginState>?
      _loadingState; // = Future.error(Exception("Not initialized"));
  late Future<void> initiatedLogin;

  // LoginState currentState;

  late bool canLoginByRedirect;

  // final LoginState loggedOutState = LoginState(
  //         connector: APIConnector(),
  //         profiles: {},
  //         // activeProfileName: 'Not logged in',
  //         // activeProfile: {}
  //         activeProfileName: null,
  //         activeProfile: null);

  // @override
  // void initState() {
  //   super.initState();

  //   storage = const FlutterSecureStorage();

  //   loadProfiles();
  // }

  LoginManager() {
    storage = const FlutterSecureStorage();

    canLoginByRedirect = Uri.base.isScheme("https");
    // canLoginByRedirect = true; // https://vkuhlmann.com

    // currentState = LoginState(
    //     connector: APIConnector(),
    //     profiles: null,
    //     activeProfileName: null,
    //     activeProfile: null);

    // state = Future.value(loggedOutState);
    // scheduleLoadProfiles();
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
          connector: APIConnector(),
          profiles: profiles.map(
              (key, value) => MapEntry(key, value as Map<String, dynamic>)),
          activeProfileName: null,
          activeProfile: null);
    }

    // var activeProfileName = activeProfileName;
    var activeProfile = profiles[activeProfileName]!;

    log.info("Returning LoginState logged in with $activeProfileName");

    return LoginState(
        connector: APIConnector(
            user: activeProfile["user"], apiSecret: activeProfile["apiSecret"]),
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

    // (_loadingState ?? Future.value()).then(() {});

    // _loadingState = _loadingState ?? .then((value) async {
    //   await storage.write(key: 'activeProfileName', value: name);
    //   return _loadState();
    // });
    // _loadingState.then((res) {
    //   // currentState = res;
    //   notifyListeners();
    // });
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
      // currentState = res;
      notifyListeners();
    });
    return b;
  }

  // void scheduleLoadProfiles() {
  //   if (_loadingState != null)
  //     return;

  //   log.info("Scheduling profile load");
  //   // state.catchError((e) {
  //   //   print("Old error loading profile: $e");
  //   // });
  //   // setState(() {

  //   _loadingState = _loadState();
  //   _loadingState.catchError((e) {
  //     log.severe("Error loading profile: $e");
  //     throw e;
  //   });
  //   _loadingState.then((res) {
  //     // currentState = res;
  //     notifyListeners();
  //   });
  //   // state.whenComplete(() {
  //   //   notifyListeners();
  //   // });
  //   // });
  //   // setState(() {
  //   // _profiles = storage.read(key: 'profiles').then((value) {
  //   //   if (value == null) {
  //   //     return {};
  //   //   }

  //   //   // activeProfile = profiles.keys.first;
  //   //   return jsonDecode(value);
  //   // });

  //   // activeProfileName = _profiles.then((value) {
  //   //   if (value.isEmpty) {
  //   //     return 'Not logged in';
  //   //   }
  //   //   return value.keys.first;
  //   // });

  //   // _activeProfileFull = Future.wait([_profiles, activeProfileName]).then((a) {
  //   //   var (prof, activeProfName) = (a[0], a[1]) as (Map<String, Map>, String);

  //   //   if (prof.isEmpty) {
  //   //     return null;
  //   //   }

  //   //   return prof[activeProfName]?.update("name", (value) => activeProfName);
  //   // });

  //   // connector = _activeProfileFull.then((activeProf) {
  //   //   if (activeProf == null) {
  //   //     return APIConnector();
  //   //   }

  //   //   return APIConnector(user: activeProf["user"], apiSecret: activeProf["apiSecret"]);
  //   // });

  //   // activeProfile = _activeProfileFull.then((a) {
  //   //   if (a == null) {
  //   //     return null;
  //   //   }

  //   //   var copy = Map<String, dynamic>.from(a);
  //   //   copy.remove("apiSecret");

  //   //   return copy;
  //   // });
  //   // });
  // }

  // void logout() {
  // }

  void scheduleLogin() {
    // state.catchError((e) {
    //   print("Old error loading profile: $e");
    // });
    setActiveProfile(null);
    initiatedLogin = _initiateLogin();
    initiatedLogin.catchError((e) {
      log.warning("Error logging in: $e");
    });
  }

  Future<LoginState> _completeLogin(
      {required String user, required String apiSecret}) async {
    String profileName = "profile1";
    // var prof = (await _loadingState).profiles;
    var prof = (await assureLoginState()).profiles;

    // _rootNavigatorKey.currentContext?.showSnackBar(SnackBar(
    //   content: Text("Logged in as $user"),
    // ));
    // ScaffoldMessenger.of(_rootNavigatorKey.currentContext!).showSnackBar(
    //   SnackBar( content: Text("Incremented"), duration: Duration(milliseconds: 300), ), );

    profileName = user;
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
      "name": profileName
    };

    prof[profileName] = profile;
    String a = jsonEncode(prof);
    await storage.write(key: 'profiles', value: a);
    await storage.write(key: 'activeProfileName', value: profileName);

    // ScaffoldMessenger.of(_rootNavigatorKey.currentContext!).showSnackBar(
    //   const SnackBar( content: Text("Logged in") ) );

    return refreshLoginState();

    // scheduleLoadProfiles();
    // state = _loadState();
    // var res = await state;
    // notifyListeners();
    // return await _loadingState;
  }

  (String, Uri) getAuthorizationUrl({required bool withRedirect}) {
    if (!withRedirect || !canLoginByRedirect) {
      return (
        "https://sib-utrecht.nl/app",
        Uri.parse("https://sib-utrecht.nl/app")
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

  Future<void> _initiateLogin() async {
    var uuid = const Uuid();
    final String appName = "sib-utrecht-app_${uuid.v4().substring(0, 6)}";

    // Uri authorize_url = Uri.parse(
    //     "$AUTHORIZE_APP_URL?app_name=$appName"
    //     "&success_url=https%3A%2F%2Fvkuhlmann.com"
    // );

    Map<String, dynamic> queryParams = {
      "app_name": appName,
    };

    if (canLoginByRedirect) {
      queryParams["success_url"] =
          Uri.base.replace(fragment: "/authorize").toString();
    }

    Uri authorizeUrl = Uri.https(Uri.parse(authorizeAppUrl).authority,
        Uri.parse(authorizeAppUrl).path, queryParams);

    log.info("Authorize url: $authorizeUrl");

    if (!await launchUrl(authorizeUrl)) {
      throw Exception("Could not launch url");
    }

    // await Future.delayed(Duration(seconds: 2));

    // var queryResults = {
    //   "user_login": "vincent",
    //   "password": "PuNZ ZO31 bZCP har0 VYwo cNKP"
    // };

    // String profileName = "profile1";
    // var prof = (await state).profiles;

    // assert(!prof.containsKey(profileName));

    // var profile = {
    //   "app_name": appName,
    //   "user": queryResults["user_login"],
    //   "apiSecret": queryResults["password"],
    //   "name": profileName
    // };

    // prof[profileName] = profile;
    // await storage.write(key: 'profiles', value: jsonEncode(prof));

    // // loadProfiles();
    // return await _loadState();
  }

  Future<LoginState> logout() {
    return setActiveProfile(null);
    // scheduleLoadProfiles();
  }

  // void eraseProfiles() {
  //   storage.delete(key: 'profiles');
  //   loadProfiles();
  // }

  // void switchProfile(String profileName) {
  // }

  // @override
  // Widget build(BuildContext context) {
  //   return APIAccess(
  //     profileName: activeProfileName,
  //     profile: activeProfile,
  //     connector: connector,
  //     child: widget.child,
  //   );
  // }
}

class APIAccess extends InheritedWidget {
  const APIAccess({
    super.key,
    required super.child,
    required this.state,
    // required this.controller
    // required this.profileName,
    // required this.profile,
    // required this.connector
  });

  // final LoginManager controller;
  final Future<LoginState> state;
  // final Future<String?> profileName;
  // final Future<Map<String, dynamic>?> profile;
  // final Future<APIConnector> connector;

  // @override
  // void initState() {

  //   super.initState();
  // }

  static APIAccess? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<APIAccess>();
  }

  static APIAccess of(BuildContext context) {
    final APIAccess? result = maybeOf(context);
    assert(result != null, 'No APIAccess found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(APIAccess oldWidget) =>
      // connector != oldWidget.connector ||
      // // connector.basicAuth != oldWidget.connector.basicAuth ||
      // profileName != oldWidget.profileName ||
      // profile != oldWidget.profile;
      state != oldWidget.state;
}
