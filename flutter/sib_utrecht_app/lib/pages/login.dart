part of '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late void Function() onLoginManagerChangedListener;

  late Future<Widget?>? corsLoginPrompt;

  var unescape = HtmlUnescape();

  @override
  void initState() {
    super.initState();

    refreshCorsLoginPrompt();

    onLoginManagerChangedListener = () {
      setState(() {});
      refreshCorsLoginPrompt();
    };

    // if (widget.params["immediate"] != "false") {
    //   loginManager.assureLoginState().then((state) {
    //     if (state.profiles.isEmpty) {
    //       WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //         router.go("/new-login2");
    //       });
    //     }
    //   });
    // }

    loginManager.addListener(onLoginManagerChangedListener);
  }

  void refreshCorsLoginPrompt() {
    loginManager.assureLoginState().then((value) {
      var alreadyExistingLogins =
          value.profiles.values.map((e) => e["user"]).toSet();

      setState(() {
        corsLoginPrompt = getCorsLoginPrompt(
            predicate: (String userLogin) =>
                !alreadyExistingLogins.contains(userLogin));
      });
    });
  }

  @override
  void dispose() {
    loginManager.removeListener(onLoginManagerChangedListener);

    super.dispose();
  }


  Widget buildLoginPrompts(BuildContext context, LoginState data) => Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            FutureBuilder(
                future: corsLoginPrompt,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const SizedBox();
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  var data = snapshot.data;
                  if (data != null) {
                    return Column(children: [
                      data,
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16)
                    ]);
                  }

                  return snapshot.data ?? const SizedBox();
                }),
            ...data.profiles.entries.map<Widget>((pair) {
              String? displayName =
                  pair.value["identity"]?["user_display_name"];

              if (displayName != null) {
                displayName = unescape.convert(displayName);
              }

              displayName = displayName ?? pair.key;

              return Card(
                  shape: RoundedRectangleBorder(
                      side: pair.key == data.activeProfileName
                          ? const BorderSide(
                              color: Colors.blue,
                              // width: 5,
                            )
                          : BorderSide.none,
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: ListTile(
                      // title: Text(pair.key),
                      // title: Row(
                      //   mainAxisSize: MainAxisSize.min,
                      //   children: [Text(displayName), const SizedBox(width: 32,), 
                      //   InkWell(
                      //     child: const Icon(Icons.delete, size: 20),
                      //     onTap: () {
                      //       loginManager.removeProfile(pair.key);
                      //     },
                      //   ),]),
                      title: Text(displayName, overflow: TextOverflow.ellipsis),
                      subtitle: Text(pair.value["user"], overflow: TextOverflow.ellipsis),
                      leading: const Icon(Icons.person),
                      onTap: () {
                        loginManager.setActiveProfile(pair.key);
                        router.go("/");
                      },
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        // const Text("A")
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            loginManager.removeProfile(pair.key);
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () {
                            loginManager.setActiveProfile(pair.key);
                            router.go("/");
                          },
                        )
                      ])));
            }).toList(),
            Card(
                child: ListTile(
                    leading: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    title: const Text("Log in via browser"),
                    subtitle: const Text(
                        "Uses the account you are logged in with on sib-utrecht.nl, or prompts login"),
                    onTap: () {
                      // router.go("/new-login2");
                      final (_, url) =
                          loginManager.getAuthorizationUrl(withRedirect: false);

                      launchUrl(url).then((v) {
                        if (!v) {
                          throw Exception("Failed to launch url");
                        }
                      }).catchError((err) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: formatError(err)));
                      });
                    })),
            Card(
                child: ListTile(
                    leading: const Icon(
                      Icons.add,
                      color: Colors.green,
                    ),
                    title: const Text("Manual login (for debugging)"),
                    onTap: () {
                      router.go("/new-login?immediate=false&debug");
                    }))
          ])));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // key: _scaffoldKey,
        appBar: AppBar(
            title: Row(children: [
          BackButton(
            onPressed: () {
              router.go("/");
            },
          ),
          const Text('Login')
        ])),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     router.go("/new-login2");
        //   },
        //   child: const Icon(Icons.add),
        // ),
        // bottomNavigationBar: const SizedBox(height:56),
        body: SafeArea(
          child: FutureBuilder(
              future: loginManager.assureLoginState(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading login profiles');
                }

                var data = snapshot.data;

                if (data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  // constraints: const BoxConstraints.expand(),
                  child: Center(
                      child: ListView(shrinkWrap: true, children: [
                    Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildLoginPrompts(context, data)),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: FilledButton(
                              onPressed: data.activeProfile == null ? null : () {
                                loginManager.logout();
                              },
                              child: const Text("Log out")))
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: FilledButton(
                              onPressed: () {
                                loginManager.refreshLoginState();
                              },
                              child: const Text("Refresh")))
                    ]),
                    // const SizedBox(height: 10),
                    // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    //   ConstrainedBox(
                    //       constraints: const BoxConstraints(maxWidth: 300),
                    //       child: FilledButton(
                    //           onPressed: () {
                    //             // loginManager.scheduleLogin();
                    //             router.go("/new-login2");
                    //           },
                    //           child:
                    //               Text(AppLocalizations.of(context)!.actionNewLogin)))
                    // ])
                  ])),
                );
              }),
          // SliverAppBar()
        ));
  }
}
