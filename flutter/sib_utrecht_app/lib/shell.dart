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
            const CircleAvatar(backgroundColor: Colors.blue)
          ],
        ),
        const SizedBox(height: 15),
        const Text("test"),
        ...((snapshot.data?.activeProfileName != null)
            ? ([
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      widget.loginController.logout().then((value) {
                        router.go("/login?immediate=false");
                      });
                    });
                  },
                  child: const Text('Logout'),
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
                  child: const Text('Login'),
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
              backgroundColor = Colors.blue;
            }
          }

          if (snapshot.hasError) {
            backgroundColor = Colors.red;
          }

          return IconButton(
              icon: CircleAvatar(backgroundColor: backgroundColor),
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

  @override
  Widget build(BuildContext context) {
    return Preferences(
        locale: "nl_NL",
        debugMode: true,
        child: APIAccess(
            state: loginState,
            child: Scaffold(
                bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (int index) {
                    _onTap(index);
                  },
                  selectedIndex: (({
                    0: 0,
                    1: 1,
                    2: 2,
                    3: 0
                  })[widget.navigationShell.currentIndex]!),
                  destinations: const <Widget>[
                    NavigationDestination(
                      icon: Icon(Icons.event_outlined),
                      // icon: Icon(Symbols.calendar_month),
                      label: 'Activities',
                      selectedIcon: Icon(Icons.event),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.timeline_outlined),
                      label: 'Feed',
                      selectedIcon: Icon(Icons.timeline),
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.tab_outlined),
                      label: "Info",
                      selectedIcon: Icon(Icons.tab),
                    )
                  ],
                ),
                appBar: AppBar(
                    backgroundColor:
                        Theme.of(context).colorScheme.inversePrimary,
                    title: Row(
                      children: <Widget>[
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

                        Text(widget.title),
                        const Spacer(),
                        buildLoginIcon(context)
                      ],
                    )),
                body: widget.navigationShell)));
  }

  void _onTap(index) {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: router,
        title: 'SIB-Utrecht',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.light),
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple, brightness: Brightness.dark),
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: true);
  }
}
