part of 'main.dart';

// Go router code based on https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
// and https://pub.dev/packages/go_router/example

final _rootNavigatorKey = GlobalKey<NavigatorState>();
// final _sectionNavigatorKey = GlobalKey<NavigatorState>();
// final _eventSpecNavigatorKey = GlobalKey<NavigatorState>();


// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _authScreensNav = GlobalKey<NavigatorState>();
final GlobalKey<_ActivitiesPageState> _activitiesPageKey =
    GlobalKey<_ActivitiesPageState>();
// final GlobalKey<NavigatorState> _infoNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
                        initialLocation: "/info",
                          // navigatorKey: _infoNavigatorKey,
                          routes: <RouteBase>[
                            GoRoute(
                                path: '/info',
                                // parentNavigatorKey: _infoNavigatorKey,
                                builder: (context, state) => const InfoPage()),

                            GoRoute(
                              path: '/api-debug',
                              builder: (context, state) =>
                                  const APIDebugPage(),
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

