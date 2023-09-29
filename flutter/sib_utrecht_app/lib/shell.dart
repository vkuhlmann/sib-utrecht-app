part of 'main.dart';

// Navigation bar code based on https://api.flutter.dev/flutter/material/NavigationBar-class.html

class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar(this.navigationShell,
      {Key? key,
      required this.title,
      required this.currentPage,
      required this.loginController})
      : super(key: key);

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;
  final String title;
  final String currentPage;

  final LoginManager loginController;

  // final BuildContext? rootContext = _rootNavigatorKey.currentContext;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  // _ScaffoldWithNavbarState({super.key});

  // int currentPageIndex = 0;
  // late LoginManager loginManager;
  // bool canPop = false;

  // List<Key> pageKeys = [
  //   const PageStorageKey('ActivitiesPage'),
  //   const PageStorageKey('InfoPage'),
  //   const PageStorageKey('DebugPage'),
  // ];

  // final Map<int, Widget> pages = [
  //   // const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
  //   const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
  //   const Placeholder(),
  //   const InfoPage(key: PageStorageKey('InfoPage')),
  //   // const DebugPage(key: PageStorageKey('DebugPage')),
  // ].asMap();

  late Future<LoginState> loginState;
  late void Function() listenerFunc;
  int get selectedIndex =>
      (({0: 0, 1: 1, 2: 2, 3: 0, 4: 2})[widget.navigationShell.currentIndex]!);
  List<NavigationDestination> getDestinations(BuildContext context) {
    return [
      NavigationDestination(
        icon: const Icon(Icons.event_outlined),
        // icon: Icon(Symbols.calendar_month),
        label: AppLocalizations.of(context)!.tabEvents,
        selectedIcon: const Icon(Icons.event),
      ),
      NavigationDestination(
        icon: const Icon(Icons.timeline_outlined),
        label: AppLocalizations.of(context)!.tabFeed,
        selectedIcon: const Icon(Icons.timeline),
      ),
      NavigationDestination(
        icon: const Icon(Icons.tab_outlined),
        label: AppLocalizations.of(context)!.tabInfo,
        selectedIcon: const Icon(Icons.tab),
      )
    ];
  }

  @override
  void initState() {
    super.initState();

    loginState = widget.loginController.assureLoginState();

    listenerFunc = () {
      setState(() {
        loginState = widget.loginController.assureLoginState();
      });
    };

    widget.loginController.addListener(listenerFunc);
    // widget.loginController.scheduleLoadProfiles();
  }

  @override
  void dispose() {
    widget.loginController.removeListener(listenerFunc);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // BuildContext? navContext = _sectionNavigatorKey.currentContext;
    // bool newCanPop = navContext != null && (false || navContext.canPop());
    // if (newCanPop != canPop) {
    //   setState(() {
    //     canPop = newCanPop;
    //   });
    // }
  }

  Widget buildLoginMenu(
      BuildContext context, AsyncSnapshot<LoginState> snapshot) {
    return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
      SliverList(
          delegate: SliverChildListDelegate(<Widget>[
        Row(
          children: [
            if (snapshot.data?.activeProfileName != null)
              Expanded(
                  child: Row(children: [
                Flexible(
                    child: Text("Hoi ${snapshot.data?.activeProfile?['user']}",
                        overflow: TextOverflow.ellipsis)),
                const Text("!")
              ]))
            else
              const Expanded(child: Text("Not logged in!")),
            const SizedBox(
              width: 16,
            ),
            // const CircleAvatar(backgroundColor: Colors.blue)
            Icon(Icons.favorite,
                color: Theme.of(context).colorScheme.primary, size: 40)
          ],
        ),
        // const SizedBox(height: 15),
        // const Text("test"),
        const SizedBox(height: 15),
        Row(children: [
          Text(AppLocalizations.of(context)!.darkTheme),
          const Spacer(),
          Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (val) {
                MyApp.setDark(context, val);
              }),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          const Text("Dutch"),
          const Spacer(),
          Switch(
              value: Localizations.localeOf(context).languageCode == "nl",
              onChanged: (val) {
                MyApp.setDutch(context, val);
              }),
        ]),
        const SizedBox(height: 15),
        Row(children: [
          const Text("SIB color in app bar"),
          const Spacer(),
          Switch(
              value: MyApp._getState(context)?.useSibColorInStatusBar == true,
              onChanged: (val) {
                MyApp.setUseSibColorInStatusBar(context, val);
              }),
        ]),
        ...((snapshot.data?.activeProfileName != null)
            ? ([
                const SizedBox(height: 15),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // setState(() {
                      //   widget.loginController.logout().then((value) {
                      //     router.go("/login?immediate=false");
                      //   });
                      // });
                      router.go("/login");
                    },
                    // child: Text(AppLocalizations.of(context)!
                    //     .actionLogout)
                    // child: const Text("Switch account"),
                    child: Text(AppLocalizations.of(context)!
                        .gotoSwitchAccountPage)
                         // const Text('Logout'),
                    ),
              ])
            : ([])),
        ...((snapshot.data?.activeProfileName == null)
            ? ([
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    router.go("/login?immediate=true");
                  },
                  child: Text(AppLocalizations.of(context)!
                        .actionLogIn),
                ),
              ])
            : ([])),
        ...((snapshot.hasError)
            ? ([const SizedBox(height: 15), Text("Error: ${snapshot.error}")])
            : ([])),
      ]))
    ]);
  }

  Widget buildLoginIcon(BuildContext context) {
    return FutureBuilder(
        future: loginState,
        builder: (context, snapshot) {
          Color backgroundColor = Colors.grey;
          if (snapshot.hasData) {
            backgroundColor = Colors.white;
            if (snapshot.data?.activeProfileName != null) {
              backgroundColor = Theme.of(context).colorScheme.primary;
            }
          }

          if (snapshot.hasError) {
            backgroundColor = Colors.red;
          }

          return IconButton(
              // icon: CircleAvatar(backgroundColor: backgroundColor),
              icon: Icon(Icons.favorite, color: backgroundColor, size: 40),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                          alignment: AlignmentDirectional.topEnd,
                          insetPadding:
                              const EdgeInsets.fromLTRB(16, 70, 16, 16),
                          child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              width: 200,
                              child: buildLoginMenu(context, snapshot)));
                    });
              });
        });
  }

  String? getBackAddress(BuildContext context) {
    if (GoRouterState.of(context).matchedLocation.startsWith("/event/")) {
      return "/";
    }

    return null;
  }

  Widget buildWide() {
    return Builder(
        builder: (context) => Scaffold(
            // bottomNavigationBar: NavigationBar(
            //   onDestinationSelected: _onDestinationSelected,
            //   selectedIndex: selectedIndex,
            //   destinations: destinations,
            // ),
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Row(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(
                      'assets/sib_logo_64.png',
                      fit: BoxFit.contain,
                      height: 40,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(width: 16),
                    Text(widget.title),
                    const Spacer(),
                    buildLoginIcon(context)
                  ],
                )),
            body: SafeArea(
                child: Row(children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: _onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: getDestinations(context)
                    .map((e) => NavigationRailDestination(
                        icon: e.icon,
                        label: Text(e.label),
                        selectedIcon: e.selectedIcon))
                    .toList(),
              ),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: widget.navigationShell)
            ]))));
  }

  Widget buildMobile() {
    String? backAddress = getBackAddress(context);

    return Builder(
        builder: (context) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: _onDestinationSelected,
              selectedIndex: selectedIndex,
              destinations: getDestinations(context),
            ),
            appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary, 
                title: Row(
                  children: <Widget>[
                    if (backAddress != null || Navigator.of(context).canPop())
                      BackButton(
                        onPressed: backAddress == null
                            ? null
                            : () {
                                // if () {
                                //   GoRouter.of(context).go("/");
                                //   return;
                                // }
                                router.go(backAddress);
                              },
                      ),
                    // BackButton(onPressed: () {
                    //   // Navigator.maybePop(context);
                    //   // context.pop();
                    //   if (GoRouterState.of(context)
                    //       .matchedLocation
                    //       .startsWith("/event/")) {
                    //     // context.go("/");
                    //     // _router.go("/");
                    //     // _router.go("/feed");
                    //     GoRouter.of(context).go("/");
                    //     // _sectionNavigatorKey.currentContext!.go("/");
                    //     return;
                    //   }
                    Image.asset(
                      'assets/sib_logo_64.png',
                      fit: BoxFit.contain,
                      height: 40,
                      filterQuality: FilterQuality.medium,
                    ),
                    const SizedBox(width: 16),
                    Text(widget.title),
                    const Spacer(),
                    buildLoginIcon(context)
                  ],
                )),
            body: SafeArea(child: widget.navigationShell)));
  }

  @override
  Widget build(BuildContext context) {
    return APIAccess(
        state: loginState,
        // child: buildMobile()
        child: MediaQuery.of(context).size.width > 800
            ? buildWide()
            : buildMobile());
  }

  void _onDestinationSelected(index) {
    widget.navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

const Color sibColor = Color.fromARGB(255, 33, 82, 111);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? _getState(BuildContext context) {
    // Source: https://stackoverflow.com/questions/55889889/how-to-change-a-flutter-app-language-without-restarting-the-app
    // answer by https://stackoverflow.com/users/7639019/seddiq-sorush

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state;
  }

  static void setDutch(BuildContext context, bool? val) {
    var state = _getState(context);

    if (state == null) {
      log.severe("Could not find _MyAppState for setDutch");
      return;
    }

    state.setDutch(val);
  }

  static void setDark(BuildContext context, bool? val) {
    // Source: https://stackoverflow.com/questions/55889889/how-to-change-a-flutter-app-language-without-restarting-the-app
    // answer by https://stackoverflow.com/users/7639019/seddiq-sorush

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    if (state == null) {
      log.severe("Could not find _MyAppState for setDark");
      return;
    }

    state.setDark(val);
  }

  static void setUseSibColorInStatusBar(BuildContext context, bool val) {
    // Source: https://stackoverflow.com/questions/55889889/how-to-change-a-flutter-app-language-without-restarting-the-app
    // answer by https://stackoverflow.com/users/7639019/seddiq-sorush

    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    if (state == null) {
      log.severe("Could not find _MyAppState for setUseSibColorInStatusBar");
      return;
    }

    state.setUseSibColorInStatusBar(val);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isDutch;
  bool? isDark;
  bool useSibColorInStatusBar = true;
  late ThemeData lightTheme;
  late ThemeData darkTheme;
  Color appbarColor = sibColor;

  @override
  void initState() {
    super.initState();

    updateTheme();
  }

  void setDutch(bool? val) {
    setState(() {
      isDutch = val;
    });
  }

  void setDark(bool? val) {
    setState(() {
      isDark = val;
    });
  }

  void setUseSibColorInStatusBar(bool val) {
    setState(() {
      useSibColorInStatusBar = val;
    });
  }

  void updateTheme() {
    bool effectiveUseSibColorInStatusBar =
        useSibColorInStatusBar && isDark != false;

    setState(() {
      lightTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: sibColor, brightness: Brightness.light,
          // primary: sibColor,
          inversePrimary: effectiveUseSibColorInStatusBar ? sibColor : null,
        ),
        useMaterial3: true,
        brightness: Brightness.light,
        // fontFamily: 'Roboto',
      );
      darkTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: sibColor, brightness: Brightness.dark,
          // primary: sibColor,
          // secondary: sibColor,
          // onPrimary: sibColor,
          // tertiary: sibColor,
          // background: sibColor,
          // onBackground: sibColor,
          // onSecondary: sibColor,
          // onTertiary: sibColor,
          // primaryContainer: sibColor,
          // secondaryContainer: sibColor,
          // tertiaryContainer: sibColor,
          inversePrimary: effectiveUseSibColorInStatusBar ? sibColor : null,
          // tertiaryContainer: Colors.red
          // primary: Colors.grey[800],
          // inverseSurface: sibColor
        ),
        useMaterial3: true,
        brightness: Brightness.dark,
        // textTheme: ThemeData.dark().textTheme.copyWith(
        //   bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
        //     fontFamily: "RobotoMono",
        //     fontFamilyFallback: ["Roboto", "NotoEmoji", "NotoSans", "RobotoMono"]
        //   ),
        // ),
        // fontFamily: 'Roboto',
      );

      Color themeColor = sibColor;

      if (!effectiveUseSibColorInStatusBar) {
        themeColor = isDark != false
            ? darkTheme.colorScheme.inversePrimary
            : lightTheme.colorScheme.inversePrimary;
      }

      appbarColor = themeColor;
    });

    setMetaThemeColor(appbarColor);
  }

  @override
  Widget build(BuildContext context) {
    bool? useDarkTheme = isDark;

    return Preferences(
        // locale: "nl_NL",
        locale: isDutch == true
            ? const Locale("nl", "NL")
            : const Locale("en", "GB"),
        debugMode: false,
        child: Builder(
            builder: (context) => MaterialApp.router(
                routerConfig: router,
                title: 'SIB-Utrecht',
                theme: lightTheme,
                darkTheme: darkTheme,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate
                ],
                supportedLocales: const [
                  Locale('en', 'GB'),
                  Locale('nl', 'NL'),
                ],
                // locale: Preferences.of(context).locale,
                locale: isDutch == true
                    ? const Locale('nl', 'NL')
                    : (isDutch == false ? const Locale('en', 'GB') : null),
                // locale: const Locale('nl', 'NL'),
                // locale: const Locale('en', 'GB'),
                themeMode: useDarkTheme == null
                    ? ThemeMode.system
                    : (useDarkTheme ? ThemeMode.dark : ThemeMode.light),
                debugShowCheckedModeBanner: true)));
  }
}
