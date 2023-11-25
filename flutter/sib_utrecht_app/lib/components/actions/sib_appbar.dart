import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/actions/action_provider.dart';
import 'package:sib_utrecht_app/components/actions/appbar_suppression.dart';

import '/globals.dart';
import '/model/login_state.dart';
import '/components/api_access.dart';

import '/shell.dart';

class WithSIBAppBar extends StatelessWidget {
  final List<Widget> actions;
  final Widget child;
  final bool showBackButton;
  // final ActionsController actionsCollection = ActionsController();

  const WithSIBAppBar(
      {Key? key,
      required this.actions,
      required this.child,
      this.showBackButton = true})
      : super(key: key);

  static bool isBackActionAvailable(BuildContext context) {
    String? backAddress = getBackAddress(context);

    bool isActive = backAddress != null ||
        Navigator.of(context).canPop() ||
        router.canPop();
    return isActive;
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
        // const SizedBox(height: 15),
        // Row(children: [
        //   const Text("SIB color in app bar"),
        //   const Spacer(),
        //   Switch(
        //       value: MyApp._getState(context)?.useSibColorInStatusBar == true,
        //       onChanged: (val) {
        //         MyApp.setUseSibColorInStatusBar(context, val);
        //       }),
        // ]),
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
                    child: Text(
                        AppLocalizations.of(context)!.gotoSwitchAccountPage)
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
                  child: Text(AppLocalizations.of(context)!.actionLogIn),
                ),
              ])
            : ([])),
        ...((snapshot.hasError)
            ? ([const SizedBox(height: 15), Text("Error: ${snapshot.error}")])
            : ([])),
      ]))
    ]);
  }

  static String? getBackAddress(BuildContext context) {
    GoRouterState routerState = GoRouterState.of(context);

    // String matchedLocation = routerState.matchedLocation;

    // String? path = routerState.path;
    // log.info("[getBackAddress] path: $path");
    // log.info("[getBackAddress] fullPath: ${routerState.fullPath}");
    // log.info("[getBackAddress] matchedLocation: $matchedLocation");

    String? backAddress = {
      "/event/:event_id": "/",
      "/management": "/info",
      "/management/groups": "/management",
      "/api-debug": "/management",
      "/info": "/",
      "/feed": "/",
      "/": null
    }[routerState.fullPath];

    return backAddress;

    // if (matchedLocation.startsWith("/event/")) {
    //   return "/";
    // }
    // if (matchedLocation == "/management") {
    //   return "/info";
    // }

    // return null;
  }

  Widget buildBackButton() => Builder(builder: (context) {
        String? backAddress = getBackAddress(context);

        // bool isActive = backAddress != null ||
        //     Navigator.of(context).canPop() ||
        //     router.canPop();
        // if (!isActive) {
        //   return const SizedBox();
        // }

        return BackButton(
          onPressed: () {
            log.info("Back button pressed");
            log.info("backAddress: $backAddress");
            log.info("Navigator canPop: ${Navigator.of(context).canPop()}");
            log.info("router canPop: ${router.canPop()}");
            log.info("GoRouter canPop: ${GoRouter.of(context).canPop()}");

            if (backAddress != null) {
              router.go(backAddress);
              return;
            }

            if (router.canPop()) {
              router.pop();
              return;
            }

            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
              return;
            }

            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
          },
        );
      });

  Widget buildLoginIcon(BuildContext context) {
    Future<LoginState> loginState = APIAccess.of(context).state;
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

  @override
  Widget build(BuildContext context) {
    AppbarSuppression? suppression = AppbarSuppression.maybeOf(context);

    // ActionProvider(
    // controller: actionsCollection,
    // child:
    // Builder(
    //     builder: (context) => ListenableBuilder(
    //         listenable: ActionProvider.of(context).controller,
    //         builder: (context, child) =>
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            leading: (showBackButton && suppression?.suppressBackbutton != true)
                ? buildBackButton()
                : null,
            title: suppression?.suppressTitle == true
                ? null
                : Row(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // buildBackButton(),
                      Image.asset(
                        'assets/sib_logo_64.png',
                        fit: BoxFit.contain,
                        height: 40,
                        filterQuality: FilterQuality.medium,
                      ),
                      const SizedBox(width: 16),
                      // Text(widget.title),
                      const Text("SIB-Utrecht (Bèta)")
                      // const Spacer(),
                    ],
                  ),
            actions: [
              // ...ActionProvider.of(context).controller.widgets,
              ...actions,
              if (suppression?.suppressMenu != true) buildLoginIcon(context)
            ]),
        body: child);
    // child: child)))
  }
}
