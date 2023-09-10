part of '../main.dart';

class NewLoginPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const NewLoginPage({Key? key, required this.params}) : super(key: key);

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  int activeStep = 0;

  bool step1Done = false;
  bool step2Done = false;
  Future<void>? step3Result;

  bool completed = false;

  final ExpansionTileController _step1Expansion = ExpansionTileController();
  final ExpansionTileController _step2Expansion = ExpansionTileController();
  final ExpansionTileController _step3Expansion = ExpansionTileController();

  final RegExp applicationPasswordFormat =
      RegExp("^([a-zA-Z0-9]{4} ){5}[a-zA-Z0-9]{4}\$");

  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _authorizationUrlController =
      TextEditingController();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _applicationPasswordController =
      TextEditingController();

  final Icon startIcon = const Icon(Icons.start);
  final Icon doneIcon = const Icon(Icons.done, color: Colors.green);

  bool useRedirect = true;
  late Uri authorizationUrl;
  late String authorizationUrlDisplay;

  bool _step2IsUsernameNonEmpty = false;
  bool _step2IsPasswordComplete = false;

  Future<void>? _step3Substep1;
  Future<void>? _step3Substep2;

  int nextLoginAttempt = 0;
  int? activeLoginAttempt;

  @override
  void initState() {
    super.initState();

    String disp;
    Uri url;

    useRedirect = loginManager.canLoginByRedirect;

    (disp, url) = loginManager.getAuthorizationUrl(withRedirect: useRedirect);

    authorizationUrlDisplay = disp;
    authorizationUrl = url;

    log.info("params are ${jsonEncode(widget.params)}");

    bool isSuccess = widget.params["success"] != "false" &&
        widget.params["user_login"] != null;
    log.info("isSuccess: $isSuccess");

    _apiUrlController.text = widget.params["api_url"] ?? defaultApiUrl;

    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          step1Done = true;
        });

        _step1Expansion.collapse();
        _step2Expansion.expand();

        _usernameController.text = widget.params["user_login"];
        _applicationPasswordController.text = widget.params["password"];

        trySubmit();
      });
    }
  }

  Widget buildSteps(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          buildStep1(context),
          buildStep2(context),
          buildStep3(context),
        ])
      ]);

  Widget buildStep1(BuildContext context) => Card(
        child: ExpansionTile(
            title: const Text("Step 1: Create a new application password"),
            controller: _step1Expansion,
            leading: step1Done ? doneIcon : startIcon,
            initiallyExpanded: !step1Done,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(8),
                  child: Column(children: [
                    if (Preferences.of(context).debugMode) ...[
                      TextField(
                          controller: _apiUrlController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'API url')),
                      // const SizedBox(height: 16),
                      // TextField(
                      //   controller: _authorizationUrlController,
                      //   decoration: const InputDecoration(
                      //     border: OutlineInputBorder(),
                      //     labelText: 'Authorization URL'),
                      //   onChanged: (value) {
                      //     setState(() {
                      //       try {
                      //         authorizationUrl = Uri.parse(value);
                      //         authorizationUrlDisplay = value;
                      //         useRedirect = false;
                      //       } catch(e){
                      //         log.warning("Invalid URL");
                      //       }
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 16),
                    ],
                    if (!useRedirect)
                      const Text("Open the following link on any device:"),
                    if (useRedirect) const Text("Open the following link:"),
                    ElevatedButton(
                      onPressed: () {
                        launchUrl(authorizationUrl);
                        // (
                        //     "https://sib-utrecht.nl/wp-admin/profile.php?page=application-passwords");
                        // },
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.open_in_browser_outlined,
                                size: 20),
                            const SizedBox(width: 5),
                            Text(authorizationUrlDisplay.toString())
                          ]),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                        onPressed: step1Done
                            ? null
                            : () {
                                setState(() {
                                  step1Done = true;
                                  _step1Expansion.collapse();
                                  _step2Expansion.expand();
                                });
                              },
                        child: const Text("Done")),
                    if (useRedirect) ...[
                      const SizedBox(height: 10),
                      TextButton(
                          child: const Text(
                              "Authorize via a different device or browser.",
                              style: TextStyle(fontSize: 10)),
                          onPressed: () {
                            setState(() {
                              String disp;
                              Uri url;
                              (disp, url) = loginManager.getAuthorizationUrl(
                                  withRedirect: false);
                              setState(() {
                                authorizationUrlDisplay = disp;
                                authorizationUrl = url;
                                authorizationUrlDisplay = "sib-utrecht.nl/app";
                                useRedirect = false;
                              });
                            });
                          })
                    ],
                  ])),
            ]),
      );

  List<TextInputFormatter> getWordPressAppPasswordFormatter() => [
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (RegExp("^([a-zA-Z0-9]{4} ){,5}[a-zA-Z0-9]{,4}\$")
              .hasMatch(newValue.text)) {
            return newValue;
          }
          if (RegExp("[^a-zA-Z0-9 ]").hasMatch(newValue.text)) {
            return oldValue;
          }

          String newText = newValue.text;

          // Fix delete button before space
          if (newValue.selection == oldValue.selection &&
              newValue.selection.extentOffset ==
                  newValue.selection.baseOffset &&
              oldValue.text[newValue.selection.baseOffset] == " " &&
              newValue.text ==
                  (oldValue.text.substring(0, newValue.selection.baseOffset) +
                      oldValue.text
                          .substring(newValue.selection.baseOffset + 1)) &&
              oldValue.text.length >= newValue.selection.baseOffset + 2) {
            newText =
                oldValue.text.substring(0, newValue.selection.baseOffset) +
                    oldValue.text.substring(newValue.selection.baseOffset + 2);
          }

          String reduced = newText.replaceAll(" ", "");
          if (reduced.length > 24) {
            return oldValue;
          }

          TextSelection newSelection = TextSelection(
            baseOffset: RegExp("[^ ]")
                .allMatches(
                    newValue.text.substring(0, newValue.selection.baseOffset))
                .length,
            extentOffset: RegExp("[^ ]")
                .allMatches(
                    newValue.text.substring(0, newValue.selection.extentOffset))
                .length,
          );

          bool leadingPosition = newValue.text.length >= oldValue.text.length &&
              reduced.isNotEmpty &&
              reduced.length < 24;

          List<String> segments = [];
          for (int i = 0; i < reduced.length; i += 4) {
            segments.add(reduced.substring(i, min(i + 4, reduced.length)));
          }
          newText = segments.join(" ");

          if (leadingPosition && reduced.length % 4 == 0) {
            newText += " ";
          }

          mapNewPos(int oldPos) {
            int newPos = oldPos;
            int group = newPos ~/ 4;
            if (!leadingPosition && group > 0 && newPos % 4 == 0) {
              group -= 1;
            }
            return newPos + group;
          }

          newSelection = newSelection.copyWith(
              baseOffset: mapNewPos(newSelection.baseOffset),
              extentOffset: mapNewPos(newSelection.extentOffset));
          return newValue.copyWith(text: newText, selection: newSelection);
        }),
      ];

  bool trySubmit() {
    final String username = _usernameController.value.text;
    final String applicationPassword =
        _applicationPasswordController.value.text;
    final String apiUrl = _apiUrlController.value.text;

    if (!applicationPasswordFormat.hasMatch(applicationPassword)) {
      return false;
    }

    setState(() {
      _step2IsPasswordComplete = true;
    });

    if (username.isEmpty) {
      return false;
    }

    log.info("Attempting login");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cancelStep3();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        int thisLoginAttempt = ++nextLoginAttempt;

        activeLoginAttempt = thisLoginAttempt;

        setState(() {
          step1Done = true;
          step2Done = true;

          _step1Expansion.collapse();
          _step2Expansion.collapse();
          _step3Expansion.expand();

          _step3Substep1 = null;
          _step3Substep2 = null;
          step3Result = null;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            step3Result =
                Future.delayed(const Duration(seconds: 0)).then((value) async {
              // throw Exception("This is a test");

              if (activeLoginAttempt != thisLoginAttempt) {
                throw Exception("Login attempt has been cancelled");
              }

              Future<LoginState> stFut = loginManager._completeLogin(
                  user: username,
                  apiSecret: applicationPassword,
                  apiAddress: apiUrl);
              setState(() {
                _step3Substep1 = stFut;
              });

              LoginState st = await stFut;

              if (activeLoginAttempt != thisLoginAttempt) {
                throw Exception("Login attempt has been cancelled");
              }

              Future<void> testConnection() async {
                // throw Exception("Test aborting");
                var result = await st.connector.get("events");
                if (result["data"]?["events"] == null) {
                  throw Exception("Could not load events");
                }
              }

              Future<void> substep2 = testConnection();

              setState(() {
                _step3Substep2 = substep2;
              });

              await substep2;

              if (activeLoginAttempt != thisLoginAttempt) {
                throw Exception("Login attempt has been cancelled");
              }

              setState(() {
                completed = true;
              });
            }).whenComplete(() {
              if (activeLoginAttempt == thisLoginAttempt) {
                activeLoginAttempt = null;
              }
            }).catchError((e) {
              if (e.toString().contains("Unkown username")) {
                _step2Expansion.expand();
              }

              throw e;
            });
          });
        });
      });
    });

    return true;
  }

  void cancelStep3() {
    setState(() {
      activeLoginAttempt = null;

      step3Result = null;
      _step3Substep1 = null;
      _step3Substep2 = null;
    });
  }

  Widget buildStep2(BuildContext context) => Card(
          child: Focus(
        onFocusChange: (value) {
          if (!value) {
            return;
          }
          attemptFillAppPasswordFromClipboard();
        },
        child: ExpansionTile(
          title: const Text("Step 2: Enter application password"),
          controller: _step2Expansion,
          leading: step2Done
              ? doneIcon
              : (step1Done ? startIcon : const Icon(Icons.schedule)),
          initiallyExpanded: step1Done,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'E-mail',
                        errorText: (_step2IsPasswordComplete &&
                                !_step2IsUsernameNonEmpty)
                            ? "Your username (e-mail) is required"
                            : null),
                    onChanged: (value) {
                      if (value.isNotEmpty != _step2IsUsernameNonEmpty) {
                        setState(() {
                          _step2IsUsernameNonEmpty = value.isNotEmpty;
                        });
                      }

                      if (activeLoginAttempt == null) {
                        cancelStep3();
                        setState(() {
                          step2Done = false;
                        });
                      }
                    },
                    onSubmitted: (value) {
                      log.fine("Received onSubmitted from username field");
                      trySubmit();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _applicationPasswordController,
                    style: const TextStyle(fontFamily: 'RobotoMono'),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Application password',
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: getWordPressAppPasswordFormatter(),
                    obscureText: false,
                    onChanged: (value) {
                      cancelStep3();
                      setState(() {
                        step2Done = false;
                        _step2IsPasswordComplete = false;
                      });

                      trySubmit();
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                      onPressed: (_step2IsPasswordComplete &&
                              _usernameController.text.isNotEmpty)
                          ? () {
                              cancelStep3();
                              trySubmit();
                            }
                          : null,
                      child: const Text("Done"))
                ])),
          ],
        ),
      ));

  Widget getLeading(AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return const Icon(Icons.error);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      return doneIcon;
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
          width: 16, height: 16, child: CircularProgressIndicator());
    }

    return const Icon(Icons.schedule);
  }

  Widget getStep3Leading(AsyncSnapshot<void> snapshot) {
    if (step2Done && snapshot.connectionState == ConnectionState.none) {
      return startIcon;
    }

    return getLeading(snapshot);
  }

  Widget buildStep3(BuildContext context) => Card(
      child: FutureBuilderPatched(
          future: step3Result,
          builder: (context, snapshot) {
            return ExpansionTile(
              title: const Text("Step 3: Connection test"),
              controller: _step3Expansion,
              leading: getStep3Leading(snapshot),
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                    child: Column(
                      children: [
                        FutureBuilderPatched(
                            future: _step3Substep1,
                            builder: (context, snapshot) => ListTile(
                                leading: getLeading(snapshot),
                                title: const Text("Store credentials"))),
                        FutureBuilderPatched(
                            future: _step3Substep2,
                            builder: (context, snapshot) => ListTile(
                                leading: getLeading(snapshot),
                                title: const Text("Test access"))),
                        (snapshot.hasError)
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: ListTile(
                                    leading: const Icon(Icons.error,
                                        color: Colors.redAccent),
                                    title: formatError(snapshot.error)))
                            : const SizedBox(),
                        const SizedBox(height: 10),
                        OutlinedButton(
                            onPressed: (snapshot.connectionState ==
                                    ConnectionState.active)
                                ? (() {
                                    cancelStep3();
                                  })
                                : null,
                            child: const Text("Cancel"))
                      ],
                    ))
              ],
            );
          }));

  Future<bool> attemptFillAppPasswordFromClipboard() async {
    if (step2Done) {
      return false;
    }
    if (_step2IsPasswordComplete) {
      return false;
    }

    log.fine("Attempting fill password from clipboard");
    ClipboardData? data;
    try {
      data = await Clipboard.getData("text/plain");
    } catch (e) {
      return false;
    }

    String? text = data?.text;
    if (text == null) {
      log.fine("No text on clipboard");
      return false;
    }

    if (!applicationPasswordFormat.hasMatch(text)) {
      log.fine("Clipboard data is no application password");
      return false;
    }

    log.fine("Found application password in clipboard data");
    setState(() {
      _applicationPasswordController.text = text;
    });
    trySubmit();
    return true;
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

  Widget buildFocus() => Builder(
      builder: (context) => ListView(shrinkWrap: true, children: [
            buildSteps(context),
            if (completed) buildCompletedPrompt()
          ]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(children: [
          BackButton(
            onPressed: () {
              router.go("/login?immediate=false");
            },
          ),
          const Text('New login')
        ])),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                constraints: const BoxConstraints.expand(),
                child: Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: buildFocus())))));
  }
}
