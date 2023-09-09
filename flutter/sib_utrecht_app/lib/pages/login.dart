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

    if (widget.params["immediate"] != "false") {
      loginManager.assureLoginState().then((state) {
        if (state.profiles.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            router.go("/new-login");
          });
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
              router.go("/");
            },
          ),
          const Text('Login')
        ])),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            router.go("/new-login");
          },
          child: const Icon(Icons.add),
        ),
        // bottomNavigationBar: const SizedBox(height:56),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                // constraints: const BoxConstraints.expand(),
                child: 
                Center(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                          FutureBuilder(
                              future: loginManager.assureLoginState(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text(
                                      'Error loading login profiles');
                                }

                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
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
                                                          router.go("/");
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
                                router.go("/new-login");
                              },
                              child: const Text("New login")))])
                        ])),
                  ),
                  // SliverAppBar()
                ));
  }
}
