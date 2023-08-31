import 'dart:async';
import 'dart:convert';

// import 'package:christmas2022_management/evadePresenceDetector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

part 'api_connector.dart';
part 'pages/activities.dart';
part 'pages/debug.dart';
part 'pages/info.dart';

void main() {
  initializeDateFormatting("nl_NL", null)
      .then((_) => initializeDateFormatting("en_GB"))
      .then((_) => runApp(const MyApp()));
  // runApp(const MyApp());
}

// TODO https://pub.dev/packages/go_router/example

// Navigation bar code based on https://api.flutter.dev/flutter/material/NavigationBar-class.html

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      debugShowCheckedModeBanner: true,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum SampleItem { itemOne, itemTwo, itemThree }

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  SampleItem? selectedMenu;

  @override
  void initState() {
    super.initState();
  }

  void createHighlightOverlay({
    required AlignmentDirectional alignment,
    required Color borderColor,
  }) {
    // Remove the existing OverlayEntry.
    // removeHighlightOverlay();

    // assert(overlayEntry == null);

    var overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return SafeArea(
          child: Align(
            alignment: alignment,
            heightFactor: 1.0,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Tap here for'),
                  Builder(builder: (BuildContext context) {
                    switch (currentPageIndex) {
                      case 0:
                        return const Column(
                          children: <Widget>[
                            Text(
                              'Explore page',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward,
                              color: Colors.red,
                            ),
                          ],
                        );
                      case 1:
                        return const Column(
                          children: <Widget>[
                            Text(
                              'Commute page',
                              style: TextStyle(
                                color: Colors.green,
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward,
                              color: Colors.green,
                            ),
                          ],
                        );
                      case 2:
                        return const Column(
                          children: <Widget>[
                            Text(
                              'Saved page',
                              style: TextStyle(
                                color: Colors.orange,
                              ),
                            ),
                            Icon(
                              Icons.arrow_downward,
                              color: Colors.orange,
                            ),
                          ],
                        );
                      default:
                        return const Text('No page selected.');
                    }
                  }),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    height: 80.0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: borderColor,
                            width: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Preferences(
        locale: "nl_NL",
        child: Scaffold(
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
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
                label: 'Activities',
                selectedIcon: Icon(Icons.event),
              ),
              // NavigationDestination(
              //   icon: Icon(Icons.person),
              //   label: 'Profile',
              //   selectedIcon: Icon(Icons.person_outline),
              // ),
              NavigationDestination(
                icon: Icon(Icons.view_timeline_outlined),
                label: 'Timeline',
                selectedIcon: Icon(Icons.view_timeline),
              ),
              NavigationDestination(
                icon: Icon(Icons.tab_outlined),
                label: "Info",
                selectedIcon: Icon(Icons.tab),
              )
            ],
          ),
          appBar: AppBar(
              // TRY THIS: Try changing the color here to a specific color (to
              // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
              // change color while the other colors stay the same.
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              title: Row(children: <Widget>[
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
                ElevatedButton(onPressed: () {
                  createHighlightOverlay(alignment: AlignmentDirectional.bottomStart, borderColor: Colors.red);
                }, child: const Text("AA")),
                MenuAnchor(
                  builder: (BuildContext context, MenuController controller, Widget? child) {
                    return IconButton(onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: CircleAvatar(backgroundColor: Colors.blue),
                    tooltip: "Profile",
                    );
                  },
                  // menuChildren: List<MenuItemButton>.generate(10,
                  //   (int index) => MenuItemButton(
                  //     onPressed: () =>
                  //         setState(() => selectedMenu = SampleItem.values[index]),
                  //     child: Text('Item ${index + 1}'),
                  //   ),
                  // )
                  menuChildren: <MenuItemButton> [
                    MenuItemButton(
                      onPressed: () =>
                          setState(() => selectedMenu = SampleItem.itemOne),
                      child: Text('Item 1'),
                    ),
                    MenuItemButton(
                      onPressed: () =>
                          setState(() => selectedMenu = SampleItem.itemTwo),
                      child: Text('Item 2'),
                    ),
                    MenuItemButton(
                      onPressed: () =>
                          setState(() => selectedMenu = SampleItem.itemThree),
                      child: Text('Item 3'),
                    ),
                  ]
                    // icon: 
                    // itemBuilder: (BuildContext context) {
                    //   return <PopupMenuEntry>[
                    //     const PopupMenuItem(
                    //       child: Text("Test"),
                    //     )
                    //   ];
                  )
              ])),
          body: <Widget>[
            const ActivitiesPage(),
            // const Text("Profile"),
            const Placeholder(),
            const InfoPage()
            // DebugPage()
          ][currentPageIndex],
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _incrementCounter,
          //   tooltip: 'Increment',
          //   child: const Icon(Icons.add),
          // ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
