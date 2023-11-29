import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/appbar_suppression.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/event/thumbnail.dart';
import 'package:sib_utrecht_app/components/dual_screen-1.0.4/lib/dual_screen.dart';
import 'package:sib_utrecht_app/pages/confidants.dart';
import 'package:sib_utrecht_app/pages/group_members.dart';
import 'package:sib_utrecht_app/pages/groups.dart';
import 'package:sib_utrecht_app/pages/user_page.dart';

import 'shell.dart';
import 'globals.dart';
import 'components/dialog_page.dart';
import 'pages/events.dart';
import 'pages/info.dart';
import 'pages/event.dart';
import 'pages/login.dart';
import 'pages/new_login.dart';
import 'pages/api_debug.dart';
import 'pages/management.dart';
import 'pages/edit_event.dart';

/// Go router code based on https://medium.com/@antonio.tioypedro1234/flutter-go-router-the-essential-guide-349ef39ec5b3
// and https://pub.dev/packages/go_router/example

final GoRouter router = createRouter();

// GoRouter.optionURLReflectsImperativeAPIs = true;

GoRouter createRouter() {
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final rootNavigatorKey = GlobalKey<NavigatorState>();
// final _sectionNavigatorKey = GlobalKey<NavigatorState>();
// final _eventSpecNavigatorKey = GlobalKey<NavigatorState>();

// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _authScreensNav = GlobalKey<NavigatorState>();
// final GlobalKey<_EventsPageState> _eventsPageKey =
//     GlobalKey<_EventsPageState>();
// final GlobalKey<NavigatorState> _infoNavigatorKey = GlobalKey<NavigatorState>();
// final GlobalKey<NavigatorState> _mainScreensNav = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
      // StatefulShellRoute.indexedStack(
      //     // builder: (context, state, navigationShell) => Padding(padding: const EdgeInsets.all(64), child: navigationShell),
      //     // builder: (context, state, navigationShell) =>
      //     //   Localizations.override(context: context, locale: const Locale("nl", "NL"), child: navigationShell)
      //     // ,
      //     builder: (context, state, navigationShell) => navigationShell
      //     // WillPopScope(
      //     //   onWillPop: () async {
      //     //     log.info("Master WillPopScope received onWillPop");
      //     //     // Navigator.pop(context);
      //     //     return false;
      //     //   },
      //     //   child: Padding(padding: const EdgeInsets.all(16), child: navigationShell)
      //     // )
      //     ,
      //     branches: [
      // StatefulShellBranch(
      //     // navigatorKey: _authScreensNav,
      //     initialLocation: "/login",
      //     routes: <RouteBase>[
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
      // ]),
      // StatefulShellBranch(
      //     // navigatorKey: _mainScreensNav,
      //     routes: [
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            log.info("Building indexed stack @@@@@@@@@@");
            return ScaffoldWithNavbar(
              loginController: loginManager,
              navigationShell,
              currentPage: state.matchedLocation,
              // title: "SIB-Utrecht (Bèta)"
            );
          },
          branches: [
            StatefulShellBranch(
                // navigatorKey: _sectionNavigatorKey,
                initialLocation: '/',
                routes: <RouteBase>[
                  GoRoute(
                    path: '/',
                    builder: (context, state) => const EventsPage(),
                  ),
                  ShellRoute(
                      builder: (context, state, child) {
                        bool isDetailsPriority = true;
                        log.info("Shell route child is $child");

                        return TwoPane(
                          startPane:
                              const EventsPage(key: ValueKey("eventsPage")),
                          endPane: Builder(builder: (context) {
                            bool suppress = true;

                            // suppress = MediaQuery.of(context).size

                            suppress = TwoPaneResolution.maybeOf(context)
                                    ?.resolvedPanePriority ==
                                TwoPanePriority.both;

                            return AppbarSuppression(
                                suppressTitle: suppress,
                                suppressMenu: suppress,
                                suppressBackbutton: suppress,
                                child: child);
                          }),
                          paneProportion: 0.5,
                          panePriority: MediaQuery.sizeOf(context).width > 1000
                              ? TwoPanePriority.both
                              : (isDetailsPriority
                                  ? TwoPanePriority.end
                                  : TwoPanePriority.start),
                        );
                      },
                      routes: [
                        GoRoute(
                            path: '/event/:event_id',
                            builder: (context, state) {
                              int? eventId;
                              if (state.pathParameters
                                  .containsKey('event_id')) {
                                eventId = int.tryParse(
                                    state.pathParameters['event_id']!);
                              }

                              if (eventId == null) {
                                router.go("/");
                                return const Center(
                                  child: Text("Invalid event id"),
                                );
                              }

                              // return EventsDoublePage(
                              //     eventId: eventId,
                              //     isDetailsPriority: true,
                              //     key: ValueKey("event_double/$eventId"));

                              return EventPage(
                                  eventId: eventId,
                                  key: ValueKey("event/$eventId"));
                            },
                            routes: [
                              GoRoute(
                                  path: 'edit',
                                  name: "event_edit",
                                  builder: (context, state) {
                                    int? eventId;
                                    // if (state.pathParameters
                                    //     .containsKey('event_id')) {
                                    //   eventId = int.tryParse(
                                    //       state.pathParameters['event_id']!);
                                    // }
                                    String? eventIdStr =
                                        state.pathParameters['event_id'];

                                    if (eventIdStr != "new" &&
                                        eventIdStr != null) {
                                      eventId = int.tryParse(eventIdStr);
                                    }

                                    return EventEditPage(
                                        eventId: eventId,
                                        key: ValueKey("event/$eventId/edit"));
                                  },
                                  routes: [
                                    GoRoute(
                                      path: 'delete',
                                      name: "event_delete_confirm",
                                      pageBuilder: (BuildContext context,
                                          GoRouterState state) {
                                        return DialogPage(
                                            // builder: (_) => AboutDialog()
                                            builder: (_) => AlertDialog(
                                                  title: const Text(
                                                      'Event deletion'),
                                                  content: const Text(
                                                      'Are you sure you want to delete the event?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          // Navigator.pop(
                                                          //         context);
                                                          router.pop(
                                                              "delete_confirmed");
                                                        },
                                                        child: const Text(
                                                            'Delete')),
                                                    TextButton(
                                                        onPressed: () {
                                                          // Navigator.pop(
                                                          //         context);
                                                          router.pop();
                                                        },
                                                        child: const Text(
                                                            'Cancel'))
                                                  ],
                                                ));
                                        // builder: (_) => ThumbnailImageDialog(
                                        //     url: state.uri
                                        //             .queryParameters["url"]
                                        //         as String));
                                      },
                                    )
                                  ]),
                              GoRoute(
                                path: 'image',
                                name: "event_image_dialog",
                                pageBuilder: (BuildContext context,
                                    GoRouterState state) {
                                  return DialogPage(
                                      // builder: (_) => AboutDialog()
                                      builder: (_) => ThumbnailImageDialog(
                                          url: state.uri.queryParameters["url"]
                                              as String));
                                },
                              )
                            ])
                      ])
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
                  ShellRoute(
                    builder: (context, state, child) => 
                    WithSIBAppBar(actions: [], child: child),
                    routes: [
                  GoRoute(
                      path: '/info',
                      // parentNavigatorKey: _infoNavigatorKey,
                      builder: (context, state) => const InfoPage(),
                      routes: [
                        GoRoute(
                          path: 'confidants',
                          // parentNavigatorKey: _infoNavigatorKey,
                          builder: (context, state) => const ConfidantsPage(),
                        ),
                        GoRoute(
                          path: 'committees',
                          // parentNavigatorKey: _infoNavigatorKey,
                          builder: (context, state) => const GroupMembersPage(
                            groupName: "committees",
                          ),
                        ),
                        GoRoute(
                          name: "group_members",
                          path: 'groups/@:group_name/members',
                          // parentNavigatorKey: _infoNavigatorKey,
                          builder: (context, state) => GroupMembersPage(
                            groupName: state.pathParameters["group_name"]!,
                          ),
                        ),
                        GoRoute(
                          path: 'societies',
                          // parentNavigatorKey: _infoNavigatorKey,
                          builder: (context, state) => const GroupMembersPage(
                            groupName: "societies",
                          ),
                        ),
                        GoRoute(
                          path: 'board',
                          builder: (context, state) => const GroupMembersPage(
                            groupName: "boards",
                          ),
                        ),
                      ]),
                  GoRoute(
                    path: '/api-debug',
                    builder: (context, state) => const APIDebugPage(),
                  ),
                  GoRoute(
                    path: '/management',
                    builder: (context, state) => const ManagementPage(),
                  ),
                  GoRoute(
                    path: '/management/groups',
                    builder: (context, state) => const GroupsPage(),
                  ),
                    ]),

                        GoRoute(
                          name: "user_page",
                          path: '/users/@:entity_name',
                          // parentNavigatorKey: _infoNavigatorKey,
                          builder: (context, state) => UserPage(
                            entityName: state.pathParameters["entity_name"]!,
                          ),
                        ),
                ]),
            // StatefulShellBranch(
            //     // navigatorKey: _eventSpecNavigatorKey,
            //     initialLocation: "/event/0",
            //     routes: <RouteBase>[

            //     ])
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
            // ])
          ])
      // ])
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
}
