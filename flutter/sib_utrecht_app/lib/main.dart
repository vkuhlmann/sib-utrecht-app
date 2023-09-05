import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
import 'package:logging/logging.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

part 'login_manager.dart';
part 'api_connector.dart';
part 'async_patch.dart';
part 'pages/activities.dart';
part 'pages/debug.dart';
part 'pages/info.dart';
part 'pages/authorize.dart';
part 'pages/event.dart';
part 'pages/login.dart';
part 'pages/new-login.dart';

part 'event.dart';
part 'locale_date_format.dart';

late Future<void> dateFormattingInitialization;
// const String wordpressUrl = "http://192.168.50.200/wordpress";
const String wordpressUrl = "https://sib-utrecht.nl";
const String apiUrl = "$wordpressUrl/wp-json/sib-utrecht-wp-plugin/v1";
const String authorizeAppUrl =
    "$wordpressUrl/wp-admin/authorize-application.php";

final log = Logger("main.dart");
late LoginManager loginManager;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  dateFormattingInitialization = Future.delayed(const Duration(seconds: 0))
      .then((_) => Future.wait([
            initializeDateFormatting("nl_NL"),
            initializeDateFormatting("en_GB")
          ]));

  // GoogleFonts.config.allowRuntimeFetching = false;

  // Seems like LicenseRegistry is not available in my current version of Flutter =/
  //
  LicenseRegistry.addLicense(() async* {
    final license2 = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license2);

    final license = await rootBundle.loadString('assets/fonts/RobotoMono/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // LicenseRegistry.addLicense(() async* {
  //   final license = await rootBundle.loadString('LICENSE');
  //   yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license);
  // });
  // .then((_) => Future.value());
  // .then((_) => runApp(const MyApp()));
  loginManager = LoginManager();
  runApp(const MyApp());
}

// Go router code based on https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
// and https://pub.dev/packages/go_router/example

// Navigation bar code based on https://api.flutter.dev/flutter/material/NavigationBar-class.html

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();
final _eventSpecNavigatorKey = GlobalKey<NavigatorState>();

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

    loginState = widget.loginController._loadingState;

    listenerFunc = () {
      setState(() {
        loginState = widget.loginController._loadingState;
      });
    };

    widget.loginController.addListener(listenerFunc);
    widget.loginController.loadProfiles();
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
    // return const Text("test");
    // return const Column(children: [Text("test")]);

    // return Row(children: [
    //   Expanded(child: Text("test_leading")),
    // ListView(
    //   shrinkWrap: true,
    //   children: [const Text("test1")])
    // ]);

    return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
      SliverList(
          delegate: SliverChildListDelegate(<Widget>[
        Row(
          children: [
            if (snapshot.data?.activeProfileName != null)
              // TextOverflow(
              //     // overflow: TextOverflow.ellipsis,
              //     children: [Text(
              //         "Hoi ${snapshot.data!.activeProfile!['user']}!")]);
              // Expanded(child: Text("Hoi ${snapshot.data?.activeProfile?['user']}!",
              //     overflow: TextOverflow.ellipsis))
              Expanded(
                  child: Row(children: [
                Flexible(child: Text("Hoi ${snapshot.data?.activeProfile?['user']}",
                    overflow: TextOverflow.ellipsis)),
                const Text("!")
              ]))
            else
              const Expanded(child: Text("Not logged in!")),
            // Text("Hoi $username!"),
            // const Spacer(),
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
                      // loginManager.eraseProfiles();
                      widget.loginController.logout();
                      widget.loginController._loadingState.then((value) {
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
                    // setState(() {
                    //   loginManager.scheduleLogin();
                    // });
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
                // createHighlightOverlay(alignment: AlignmentDirectional.bottomStart, borderColor: Colors.red);
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
                              // constraints: const BoxConstraints(minWidth: 200),
                              // child: const Text("test")
                              // child: ListView(children: [const Text("test")],)
                              child: buildLoginMenu(context, snapshot)
                              // Container(
                              //     // mainAxisSize: MainAxisSize.min,
                              //     // mainAxisAlignment:
                              //     //     MainAxisAlignment.start,
                              //     // crossAxisAlignment: CrossAxisAlignment.end,
                              //     children: <Widget>[
                              //       const Text(
                              //           'This is a typical dialog.'),
                              //       const SizedBox(height: 15),
                              //       TextButton(
                              //         onPressed: () {
                              //           Navigator.pop(context);
                              //         },
                              //         child: const Text('Close'),
                              //       ),
                              //     ])
                              ));

                      // title: const Text("Test"),
                      // content: const Text("Test"),
                      // actions: <Widget>[
                      //   TextButton(onPressed: () {
                      //     Navigator.of(context).pop();
                      //   }, child: const Text("OK"))
                      // ],
                      // );
                    });
              });
        });
    //   MenuAnchor(
    //       builder: (BuildContext context, MenuController controller,
    //           Widget? child) {
    //         return IconButton(
    //           onPressed: () {
    //             if (controller.isOpen) {
    //               controller.close();
    //             } else {
    //               controller.open();
    //             }
    //           },
    //           icon: CircleAvatar(backgroundColor: Colors.blue),
    //           tooltip: "Profile",
    //         );
    //       },
    //       // menuChildren: List<MenuItemButton>.generate(10,
    //       //   (int index) => MenuItemButton(
    //       //     onPressed: () =>
    //       //         setState(() => selectedMenu = SampleItem.values[index]),
    //       //     child: Text('Item ${index + 1}'),
    //       //   ),
    //       // )
    //       menuChildren: <MenuItemButton>[
    //         MenuItemButton(
    //           onPressed: () =>
    //               setState(() => selectedMenu = SampleItem.itemOne),
    //           child: Text('Item 1'),
    //         ),
    //         MenuItemButton(
    //           onPressed: () =>
    //               setState(() => selectedMenu = SampleItem.itemTwo),
    //           child: Text('Item 2'),
    //         ),
    //         MenuItemButton(
    //           onPressed: () =>
    //               setState(() => selectedMenu = SampleItem.itemThree),
    //           child: Text('Item 3'),
    //         ),
    //       ]
    //       // icon:
    //       // itemBuilder: (BuildContext context) {
    //       //   return <PopupMenuEntry>[
    //       //     const PopupMenuItem(
    //       //       child: Text("Test"),
    //       //     )
    //       //   ];
    //       )
    //
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: navigationShell,
    //   bottomNavigationBar: BottomNavigationBar(
    //     currentIndex: navigationShell.currentIndex,
    //     items: const [
    //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    //       BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shope'),
    //     ],
    //     onTap: _onTap,
    //   ),
    // );

    // var pages = ["/", "/feed", "/info"];
    // print("Current page is ${widget.currentPage}");
    // int currentPageIndex = pages.indexOf(widget.currentPage);
    // if (currentPageIndex == -1) {
    //   currentPageIndex = 0;
    // }

    return Preferences(
        locale: "nl_NL",
        child: APIAccess(
            state: loginState,
            // profileName: loginManager.activeProfileName,
            // profile: loginManager.activeProfile,
            // connector: loginManager.connector,
            // state: loginManager.state,
            // controller: loginManager,
            // child: LoginContext(
            child: Scaffold(
                bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (int index) {
                    // setState(() {
                    //   currentPageIndex = index;
                    // });
                    // context.go(pages[index]);
                    _onTap(index);
                  },
                  selectedIndex: (({
                    0: 0,
                    1: 1,
                    2: 2,
                    3: 0
                  })[widget.navigationShell.currentIndex]!),
                  destinations: const <Widget>[
                    // NavigationDestination(
                    //   icon: Icon(Icons.home),
                    //   label: 'Home',
                    //   selectedIcon: Icon(Icons.home_filled),
                    // ),
                    NavigationDestination(
                      icon: Icon(Icons.event_outlined),
                      // icon: Icon(Symbols.calendar_month),
                      label: 'Activities',
                      selectedIcon: Icon(Icons.event),
                    ),
                    // NavigationDestination(
                    //   icon: Icon(Icons.person),
                    //   label: 'Profile',
                    //   selectedIcon: Icon(Icons.person_outline),
                    // ),
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
                        // if (canPop)
                        // if (_sectionNavigatorKey.currentState != null
                        // && _sectionNavigatorKey.currentState!.canPop())
                        // BackButton(),
                        // (cont) {
                        //   BuildContext? navContext = _rootNavigatorKey.currentContext;

                        // if (navContext != null && false && navContext.canPop()) {
                        //                             return SizedBox();
                        //   return (
                        BackButton(onPressed: () {
                          // Navigator.maybePop(context);
                          // context.pop();
                          if (GoRouterState.of(context)
                              .matchedLocation
                              .startsWith("/event/")) {
                            // context.go("/");
                            // _router.go("/");
                            // _router.go("/feed");
                            router.go("/");
                            // _sectionNavigatorKey.currentContext!.go("/");
                            return;
                          }

                          // if (_rootNavigatorKey.currentContext!.canPop()) {
                          //   _rootNavigatorKey.currentContext!.pop();
                          // }
                          // if(_router.canPop()) {
                          //   _router.pop();
                          // }
                        }),
                        // );
                        //   // widget.
                        // }
                        // return SizedBox();
                        // }(context),
                        Text(widget.title),
                        const Spacer(),
                        // Text("Test")
                        // OverlayEntry(builder:
                        // Positioned.directional(
                        //   textDirection: Directionality.of(outerContext),
                        //   top: 0,
                        //   start: 0,
                        //   child: Directionality()
                        // )),
                        buildLoginIcon(context)
                      ],
                    )),
                // body: <Widget>[
                //   const ActivitiesPage(),
                //   // const Text("Profile"),
                //   const Placeholder(),
                //   const InfoPage()
                //   // DebugPage()
                // ][currentPageIndex],
                // body: Stack(children: widget.pages.map<int, Widget>((key, value) => key == currentPageIndex ? MapEntry(key, value) : MapEntry(key, Offstage(child: value))).values.toList())// [currentPageIndex]
                body: widget.navigationShell
                // body: Stack(
                //     children: pages
                //         .map<int, Widget>((key, value) => MapEntry(
                //             key,
                //             Offstage(
                //                 offstage: key != currentPageIndex,
                //                 child: value)))
                //         .values
                //         .toList()) // [currentPageIndex]
                // floatingActionButton: FloatingActionButton(
                //   onPressed: _incrementCounter,
                //   tooltip: 'Increment',
                //   child: const Icon(Icons.add),
                // ), // This trailing comma makes auto-formatting nicer for build methods.
                )));
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

final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _authScreensNav = GlobalKey<NavigatorState>();
final GlobalKey<_ActivitiesPageState> _activitiesPageKey =
    GlobalKey<_ActivitiesPageState>();
final GlobalKey<NavigatorState> _infoNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  // navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        // builder: (context, state, navigationShell) => Padding(padding: const EdgeInsets.all(64), child: navigationShell),
        builder: (context, state, navigationShell) => navigationShell,
        branches: [
          StatefulShellBranch(
              // navigatorKey: _authScreensNav,
              initialLocation: "/login",
              routes: <RouteBase>[
                GoRoute(
                  path: '/authorize',
                  builder: (context, state) =>
                      AuthorizePage(params: state.uri.queryParameters),
                ),
                GoRoute(
                  // parentNavigatorKey: _authScreensNav,
                  path: '/login',
                  builder: (context, state) =>
                      LoginPage(params: state.uri.queryParameters),
                ),
                GoRoute(
                  // parentNavigatorKey: _authScreensNav,
                  path: '/new-login',
                  builder: (context, state) =>
                      NewLoginPage(params: state.uri.queryParameters),
                ),
              ]),
          StatefulShellBranch(
              // navigatorKey: _mainScreensNav,
              routes: [
                StatefulShellRoute.indexedStack(
                    builder: (context, state, navigationShell) {
                      return ScaffoldWithNavbar(
                          loginController: loginManager,
                          navigationShell,
                          currentPage: state.matchedLocation,
                          title: "SIB-Utrecht");
                    },
                    branches: [
                      StatefulShellBranch(
                          // navigatorKey: _sectionNavigatorKey,
                          initialLocation: '/',
                          routes: <RouteBase>[
                            GoRoute(
                              path: '/',
                              builder: (context, state) =>
                                  ActivitiesPage(key: _activitiesPageKey),
                            ),
                          ]),
                      StatefulShellBranch(routes: <RouteBase>[
                        GoRoute(
                            path: '/feed',
                            builder: (context, state) => const Placeholder()),
                      ]),
                      StatefulShellBranch(
                          // navigatorKey: _infoNavigatorKey,
                          routes: <RouteBase>[
                            GoRoute(
                                path: '/info',
                                // parentNavigatorKey: _infoNavigatorKey,
                                builder: (context, state) => const InfoPage()),
                          ]),
                      StatefulShellBranch(
                          // navigatorKey: _eventSpecNavigatorKey,
                          initialLocation: "/event/0",
                          routes: <RouteBase>[
                            GoRoute(
                                path: '/event/:event_id',
                                builder: (context, state) {
                                  int? eventId;
                                  if (state.pathParameters
                                      .containsKey('event_id')) {
                                    eventId = int.tryParse(
                                        state.pathParameters['event_id']!);
                                  }
                                  return EventPage(
                                      eventId: eventId,
                                      key: ValueKey("event/$eventId"));
                                })
                          ])
                      // StatefulShellBranch(initialLocation: "/event/1", routes: <RouteBase>[
                      //   GoRoute(
                      //       path: "/event/:event_id",
                      //       builder: (context, state) {
                      //         int? eventId;
                      //         if (state.pathParameters.containsKey('event_id')) {
                      //           eventId = int.tryParse(state.pathParameters['event_id']!);
                      //         }
                      //         return EventPage(eventId: eventId);
                      //       })
                      // ]),
                    ])
              ])
        ])
    // GoRoute(
    //     path: "feed",
    //     builder: (BuildContext context, GoRouterState state) {
    //       return const Placeholder();
    //     }),
    // GoRoute(
    //   path: 'info',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const InfoPage();
    //   },
    // ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: router,
        title: 'Flutter Demo',
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
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: true);
  }
}

class Preferences extends InheritedWidget {
  const Preferences({super.key, required super.child, required this.locale});

  final String locale;

  static Preferences? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Preferences>();
  }

  static Preferences of(BuildContext context) {
    final Preferences? result = maybeOf(context);
    assert(result != null, 'No Preferences found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Preferences old) => locale != old.locale;
}
