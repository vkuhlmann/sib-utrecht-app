part of '../main.dart';

class AuthorizePage extends StatefulWidget {
  const AuthorizePage({Key? key, required this.params}) : super(key: key);

  final Map<String, dynamic> params;

  @override
  State<AuthorizePage> createState() => _AuthorizePageState();
}

class _AuthorizePageState extends State<AuthorizePage> {
  late bool isSuccess;
  Future<LoginState>? initiatedLogin;

  @override
  void initState() {
    super.initState();

    isSuccess = widget.params["success"] != false && widget.params["user_login"] != null;
    log.info("isSuccess: $isSuccess");

    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_){
        log.info("Completing login");
        setState(() {
          initiatedLogin = loginManager._completeLogin(
            user: widget.params["user_login"],
            apiSecret: widget.params["password"],
          ).then((state) {
            _router.go("/");
            return state;
          });
        });
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
        title: const Text("Authorization"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text("Authorize"),
            // const Text("User is ${}"),
            // Text(jsonEncode(widget.params)),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            //   child: const Text("Go back"),
            // ),
            if (isSuccess) const Text(
              "Login successful",
              style: TextStyle(color: Colors.green, fontSize: 28),
              ),
            if (!isSuccess) const Text(
              "Login failed",
              style: TextStyle(color: Colors.red, fontSize: 28),
              ),

            FutureBuilder(future: initiatedLogin,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("Logged in as ${snapshot.data?.activeProfile?["user"]}");
                } else if (snapshot.hasError) {
                  return Text("Error completing login: \n${snapshot.error}");
                } else {
                  return const CircularProgressIndicator();
                }
              },
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