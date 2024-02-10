import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/services.dart';

import '../utils.dart';
import '../globals.dart';
import '../constants.dart';
import '../model/login_state.dart';
import '../view_model/async_patch.dart';

import '../shell.dart';
import '../main.dart';

class ActivatePage extends StatefulWidget {
  final String activationCode;
  final Map<String, dynamic> params;

  const ActivatePage(
      {super.key, required this.activationCode, required this.params});

  @override
  State<ActivatePage> createState() => _ActivatePageState();
}

class _ActivatePageState extends State<ActivatePage> {
  bool completed = false;

  // final RegExp applicationPasswordFormat =
  //     RegExp("^([a-zA-Z0-9]{4} ){5}[a-zA-Z0-9]{4}\$");

  // final TextEditingController _apiUrlController = TextEditingController();

  // final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _applicationPasswordController =
  //     TextEditingController();

  // bool useRedirect = true;
  bool advancedMode = false;

  Future<void>? activateRequest;

  Future<LoginState> doActivateRequest() async {
    if (!mounted) {
      throw Exception("Not mounted");
    }

    log.fine("Activate parameters are ${widget.params}");

    final apiAddress = (widget.params["api_address"] ??
        "https://sib-utrecht.nl/wp-json/sib-utrecht-wp-plugin");
    final String activationCode = widget.activationCode;

    final conn = HTTPApiConnector(apiAddress: apiAddress);

    final result = await conn.post("/activate", version: ApiVersion.v1, body: {
      "token": activationCode,
    });

    final userLogin = result["data"]["user_login"];
    final password = result["data"]["password"];

    LoginState stFut = await loginManager.completeLogin(
        user: userLogin, apiSecret: password, apiAddress: apiAddress);

    if (mounted) {
      setState(() {
        completed = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        router.go("/");
      });
    }
    return stFut;
  }

  void initiateActivation() {
    // final String activationCode = widget.params["activation_code"];

    setState(() {
      activateRequest = doActivateRequest();
    });
  }

  @override
  void initState() {
    super.initState();

    initiateActivation();
  }

  @override
  void didUpdateWidget(covariant ActivatePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activationCode != widget.activationCode ||
        oldWidget.params["api_address"] != widget.params["api_address"]) {
      initiateActivation();
    }
  }

  Widget buildCompletedPrompt() => Builder(
      builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: FilledButton(
                    onPressed: () {
                      router.go("/");
                    },
                    child: const Text("Go to home screen")))
          ])));

  Widget buildFocus() => Builder(builder: (context) {
        bool isDutch = Localizations.localeOf(context).languageCode == "nl";
        bool isDark = Theme.of(context).brightness == Brightness.dark;

        return ListView(shrinkWrap: true, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: !isDutch
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      MyApp.setDutch(context, !isDutch);
                    },
                    icon: const Icon(Icons.language)),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: isDark
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      MyApp.setDark(context, !isDark);
                    },
                    icon: const Icon(Icons.dark_mode)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FutureBuilderPatched(
              future: activateRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text("Error:"),
                              formatError(snapshot.error)
                            ],
                          ));
                }
                return const SizedBox.shrink();
              }),
          if (completed) buildCompletedPrompt()
        ]);
      });

  @override
  Widget build(BuildContext context) {
    if (Preferences.of(context).debugMode ||
        widget.params["debug"] == "" ||
        widget.params["debug"] == "true") {
      advancedMode = true;
    }

    return WithSIBAppBar(
        actions: const [],
        child: ActionSubscriptionAggregator(
            child: SafeArea(
                child: Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: buildFocus())))));
  }
}
