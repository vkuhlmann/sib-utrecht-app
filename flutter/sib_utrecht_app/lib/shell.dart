import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sib_utrecht_app/components/resource_pool_access.dart';

import 'globals.dart';
import 'model/login_manager.dart';
import 'model/login_state.dart';
import 'components/api_access.dart';

import 'main.dart';

import 'theme_fallback.dart' if (dart.library.html) 'theme_web.dart';

// Navigation bar code based on https://api.flutter.dev/flutter/material/NavigationBar-class.html

class ScaffoldWithNavbar extends StatefulWidget {
  const ScaffoldWithNavbar(this.navigationShell,
      {Key? key,
      // required this.title,
      required this.currentPage,
      required this.loginController})
      : super(key: key);

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;
  // final String title;
  final String currentPage;

  final LoginManager loginController;

  // final BuildContext? rootContext = _rootNavigatorKey.currentContext;

  @override
  State<ScaffoldWithNavbar> createState() => _ScaffoldWithNavbarState();
}

class _ScaffoldWithNavbarState extends State<ScaffoldWithNavbar> {
  // List<Key> pageKeys = [
  //   const PageStorageKey('ActivitiesPage'),
  //   const PageStorageKey('InfoPage'),
  //   const PageStorageKey('DebugPage'),
  // ];

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

  Widget buildWide(Widget child) {
    return Builder(
        builder: (context) => Scaffold(
            // bottomNavigationBar: NavigationBar(
            //   onDestinationSelected: _onDestinationSelected,
            //   selectedIndex: selectedIndex,
            //   destinations: destinations,
            // ),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            // backgroundColor: Colors.white,
            // appBar: SIBAppBar(actions: []),
            body: SafeArea(
                child: Container(
                    color: Theme.of(context).colorScheme.background,
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
                      Expanded(child: child)
                    ])))));
  }

  Widget buildMobile(Widget child) {
    return Builder(
        builder: (context) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: _onDestinationSelected,
              selectedIndex: selectedIndex,
              destinations: getDestinations(context),
            ),
            // appBar: AppBar(
            //     backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            //     leading: buildBackButton(),
            //     title:
            //     // Text("AA"),
            //      Row(
            //       children: <Widget>[
            //         // BackButton(),
            //         // buildBackButton(),
            //         // BackButton(onPressed: () {
            //         //   // Navigator.maybePop(context);
            //         //   // context.pop();
            //         //   if (GoRouterState.of(context)
            //         //       .matchedLocation
            //         //       .startsWith("/event/")) {
            //         //     // context.go("/");
            //         //     // _router.go("/");
            //         //     // _router.go("/feed");
            //         //     GoRouter.of(context).go("/");
            //         //     // _sectionNavigatorKey.currentContext!.go("/");
            //         //     return;
            //         //   }
            //         Image.asset(
            //           'assets/sib_logo_64.png',
            //           fit: BoxFit.contain,
            //           height: 40,
            //           filterQuality: FilterQuality.medium,
            //         ),
            //         const SizedBox(width: 16),
            //         Text(widget.title),
            //         // const Spacer(),
            //         // buildLoginIcon(context)
            //       ],
            //     ),
            //     actions: [
            //       buildLoginIcon(context)
            //     ],
            //     ),
            body: SafeArea(
                child: Container(
                    color: Theme.of(context).colorScheme.background,
                    child: child))));
  }

  @override
  Widget build(BuildContext context) {
    Super(Widget child) => Builder(
        builder: (context) => MediaQuery.sizeOf(context).width > 800
            ? buildWide(child)
            : buildMobile(child));

    // return APIAccess(
    //     state: loginState,
    //     // child: buildMobile()
    //     // child: WithSIBAppBar(
    //     //     actions: [
    //     //       IconButton(onPressed: () {

    //     //       }, icon: const Icon(Icons.refresh))
    //     //     ],
    //     child: ResourcePoolProvider(
    //         child: ));

    return Super(
        // APIAccess(
        //   state: loginState,
        //   child:
        ResourcePoolProvider(
      state: loginState,

      // TODO add channel name
      channelName: null,
      child: widget.navigationShell,
    ));
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
          // inversePrimary: effectiveUseSibColorInStatusBar ? sibColor : null,
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
            // surface: Colors.green,
            // surface: Colors.black
            // surfaceTint: Colors.greenAccent,
            // surfaceVariant: Colors.lightGreen
            // tertiaryContainer: Colors.red
            // primary: Colors.grey[800],
            // inverseSurface: sibColor
          ).copyWith(),
          useMaterial3: true,
          brightness: Brightness.dark,
          filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom().copyWith(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)))))
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
    // if (isDark != false) {
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarColor: appbarColor,
    //     statusBarIconBrightness: Brightness.light,
    //     statusBarBrightness: Brightness.dark,
    //     systemNavigationBarColor: Colors.black,
    //     systemNavigationBarDividerColor: Colors.black,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //   ));
    // }
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
                  title: 'SIB-Utrecht (Bèta)',
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
                  debugShowCheckedModeBanner: false,
                  // locale: Preferences.of(context).locale,
                  locale: isDutch == true
                      ? const Locale('nl', 'NL')
                      : (isDutch == false ? const Locale('en', 'GB') : null),
                  themeMode: useDarkTheme == null
                      ? ThemeMode.system
                      : (useDarkTheme ? ThemeMode.dark : ThemeMode.light),
                )));
  }
}
