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

  final SelectorConfig phoneSelectorConfig = const SelectorConfig(
    showFlags: true,
  );

  final RegExp applicationPasswordFormat =
      RegExp("^([a-zA-Z0-9]{4} ){5}[a-zA-Z0-9]{4}\$");

  final TextEditingController _applicationPasswordController =
      TextEditingController();

  final Icon startIcon = const Icon(Icons.start);
  final Icon doneIcon = const Icon(Icons.done, color: Colors.green);

  @override
  void initState() {
    super.initState();
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
            leading:
                step1Done ? doneIcon : startIcon,
            initiallyExpanded: !step1Done,
            children: <Widget>[
              Container(
                  margin: const EdgeInsets.all(8),
                  child: ElevatedButton(
                      onPressed: step1Done
                          ? null
                          : () {
                              setState(() {
                                step1Done = true;
                                _step1Expansion.collapse();
                                _step2Expansion.expand();
                              });
                            },
                      child: const Text("Done"))),
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

          Clipboard.getData(Clipboard.kTextPlain).then((value) {});

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

  bool checkIfAppPasswordComplete() {
    final String applicationPassword =
        _applicationPasswordController.value.text;
    if (!applicationPasswordFormat.hasMatch(applicationPassword)) {
      return false;
    }

    print("Not implemented: connection test verification");
    setState(() {
      step1Done = true;
      step2Done = true;

      _step1Expansion.collapse();
      _step2Expansion.collapse();
      _step3Expansion.expand();

      step3Result = Future.delayed(const Duration(seconds: 5)).then((value) {
          setState(() {
            completed = true;
          });
      });
    });
    return true;
  }

  @override
  Widget buildStep2(BuildContext context) => Card(
        child: ExpansionTile(
          title: const Text("Step 2: Enter application password"),
          controller: _step2Expansion,
          leading: step2Done
              ? doneIcon
              : (step1Done
                  ? startIcon
                  : const Icon(Icons.schedule)),
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
                      if (step2Done) {
                        step2Done = false;
                        step3Result = null;
                      }

                      checkIfAppPasswordComplete();

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
                  )
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
      );

  @override
  Widget buildStep3(BuildContext context) => Card(
      child: FutureBuilder(
          future: step3Result,
          builder: (context, snapshot) => ExpansionTile(
                title: const Text("Step 3: Connection test"),
                controller: _step3Expansion,
                leading: step2Done
                    ? ((step3Result == null)
                        ? startIcon
                        : snapshot.hasError
                            ? const Icon(Icons.error)
                            : (snapshot.connectionState == ConnectionState.done
                                ? doneIcon
                                : const SizedBox(width: 16,height: 16, child: Center(child: CircularProgressIndicator()))))
                    : const Icon(Icons.schedule),
                // subtitle: const Text("This step is automatic")
              )));

  Future<bool> attemptFillAppPasswordFromClipboard() async {
    if (step2Done) {
      return false;
    }

    print("Attempting fill password from clipboard");
    ClipboardData? data = await Clipboard.getData("text/plain");

    String? text = data?.text;
    if (text == null) {
      print("No text on clipboard");
      return false;
    }

    if (!applicationPasswordFormat.hasMatch(text)) {
      print("Clipboard data is no application password");
      return false;
    }

    print("Found application password in clipboard data");
    setState(() {
      _applicationPasswordController.text = text;
    });
    // scheduleVerifyStep3();
    checkIfAppPasswordComplete();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Row(children: [
          BackButton(
            onPressed: () {
              // var navContext = _rootNavigatorKey.currentContext;

              // if (navContext != null && navContext.canPop()) {
              //   navContext.pop();
              // }

              _router.go("/login?immediate=false");

              // if (_router.canPop()) {
              //   _router.pop();
              // }
              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context);
              // }
            },
          ),
          const Text('New login')
        ])),
        // bottomNavigationBar: const SizedBox(height:56),
        body: SafeArea(
            child: Focus(
                onFocusChange: (value) {
                  if (!value) {
                    return;
                  }
                  print("Got focus!!");
                  attemptFillAppPasswordFromClipboard();
                },
                child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
                    constraints: const BoxConstraints.expand(),
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                            child: Center(
                                child: Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 600),
                                    child: buildSteps(context))))
                      ],

                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // children: [
                      //   Text("Hoi!")
                      // ]
                    )))));
  }
}
