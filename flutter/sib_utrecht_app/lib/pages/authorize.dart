part of '../main.dart';

class AuthorizePage extends StatefulWidget {
  const AuthorizePage({Key? key, required Map<String, dynamic> this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  State<AuthorizePage> createState() => _AuthorizePageState();
}

class _AuthorizePageState extends State<AuthorizePage> {
  @override
  void initState() {
    super.initState();

    bool isSuccess = widget.params["success"] != false && widget.params["user_login"] != null;
    log.info("isSuccess: $isSuccess");

    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_){
        log.info("Completing login");
        LoginManager()._completeLogin(
          user: widget.params["user_login"],
          apiSecret: widget.params["password"],
        );
        log.info("Completed login");
        // context.go("/");
      });
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   print(jsonEncode(widget.params));

  //   context.go("/");
  // }

  @override
  Widget build(BuildContext context) {
    // Map<String, dynamic> params = GoRouterState.of(context).queryParams;
    // Map<String,dynamic> qparams = GoRouterState.of(context).uri;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Authorize"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Authorize"),
            // const Text("User is ${}"),
            Text(jsonEncode(widget.params)),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Go back"),
            ),
            ElevatedButton(
              onPressed: () {
                context.go("/");
              },
              child: const Text("Go to home screen"),
            ),
          ],
        ),
      ),
    );
  }
}