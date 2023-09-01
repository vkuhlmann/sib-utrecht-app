import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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

part 'login_context.dart';
part 'api_connector.dart';
part 'pages/activities.dart';
part 'pages/debug.dart';
part 'pages/info.dart';

late Future<void> dateFormattingInitialization;
const String WORDPRESS_URL = "http://192.168.50.200/wordpress";
const String API_URL = "$WORDPRESS_URL/wp-json/sib-utrecht-wp-plugin/v1";
const String AUTHORIZE_APP_URL =
    "$WORDPRESS_URL/wp-admin/authorize-application.php";

void main() {
  dateFormattingInitialization = Future.wait([
    initializeDateFormatting("nl_NL", null),
    initializeDateFormatting("en_GB")
  ]);
  // .then((_) => runApp(const MyApp()));
  runApp(const MyApp());
}

// Go router code based on https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
// and https://pub.dev/packages/go_router/example

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

// TODO https://pub.dev/packages/go_router/example

class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar(this.navigationShell,
      {Key? key, required this.title, required this.currentPage})
      : super(key: key);

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;
  final String title;
  final String currentPage;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  // _ScaffoldWithNavbarState({super.key});

  // int currentPageIndex = 0;
  late LoginManager loginManager;

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

  @override
  void initState() {
    super.initState();

    loginManager = LoginManager();
  }

  Widget buildLoginMenu(
      BuildContext context, AsyncSnapshot<LoginState> snapshot) {
    return CustomScrollView(shrinkWrap: true, slivers: <Widget>[
      SliverList(
          delegate: SliverChildListDelegate(<Widget>[
        Row(
          children: [
            if (snapshot.data?.activeProfileName != null)
              Text("Hoi ${snapshot.data!.activeProfile!['user']}!")
            else
              const Text("Not logged in!"),
            // Text("Hoi $username!"),
            const Spacer(),
            const CircleAvatar(backgroundColor: Colors.blue)
          ],
        ),
        SizedBox(height: 15),
        const Text("test"),
        ...((snapshot.data?.activeProfileName != null)
            ? ([
                SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      loginManager.eraseProfiles();
                    });
                  },
                  child: const Text('Logout'),
                ),
              ])
            : ([])),
        ...((snapshot.data?.activeProfileName == null)
            ? ([
                SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      loginManager.scheduleLogin();
                    });
                  },
                  child: const Text('Login'),
                ),
              ])
            : ([])),
        ...((snapshot.hasError)
            ? ([SizedBox(height: 15), Text("Error: ${snapshot.error}")])
            : ([])),
      ]))
    ]);
  }

  Widget buildLoginIcon(BuildContext context) {
    return FutureBuilder(
        future: loginManager.state,
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

    var pages = ["/", "/feed", "/info"];
    print("Current page is ${widget.currentPage}");
    int currentPageIndex = pages.indexOf(widget.currentPage);
    if (currentPageIndex == -1) {
      currentPageIndex = 0;
    }

    return Preferences(
        locale: "nl_NL",
        child: APIAccess(
            // profileName: loginManager.activeProfileName,
            // profile: loginManager.activeProfile,
            // connector: loginManager.connector,
            state: loginManager.state,
            // child: LoginContext(
            child: Scaffold(
                bottomNavigationBar: NavigationBar(
                  onDestinationSelected: (int index) {
                    setState(() {
                      currentPageIndex = index;
                    });
                    context.go(pages[index]);
                  },
                  selectedIndex: currentPageIndex,
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

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavbar(navigationShell,
              currentPage: state.fullPath ?? "/", title: "SIB-Utrecht");
        },
        branches: [
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/feed',
                builder: (context, state) => const Placeholder()),
          ]),
          StatefulShellBranch(routes: <RouteBase>[
            GoRoute(
                path: '/info', builder: (context, state) => const InfoPage()),
          ]),
          StatefulShellBranch(
              navigatorKey: _sectionNavigatorKey,
              routes: <RouteBase>[
                GoRoute(
                  path: '/',
                  builder: (context, state) => const ActivitiesPage(),
                )
              ]),
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

// Navigation bar code based on https://api.flutter.dev/flutter/material/NavigationBar-class.html

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routerConfig: _router,
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
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

    // return MaterialApp(
    //   title: 'Flutter Demo',
    //   theme: ThemeData(
    //     // This is the theme of your application.
    //     //
    //     // TRY THIS: Try running your application with "flutter run". You'll see
    //     // the application has a blue toolbar. Then, without quitting the app,
    //     // try changing the seedColor in the colorScheme below to Colors.green
    //     // and then invoke "hot reload" (save your changes or press the "hot
    //     // reload" button in a Flutter-supported IDE, or press "r" if you used
    //     // the command line to start the app).
    //     //
    //     // Notice that the counter didn't reset back to zero; the application
    //     // state is not lost during the reload. To reset the state, use hot
    //     // restart instead.
    //     //
    //     // This works for code too, not just values: Most code changes can be
    //     // tested with just a hot reload.
    //     colorScheme: ColorScheme.fromSeed(
    //         seedColor: Colors.deepPurple, brightness: Brightness.light),
    //     useMaterial3: true,
    //     brightness: Brightness.light,
    //   ),
    //   darkTheme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(
    //         seedColor: Colors.deepPurple, brightness: Brightness.dark),
    //     useMaterial3: true,
    //     brightness: Brightness.dark,
    //   ),
    //   themeMode: ThemeMode.dark,
    //   debugShowCheckedModeBanner: true,
    //   home: const MyHomePage(title: 'Flutter Demo Home Page'),
    // );
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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // final Map<int, Widget> pages = [
//   //   // const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
//   //   const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
//   //   const Placeholder(),
//   //   const InfoPage(key: PageStorageKey('InfoPage')),
//   //   // const DebugPage(key: PageStorageKey('DebugPage')),
//   // ].asMap();

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// enum SampleItem { itemOne, itemTwo, itemThree }

// class _MyHomePageState extends State<MyHomePage> {
//   int currentPageIndex = 0;
//   late LoginManager loginManager;

//   // List<Key> pageKeys = [
//   //   const PageStorageKey('ActivitiesPage'),
//   //   const PageStorageKey('InfoPage'),
//   //   const PageStorageKey('DebugPage'),
//   // ];

//   final Map<int, Widget> pages = [
//     // const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
//     const ActivitiesPage(key: PageStorageKey('ActivitiesPage')),
//     const Placeholder(),
//     const InfoPage(key: PageStorageKey('InfoPage')),
//     // const DebugPage(key: PageStorageKey('DebugPage')),
//   ].asMap();

//   // SampleItem? selectedMenu;

//   @override
//   void initState() {
//     super.initState();
//     loginManager = LoginManager();
//   }

//   // void createHighlightOverlay({
//   //   required AlignmentDirectional alignment,
//   //   required Color borderColor,
//   // }) {
//   //   // Remove the existing OverlayEntry.
//   //   // removeHighlightOverlay();

//   //   // assert(overlayEntry == null);

//   //   var overlayEntry = OverlayEntry(
//   //     // Create a new OverlayEntry.
//   //     builder: (BuildContext context) {
//   //       // Align is used to position the highlight overlay
//   //       // relative to the NavigationBar destination.
//   //       return SafeArea(
//   //         child: Align(
//   //           alignment: AlignmentDirectional.topEnd.add(const Alignment(0, 0.1)),
//   //           heightFactor: 1.0,
//   //           child: DefaultTextStyle(
//   //             style: const TextStyle(
//   //               color: Colors.blue,
//   //               fontWeight: FontWeight.bold,
//   //               fontSize: 14.0,
//   //             ),
//   //             child: Column(
//   //               mainAxisSize: MainAxisSize.min,
//   //               children: <Widget>[
//   //                 const Text('Tap here for'),
//   //                 Builder(builder: (BuildContext context) {
//   //                   switch (currentPageIndex) {
//   //                     case 0:
//   //                       return const Column(
//   //                         children: <Widget>[
//   //                           Text(
//   //                             'Explore page',
//   //                             style: TextStyle(
//   //                               color: Colors.red,
//   //                             ),
//   //                           ),
//   //                           Icon(
//   //                             Icons.arrow_downward,
//   //                             color: Colors.red,
//   //                           ),
//   //                         ],
//   //                       );
//   //                     case 1:
//   //                       return const Column(
//   //                         children: <Widget>[
//   //                           Text(
//   //                             'Commute page',
//   //                             style: TextStyle(
//   //                               color: Colors.green,
//   //                             ),
//   //                           ),
//   //                           Icon(
//   //                             Icons.arrow_downward,
//   //                             color: Colors.green,
//   //                           ),
//   //                         ],
//   //                       );
//   //                     case 2:
//   //                       return const Column(
//   //                         children: <Widget>[
//   //                           Text(
//   //                             'Saved page',
//   //                             style: TextStyle(
//   //                               color: Colors.orange,
//   //                             ),
//   //                           ),
//   //                           Icon(
//   //                             Icons.arrow_downward,
//   //                             color: Colors.orange,
//   //                           ),
//   //                         ],
//   //                       );
//   //                     default:
//   //                       return const Text('No page selected.');
//   //                   }
//   //                 }),
//   //                 SizedBox(
//   //                   width: MediaQuery.of(context).size.width / 3,
//   //                   height: 80.0,
//   //                   child: Center(
//   //                     child: Container(
//   //                       decoration: BoxDecoration(
//   //                         border: Border.all(
//   //                           color: borderColor,
//   //                           width: 4.0,
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );

//   //   // Add the OverlayEntry to the Overlay.
//   //   Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // return ScaffoldWithNavbar(navigationShell)

//     // return Preferences(
//     //     locale: "nl_NL",
//     //     child: APIAccess(
//     //         // profileName: loginManager.activeProfileName,
//     //         // profile: loginManager.activeProfile,
//     //         // connector: loginManager.connector,
//     //         state: loginManager.state,
//     //         // child: LoginContext(
//     //         child: Scaffold(
//     //             bottomNavigationBar: NavigationBar(
//     //               onDestinationSelected: (int index) {
//     //                 setState(() {
//     //                   currentPageIndex = index;
//     //                 });
//     //                 context.go(["/", "/feed", "/info"][index]);
//     //               },
//     //               selectedIndex: currentPageIndex,
//     //               destinations: const <Widget>[
//     //                 // NavigationDestination(
//     //                 //   icon: Icon(Icons.home),
//     //                 //   label: 'Home',
//     //                 //   selectedIcon: Icon(Icons.home_filled),
//     //                 // ),
//     //                 NavigationDestination(
//     //                   icon: Icon(Icons.event_outlined),
//     //                   // icon: Icon(Symbols.calendar_month),
//     //                   label: 'Activities',
//     //                   selectedIcon: Icon(Icons.event),
//     //                 ),
//     //                 // NavigationDestination(
//     //                 //   icon: Icon(Icons.person),
//     //                 //   label: 'Profile',
//     //                 //   selectedIcon: Icon(Icons.person_outline),
//     //                 // ),
//     //                 NavigationDestination(
//     //                   icon: Icon(Icons.timeline_outlined),
//     //                   label: 'Feed',
//     //                   selectedIcon: Icon(Icons.timeline),
//     //                 ),
//     //                 NavigationDestination(
//     //                   icon: Icon(Icons.tab_outlined),
//     //                   label: "Info",
//     //                   selectedIcon: Icon(Icons.tab),
//     //                 )
//     //               ],
//     //             ),
//     //             appBar: AppBar(
//     //                 backgroundColor:
//     //                     Theme.of(context).colorScheme.inversePrimary,
//     //                 title: Row(
//     //                   children: <Widget>[
//     //                     Text(widget.title),
//     //                     const Spacer(),
//     //                     // Text("Test")
//     //                     // OverlayEntry(builder:
//     //                     // Positioned.directional(
//     //                     //   textDirection: Directionality.of(outerContext),
//     //                     //   top: 0,
//     //                     //   start: 0,
//     //                     //   child: Directionality()
//     //                     // )),
//     //                     FutureBuilder(
//     //                         future: loginManager.state,
//     //                         builder: (context, snapshot) {
//     //                           Color backgroundColor = Colors.grey;
//     //                           if (snapshot.hasData) {
//     //                             backgroundColor = Colors.white;
//     //                             if (snapshot.data?.activeProfileName != null) {
//     //                               backgroundColor = Colors.blue;
//     //                             }
//     //                           }

//     //                           if (snapshot.hasError) {
//     //                             backgroundColor = Colors.red;
//     //                           }

//     //                           return IconButton(
//     //                               icon: CircleAvatar(
//     //                                   backgroundColor: backgroundColor),
//     //                               onPressed: () {
//     //                                 // createHighlightOverlay(alignment: AlignmentDirectional.bottomStart, borderColor: Colors.red);
//     //                                 showDialog(
//     //                                     context: context,
//     //                                     builder: (BuildContext context) {
//     //                                       return Dialog(
//     //                                           alignment:
//     //                                               AlignmentDirectional.topEnd,
//     //                                           insetPadding:
//     //                                               const EdgeInsets.fromLTRB(
//     //                                                   16, 70, 16, 16),
//     //                                           child: Container(
//     //                                               padding:
//     //                                                   const EdgeInsets.fromLTRB(
//     //                                                       16, 16, 16, 32),
//     //                                               width: 200,
//     //                                               // child: const Text("test")
//     //                                               // child: ListView(children: [const Text("test")],)
//     //                                               child: CustomScrollView(
//     //                                                   shrinkWrap: true,
//     //                                                   slivers: <Widget>[
//     //                                                     SliverList(
//     //                                                         delegate:
//     //                                                             SliverChildListDelegate(<Widget>[
//     //                                                       Row(
//     //                                                         children: [
//     //                                                           if (snapshot.data
//     //                                                                   ?.activeProfileName !=
//     //                                                               null)
//     //                                                             Text(
//     //                                                                 "Hoi ${snapshot.data!.activeProfile!['user']}!")
//     //                                                           else
//     //                                                             const Text(
//     //                                                                 "Not logged in!"),
//     //                                                           // Text("Hoi $username!"),
//     //                                                           const Spacer(),
//     //                                                           const CircleAvatar(
//     //                                                               backgroundColor:
//     //                                                                   Colors
//     //                                                                       .blue)
//     //                                                         ],
//     //                                                       ),
//     //                                                       SizedBox(height: 15),
//     //                                                       const Text("test"),
//     //                                                       ...((snapshot.data
//     //                                                                   ?.activeProfileName !=
//     //                                                               null)
//     //                                                           ? ([
//     //                                                               SizedBox(
//     //                                                                   height:
//     //                                                                       15),
//     //                                                               TextButton(
//     //                                                                 onPressed:
//     //                                                                     () {
//     //                                                                   Navigator.pop(
//     //                                                                       context);
//     //                                                                   setState(
//     //                                                                       () {
//     //                                                                     loginManager
//     //                                                                         .eraseProfiles();
//     //                                                                   });
//     //                                                                 },
//     //                                                                 child: const Text(
//     //                                                                     'Logout'),
//     //                                                               ),
//     //                                                             ])
//     //                                                           : ([])),
//     //                                                       ...((snapshot.data
//     //                                                                   ?.activeProfileName ==
//     //                                                               null)
//     //                                                           ? ([
//     //                                                               SizedBox(
//     //                                                                   height:
//     //                                                                       15),
//     //                                                               TextButton(
//     //                                                                 onPressed:
//     //                                                                     () {
//     //                                                                   Navigator.pop(
//     //                                                                       context);
//     //                                                                   setState(
//     //                                                                       () {
//     //                                                                     loginManager
//     //                                                                         .scheduleLogin();
//     //                                                                   });
//     //                                                                 },
//     //                                                                 child: const Text(
//     //                                                                     'Login'),
//     //                                                               ),
//     //                                                             ])
//     //                                                           : ([])),
//     //                                                       ...((snapshot
//     //                                                               .hasError)
//     //                                                           ? ([
//     //                                                               SizedBox(
//     //                                                                   height:
//     //                                                                       15),
//     //                                                               Text(
//     //                                                                   "Error: ${snapshot.error}")
//     //                                                             ])
//     //                                                           : ([])),
//     //                                                     ]))
//     //                                                   ])
//     //                                               // Container(
//     //                                               //     // mainAxisSize: MainAxisSize.min,
//     //                                               //     // mainAxisAlignment:
//     //                                               //     //     MainAxisAlignment.start,
//     //                                               //     // crossAxisAlignment: CrossAxisAlignment.end,
//     //                                               //     children: <Widget>[
//     //                                               //       const Text(
//     //                                               //           'This is a typical dialog.'),
//     //                                               //       const SizedBox(height: 15),
//     //                                               //       TextButton(
//     //                                               //         onPressed: () {
//     //                                               //           Navigator.pop(context);
//     //                                               //         },
//     //                                               //         child: const Text('Close'),
//     //                                               //       ),
//     //                                               //     ])
//     //                                               ));

//     //                                       // title: const Text("Test"),
//     //                                       // content: const Text("Test"),
//     //                                       // actions: <Widget>[
//     //                                       //   TextButton(onPressed: () {
//     //                                       //     Navigator.of(context).pop();
//     //                                       //   }, child: const Text("OK"))
//     //                                       // ],
//     //                                       // );
//     //                                     });
//     //                               });
//     //                         }),
//     //                     //   MenuAnchor(
//     //                     //       builder: (BuildContext context, MenuController controller,
//     //                     //           Widget? child) {
//     //                     //         return IconButton(
//     //                     //           onPressed: () {
//     //                     //             if (controller.isOpen) {
//     //                     //               controller.close();
//     //                     //             } else {
//     //                     //               controller.open();
//     //                     //             }
//     //                     //           },
//     //                     //           icon: CircleAvatar(backgroundColor: Colors.blue),
//     //                     //           tooltip: "Profile",
//     //                     //         );
//     //                     //       },
//     //                     //       // menuChildren: List<MenuItemButton>.generate(10,
//     //                     //       //   (int index) => MenuItemButton(
//     //                     //       //     onPressed: () =>
//     //                     //       //         setState(() => selectedMenu = SampleItem.values[index]),
//     //                     //       //     child: Text('Item ${index + 1}'),
//     //                     //       //   ),
//     //                     //       // )
//     //                     //       menuChildren: <MenuItemButton>[
//     //                     //         MenuItemButton(
//     //                     //           onPressed: () =>
//     //                     //               setState(() => selectedMenu = SampleItem.itemOne),
//     //                     //           child: Text('Item 1'),
//     //                     //         ),
//     //                     //         MenuItemButton(
//     //                     //           onPressed: () =>
//     //                     //               setState(() => selectedMenu = SampleItem.itemTwo),
//     //                     //           child: Text('Item 2'),
//     //                     //         ),
//     //                     //         MenuItemButton(
//     //                     //           onPressed: () =>
//     //                     //               setState(() => selectedMenu = SampleItem.itemThree),
//     //                     //           child: Text('Item 3'),
//     //                     //         ),
//     //                     //       ]
//     //                     //       // icon:
//     //                     //       // itemBuilder: (BuildContext context) {
//     //                     //       //   return <PopupMenuEntry>[
//     //                     //       //     const PopupMenuItem(
//     //                     //       //       child: Text("Test"),
//     //                     //       //     )
//     //                     //       //   ];
//     //                     //       )
//     //                     //
//     //                   ],
//     //                 )),
//     //             // body: <Widget>[
//     //             //   const ActivitiesPage(),
//     //             //   // const Text("Profile"),
//     //             //   const Placeholder(),
//     //             //   const InfoPage()
//     //             //   // DebugPage()
//     //             // ][currentPageIndex],
//     //             // body: Stack(children: widget.pages.map<int, Widget>((key, value) => key == currentPageIndex ? MapEntry(key, value) : MapEntry(key, Offstage(child: value))).values.toList())// [currentPageIndex]
//     //             body: Stack(
//     //                 children: pages
//     //                     .map<int, Widget>((key, value) => MapEntry(
//     //                         key,
//     //                         Offstage(
//     //                             offstage: key != currentPageIndex,
//     //                             child: value)))
//     //                     .values
//     //                     .toList()) // [currentPageIndex]
//     //             // floatingActionButton: FloatingActionButton(
//     //             //   onPressed: _incrementCounter,
//     //             //   tooltip: 'Increment',
//     //             //   child: const Icon(Icons.add),
//     //             // ), // This trailing comma makes auto-formatting nicer for build methods.
//     //             )));
//   }
// }
