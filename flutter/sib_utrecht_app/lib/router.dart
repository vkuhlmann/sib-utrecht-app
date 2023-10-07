part of 'main.dart';

// Go router code based on https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
// and https://pub.dev/packages/go_router/example

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _sectionNavigatorKey = GlobalKey<NavigatorState>();
// final _eventSpecNavigatorKey = GlobalKey<NavigatorState>();

// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _authScreensNav = GlobalKey<NavigatorState>();
final GlobalKey<_EventsPageState> _eventsPageKey =
    GlobalKey<_EventsPageState>();
// final GlobalKey<NavigatorState> _infoNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  routes: <RouteBase>[
    // GoRoute(
    //     path: '/aa',
    //     builder: (context, state) => Center(
    //             child: Column(children: [
    //           Text("AA"),
    //           BackButton(),
    //           buildBackButton(),
    //           ElevatedButton(
    //               onPressed: () => router.go("/aa"), child: Text("Go to AA")),
    //           ElevatedButton(
    //               onPressed: () => router.go("/bb"), child: Text("Go to BB")),
    //           ElevatedButton(
    //               onPressed: () => router.go("/cc"), child: Text("Go to CC")),
    //           ElevatedButton(
    //               onPressed: () => router.go("/aa/test"),
    //               child: Text("Go to AA test")),
    //           ElevatedButton(
    //               onPressed: () => router.go("test"),
    //               child: Text("Go to AA test 2")),
    //         ])),
    //     routes: [
    //       GoRoute(
    //           path: 'test',
    //           builder: (context, state) => Center(
    //                   child: Column(children: [
    //                 Text("AA test"),
    //                 BackButton(),
    //                 buildBackButton(),
    //                 ElevatedButton(
    //                     onPressed: () => router.go("/aa"),
    //                     child: Text("Go to AA")),
    //                 ElevatedButton(
    //                     onPressed: () => router.go("/bb"),
    //                     child: Text("Go to BB")),
    //                 ElevatedButton(
    //                     onPressed: () => router.go("/cc"),
    //                     child: Text("Go to CC")),
    //               ])))
    //     ]),
    // GoRoute(
    //     path: '/bb',
    //     builder: (context, state) => Center(
    //           child: Column(children: [
    //             Text("BB"),
    //             BackButton(),
    //             buildBackButton(),
    //             ElevatedButton(
    //                 onPressed: () => router.go("/aa"), child: Text("Go to AA")),
    //             ElevatedButton(
    //                 onPressed: () => router.go("/bb"), child: Text("Go to BB")),
    //             ElevatedButton(
    //                 onPressed: () => router.go("/cc"), child: Text("Go to CC")),
    //             ElevatedButton(
    //                 onPressed: () => router.go("/aa/test"),
    //                 child: Text("Go to AA test")),
    //             ElevatedButton(
    //                 onPressed: () => router.go("test"),
    //                 child: Text("Go to AA test 2")),
    //           ]),
    //         )),
    // GoRoute(
    //   path: '/cc',
    //   builder: (context, state) => Center(
    //       child: Column(children: [
    //     Text("CC"),
    //     BackButton(),
    //     buildBackButton(),
    //     ElevatedButton(
    //         onPressed: () => router.go("/aa"), child: Text("Go to AA")),
    //     ElevatedButton(
    //         onPressed: () => router.go("/bb"), child: Text("Go to BB")),
    //     ElevatedButton(
    //         onPressed: () => router.go("/cc"), child: Text("Go to CC")),
    //   ])),
    // ),
    StatefulShellRoute.indexedStack(
        // builder: (context, state, navigationShell) => Padding(padding: const EdgeInsets.all(64), child: navigationShell),
        // builder: (context, state, navigationShell) =>
        //   Localizations.override(context: context, locale: const Locale("nl", "NL"), child: navigationShell)
        // ,
        builder: (context, state, navigationShell) => navigationShell
        // WillPopScope(
        //   onWillPop: () async {
        //     log.info("Master WillPopScope received onWillPop");
        //     // Navigator.pop(context);
        //     return false;
        //   },
        //   child: Padding(padding: const EdgeInsets.all(16), child: navigationShell)
        // )
        ,
        branches: [
          StatefulShellBranch(
              // navigatorKey: _authScreensNav,
              initialLocation: "/login",
              routes: <RouteBase>[
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
                GoRoute(
                  path: '/new-login2',
                  builder: (context, state) =>
                      NewLogin2Page(params: state.uri.queryParameters),
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
                                  EventsPage(key: _eventsPageKey),
                            ),
                          ]),
                      StatefulShellBranch(routes: <RouteBase>[
                        GoRoute(
                            path: '/feed',
                            builder: (context, state) => const Placeholder()),
                      ]),
                      StatefulShellBranch(
                          initialLocation: "/info",
                          // navigatorKey: _infoNavigatorKey,
                          routes: <RouteBase>[
                            GoRoute(
                                path: '/info',
                                // parentNavigatorKey: _infoNavigatorKey,
                                builder: (context, state) => const InfoPage(),
                            ),
                            GoRoute(
                              path: '/api-debug',
                              builder: (context, state) => const APIDebugPage(),
                            ),
                            GoRoute(
                              path: '/management',
                              builder: (context, state) =>
                                  const ManagementPage(),
                            ),
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
                                },
                                routes: [
                                  GoRoute(
                                    path: 'image',
                                    name: "event_image_dialog",
                                    pageBuilder: (BuildContext context,
                                        GoRouterState state) {
                                      return DialogPage(
                                          // builder: (_) => AboutDialog()
                                          builder: (_) => ThumbnailImageDialog(
                                              url: state.uri
                                                      .queryParameters["url"]
                                                  as String));
                                    },
                                  )
                                ])
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
