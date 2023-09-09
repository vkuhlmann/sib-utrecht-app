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

  // final SelectorConfig phoneSelectorConfig = const SelectorConfig(
  //   showFlags: true,
  // );

  final RegExp applicationPasswordFormat =
      RegExp("^([a-zA-Z0-9]{4} ){5}[a-zA-Z0-9]{4}\$");

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _applicationPasswordController =
      TextEditingController();

  final Icon startIcon = const Icon(Icons.start);
  final Icon doneIcon = const Icon(Icons.done, color: Colors.green);

  bool useRedirect = true;
  late Uri authorizationUrl;
  late String authorizationUrlDisplay;

  Future<bool>? _step1LaunchUrl;

  // String? _step2UsernameError;

  bool _step2IsUsernameNonEmpty = false;
  bool _step2IsPasswordComplete = false;

  Future<void>? _step3_substep1;
  Future<void>? _step3_substep2;

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
    // log.info("condition 1: ${widget.params["success"] != "false"}");
    // log.info("condition 2: ${widget.params["user_login"] != null}");

    bool isSuccess = widget.params["success"] != "false" && widget.params["user_login"] != null;
    log.info("isSuccess: $isSuccess");

    if (isSuccess) {
       
      WidgetsBinding.instance.addPostFrameCallback((_){
        setState(() {
        step1Done = true;
        });

        _step1Expansion.collapse();
        _step2Expansion.expand();

        _usernameController.text = widget.params["user_login"];
        _applicationPasswordController.text = widget.params["password"];

        trySubmit();
      });

      // WidgetsBinding.instance.addPostFrameCallback((_){
      //   log.info("Completing login");
      //   setState(() {
      //     initiatedLogin = loginManager._completeLogin(
      //       user: widget.params["user_login"],
      //       apiSecret: widget.params["password"],
      //     ).then((state) {
      //       router.go("/");
      //       return state;
      //     });
      //   });
      //   log.info("Completed login");
      //   // context.go("/");
      // });
    }
  }

  @override
  Widget buildSteps(BuildContext context) =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        // const Text("Redirecting..."),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // const Icon(Icons.open_in_browser,
          //     size: 100),
          buildStep1(context),
          buildStep2(context),
          buildStep3(context),
          // Card(
          //   child: ListTile(
          //       leading: Icon(Icons.start),
          //       title: const Text("Step 4: ")),
          // ),
          // Card(
          //   child: ListTile(
          //       leading: Icon(Icons.schedule),
          //       title: const Text("Step 3")),
          // )
        ])
      ]);

  @override
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
                    if (!useRedirect)
                      const Text("Open the following link on any device:"),
                    if (useRedirect) const Text("Open the following link:"),
                    ElevatedButton(
                      onPressed: () {
                        _step1LaunchUrl = launchUrl(authorizationUrl);
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
        // LengthLimitingTextInputFormatter(29, maxLengthEnforcement: MaxLengthEnforcement.enforced),
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

          if (leadingPosition
                  // && reduced.isNotEmpty
                  &&
                  reduced.length % 4 == 0
              // && reduced.length < 24
              ) {
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

          // print("newText: $newText");

          // newSelection = newSelection.copyWith(
          //   baseOffset: newValue.selection.baseOffset +
          //         ((newValue.selection.baseOffset - (leadingPosition ? 1 : 0)) ~/ 4),
          //   extentOffset: newValue.selection.extentOffset +
          //         (newValue.selection.extentOffset ~/ 4));
          newSelection = newSelection.copyWith(
              baseOffset: mapNewPos(newSelection.baseOffset),
              extentOffset: mapNewPos(newSelection.extentOffset));
          return newValue.copyWith(text: newText, selection: newSelection);
        }),

        // TextInputFormatter.withFunction((oldValue, newValue) {
        //   print("selection in func1 is [old] ${oldValue.selection}");
        //   print("composing in func1 is [old] ${oldValue.composing}");
        //   print("selection in func1 is ${newValue.selection}");
        //   print("composing in func1 is ${newValue.composing}");
        //   TextSelection newSelection = TextSelection(
        //     baseOffset: RegExp("[^ ]")
        //         .allMatches(
        //             newValue.text.substring(0, newValue.selection.baseOffset))
        //         .length,
        //     extentOffset: RegExp("[^ ]")
        //         .allMatches(
        //             newValue.text.substring(0, newValue.selection.extentOffset))
        //         .length,
        //   );

        //   return newValue.copyWith(
        //       text: newValue.text.replaceAll(" ", ""),
        //       composing: TextRange.empty,
        //       selection: newSelection);
        // }),
        // FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        // LengthLimitingTextInputFormatter(24, maxLengthEnforcement: MaxLengthEnforcement.enforced),
        // TextInputFormatter.withFunction((oldValue, newValue) {
        //   print("selection in func2 is [old] ${oldValue.selection}");
        //   print("composing in func2 is [old] ${oldValue.composing}");
        //   print("selection in func2 is ${newValue.selection}");
        //   print("composing in func2 is ${newValue.composing}");
        //   List<String> segments = [];
        //   for (int i = 0; i < newValue.text.length; i += 4) {
        //     segments.add(newValue.text.substring(i, min(i + 4, newValue.text.length)));
        //   }
        //   String newText = segments.join(" ");
        //   if (
        //     newValue.text.isNotEmpty
        //     && newValue.text.length % 4 == 0
        //     && newValue.text.length < 24
        //   ) {
        //     newText += " ";
        //   }

        //   // print("newText: $newText");

        //   TextSelection newSelection = newValue.selection.copyWith(
        //     baseOffset: newValue.selection.baseOffset +
        //           (newValue.selection.baseOffset ~/ 4),
        //     extentOffset: newValue.selection.extentOffset +
        //           (newValue.selection.extentOffset ~/ 4));
        //   return newValue.copyWith(text: newText, selection: newSelection);
        // })
      ];

  bool trySubmit() {
    final String username = _usernameController.value.text;
    final String applicationPassword =
        _applicationPasswordController.value.text;
    if (!applicationPasswordFormat.hasMatch(applicationPassword)) {
      return false;
    }

    setState(() {
      _step2IsPasswordComplete = true;
    });

    if (username.isEmpty) {
      return false;
    }

    print("Attempting login");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cancelStep3();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        int thisLoginAttempt = ++nextLoginAttempt;

        activeLoginAttempt = thisLoginAttempt;

        // print("Not implemented: connection test verification");
        setState(() {
          step1Done = true;
          step2Done = true;

          _step1Expansion.collapse();
          _step2Expansion.collapse();
          _step3Expansion.expand();

          _step3_substep1 = null;
          _step3_substep2 = null;
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

              Future<LoginState> st_fut = loginManager._completeLogin(
                  user: username, apiSecret: applicationPassword);
              setState(() {
                _step3_substep1 = st_fut;
              });

              LoginState st = await st_fut;

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
                _step3_substep2 = substep2;
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
            // .catchError((e) {
            //   if (activeLoginAttempt == thisLoginAttempt) {
            //     activeLoginAttempt = null;
            //   }
            //   throw e;
            // });
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
      _step3_substep1 = null;
      _step3_substep2 = null;
    });
  }

  @override
  Widget buildStep2(BuildContext context) => Card(
          child: Focus(
        onFocusChange: (value) {
          if (!value) {
            return;
          }
          print("Got focus!!");
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
            // InternationalPhoneNumberInput(
            //   countries: const ["NL", "BE", "DE"],
            //   selectorConfig: phoneSelectorConfig,
            //   onInputChanged: (value) {
            //     print(value);
            //   },
            // )
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
                      print("Received onSubmitted from username field");
                      trySubmit();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _applicationPasswordController,
                    style: const TextStyle(
                        fontFamily: 'RobotoMono'), //GoogleFonts.robotoMono(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Application password',
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    inputFormatters: getWordPressAppPasswordFormatter(),
                    obscureText: false,
                    onChanged: (value) {
                      // print(value);
                      // if (step2Done) {
                      //   setState(() {
                      //     step2Done = false;
                      //     // step3Result = null;
                      //     // cancelStep3();
                      //   });
                      // }

                      cancelStep3();
                      setState(() {
                        step2Done = false;
                        _step2IsPasswordComplete = false;
                      });

                      // if (value.isNotEmpty && _step2IsUsernameNonEmpty) {
                      //   setState(() {
                      //     _step2UsernameError = "Username is required";
                      //   });
                      // }
                      trySubmit();

                      // if (applicationPasswordFormat.hasMatch(value) !=
                      //     step2Done) {
                      //   // setState(() {
                      //   //   step2Done = applicationPasswordFormat.hasMatch(value);
                      //   //   if (step2Done) {
                      //   //     _step2Expansion.collapse();
                      //   //     _step3Expansion.expand();
                      //   //   }
                      //   // });
                      // }
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                      onPressed: (_step2IsPasswordComplete &&
                              _usernameController.text.isNotEmpty)
                          ? () {
                              cancelStep3();
                              trySubmit();

                              // setState(() {
                              //   if () {
                              //     _step2Expansion.collapse();
                              //     _step3Expansion.expand();
                              //   }
                              //   // step1Done = true;
                              //   // _step1Expansion.collapse();
                              //   // _step2Expansion.expand();
                              // });
                            }
                          : null,
                      child: const Text("Done"))
                ])),

            // TextField(
            //   decoration: const InputDecoration(
            //     border: OutlineInputBorder(),
            //     labelText: 'Application password',
            //   ),
            //   obscureText: false,
            //   onChanged: (value) {
            //     print(value);
            //   },
            // )
          ],
        ),
      ));

  @override
  Widget buildStep3(BuildContext context) => Card(
      child: FutureBuilderPatched(
          future: step3Result,
          builder: (context, snapshot) {
            // String? errorMessage;
            // if (snapshot.hasError) {
            //   errorMessage = snapshot.error.toString();

            //   var m = RegExp(
            //           r"^(Exception: )?(<strong>Error:</strong> )?(?<message>.*)$")
            //       .firstMatch(errorMessage);

            //   errorMessage = m?.namedGroup("message") ?? errorMessage;
            // }

            return ExpansionTile(
              title: const Text("Step 3: Connection test"),
              controller: _step3Expansion,
              leading: step2Done
                  ? ((step3Result == null)
                      ? startIcon
                      : snapshot.hasError
                          ? const Icon(Icons.error)
                          : (snapshot.connectionState == ConnectionState.done
                              ? doneIcon
                              : const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: Center(
                                      child: CircularProgressIndicator()))))
                  : const Icon(Icons.schedule),
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                    child: Column(
                      children: [
                        FutureBuilderPatched(
                            future: _step3_substep1,
                            builder: (context, snapshot) {
                              Widget ic = const Icon(Icons.schedule);

                              if (snapshot.hasError) {
                                ic = const Icon(Icons.error);
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.active) {
                                ic = const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }

                              if (!snapshot.hasError && snapshot.connectionState ==
                                  ConnectionState.done) {
                                ic = const Icon(Icons.done);
                              }

                              return ListTile(
                                  leading: ic,
                                  title: const Text("Store credentials"));
                            }),
                        FutureBuilderPatched(
                            future: _step3_substep2,
                            builder: (context, snapshot) {
                              Widget ic = const Icon(Icons.schedule);

                              if (snapshot.hasError) {
                                ic = const Icon(Icons.error);
                              }

                              if (!snapshot.hasError &&
                                  snapshot.connectionState ==
                                      ConnectionState.active) {
                                ic = const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: Center(
                                        child: CircularProgressIndicator()));
                              }

                              if (!snapshot.hasError &&
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
                                ic = const Icon(Icons.done);
                              }

                              return ListTile(
                                  leading: ic,
                                  title: const Text("Test access"));
                            }),
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
              // subtitle: const Text("This step is automatic")
            );
          }));

  Future<bool> attemptFillAppPasswordFromClipboard() async {
    if (step2Done) {
      return false;
    }
    if (_step2IsPasswordComplete) {
      return false;
    }

    // print("Attempting fill password from clipboard");
    ClipboardData? data;
    try {
     data = await Clipboard.getData("text/plain");
    } catch (e) {
      return false;
    }

    String? text = data?.text;
    if (text == null) {
      // print("No text on clipboard");
      return false;
    }

    if (!applicationPasswordFormat.hasMatch(text)) {
      // print("Clipboard data is no application password");
      return false;
    }

    // print("Found application password in clipboard data");
    setState(() {
      _applicationPasswordController.text = text;
    });
    // scheduleVerifyStep3();
    trySubmit();
    return true;
  }

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
        // bottomNavigationBar: const SizedBox(height:56),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                constraints: const BoxConstraints.expand(),
                child: Center(
                    child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: ListView(shrinkWrap: true, children: [
                          buildSteps(context),
                          if (completed)
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 300),
                                          child: FilledButton(
                                              onPressed: () {
                                                router.go("/");
                                              },
                                              child: const Text(
                                                  "Go to home screen")))
                                    ]))
                        ]))))));
  }
}
