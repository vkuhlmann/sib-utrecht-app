part of '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    loginManager.loadProfiles();

    if (widget.params["immediate"] == "true") {
      loginManager.state.then((state) {
        if (state.profiles.isEmpty) {
          // loginManager.scheduleLogin();
          _router.go("/new-login");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // key: _scaffoldKey,
        appBar: AppBar(
            title: Row(children: [
          BackButton(
            onPressed: () {
              // var navContext = _rootNavigatorKey.currentContext;

              // if (navContext != null && navContext.canPop()) {
              //   navContext.pop();
              // }

              _router.go("/");

              // if (_router.canPop()) {
              //   _router.pop();
              // }
              // if (Navigator.canPop(context)) {
              //   Navigator.pop(context);
              // }
            },
          ),
          const Text('Login')
        ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _router.go("/new-login");
          },
          child: const Icon(Icons.add),
        ),
        // bottomNavigationBar: const SizedBox(height:56),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                // constraints: const BoxConstraints.expand(),
                child: CustomScrollView(slivers: [
                  SliverFillRemaining(
                    child: 
                    Center(
                        child: ListView(children:[
                          FutureBuilder(
                              future: loginManager.state,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text(
                                      'Error loading login profiles');
                                }

                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                return Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children:
                                            snapshot.data!.profiles.entries
                                                .map<Widget>((pair) => Card(
                                                    child: ListTile(
                                                        title: Text(pair.key),
                                                        onTap: () {
                                                          loginManager
                                                              .setActiveProfile(
                                                                  pair.key);
                                                          _router.go("/");
                                                        })))
                                                .toList()));
                              }),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300),
                          child: 
                          FilledButton(
                              onPressed: () {
                                // loginManager.scheduleLogin();
                                _router.go("/new-login");
                              },
                              child: const Text("New login")))])
                        ])),
                  ),
                  // SliverAppBar()
                ]))));
  }
}
