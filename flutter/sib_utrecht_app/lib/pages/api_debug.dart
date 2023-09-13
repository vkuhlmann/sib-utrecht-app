part of '../main.dart';

class APIDebugPage extends StatefulWidget {
  const APIDebugPage({Key? key}) : super(key: key);

  @override
  State<APIDebugPage> createState() => _APIDebugPageState();
}

class _APIDebugPageState extends State<APIDebugPage> {
  Future<APIConnector>? connector;
  Future<String>? response;

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _requestBodyJsonController = TextEditingController();
  String method = "GET";
  bool isJsonValid = true;
  // Map? requestBodyJson;

  @override
  void initState() {
    super.initState();

    // response = widget.connector.get("/api/v1/activities");
  }

  @override
  void didChangeDependencies() {
    final apiConnector = APIAccess.of(context).state.then((a) => a.connector);
    if (connector != apiConnector) {
      log.fine(
          "[APIDebugPage] API connector changed from $connector to $apiConnector");
      connector = apiConnector;
    }

    super.didChangeDependencies();
  }

  void submit() {
    var conn = connector;
    if (conn == null) {
      return;
    }

    String url = _urlController.text;
    Map? body = _requestBodyJsonController.text.isNotEmpty ? jsonDecode(_requestBodyJsonController.text) : null;

    setState(() {
      response = connector!.then((c) {
        switch (method) {
          case "GET":
            return c.get(url);
          case "POST":
            return c.post(url, body: body);
          case "PUT":
            return c.put(url, body: body);
          case "DELETE":
            return c.delete(url);
        }
        throw Exception("Unknown method $method");
      }).then((value) {
        return const JsonEncoder.withIndent("  ").convert(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Text("test");
    bool isBodyAvailable = method != "GET" && method != "DELETE";

    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: const Text("API Debug"),
        //   ),
        //   body:
        Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(children: [
              Row(children: [
                DropdownButton(
                  items: const [
                    DropdownMenuItem(value: "GET", child: Text("GET")),
                    DropdownMenuItem(value: "POST", child: Text("POST")),
                    DropdownMenuItem(value: "PUT", child: Text("PUT")),
                    DropdownMenuItem(value: "DELETE", child: Text("DELETE")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      method = value ?? "GET";
                    });
                  },
                  value: method,
                ),
                const SizedBox(width: 16),
                // TextField(
                //   controller: _urlController,
                //   decoration: const InputDecoration(
                //       border: OutlineInputBorder(),
                //       labelText: 'URL'),
                //       expands: true, maxLines: null,)
                Expanded(
                    child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'URL'),
                  // minLines: 1, maxLines: 1,
                  onSubmitted: (value) {
                    submit();
                  },
                ))
              ]),
              const SizedBox(height: 16),
              TextField(
                  enabled: isBodyAvailable,
                  controller: _requestBodyJsonController,
                  maxLines: null,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      // labelText: 'Request body JSON',
                      labelText: isBodyAvailable ? 'Request body JSON'
                      : "Request body JSON (not available for $method)",
                      // helperText: "Except  GET/DELETE",
                      errorText: (isJsonValid || !isBodyAvailable) ? null : "Invalid JSON"),
                  onChanged: (value) {
                    
                    bool isNewValid = false;
                    try{
                      isNewValid = value.isEmpty || (jsonDecode(value) is Map<String, dynamic>);
                    } catch (e) {}

                    if (isNewValid != isJsonValid) {
                      setState(() {
                        isJsonValid = isNewValid;
                      });
                    }
                  },
                ),
              const SizedBox(height: 32),
              FilledButton(
                  onPressed: connector != null ? submit : null,
                  child: const Text("Send")),
              const SizedBox(height: 16),
              FutureBuilder(
                future: response,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Expanded(child: Text(snapshot.error.toString()));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    return Expanded(
                        child: SelectableText(snapshot.data.toString()));
                  }

                  return const SizedBox();
                },
              )
              // Expanded(child: Text(),)
              //
            ]));
    //  FutureBuilder<APIResponse>(
    //   future: connector,
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       return ListView(
    //         children: [
    //           ListTile(
    //             title: const Text("Response"),
    //             subtitle: Text(snapshot.data!.body),
    //           ),
    //           ListTile(
    //             title: const Text("Status"),
    //             subtitle: Text(snapshot.data!.status.toString()),
    //           ),
    //           ListTile(
    //             title: const Text("Headers"),
    //             subtitle: Text(snapshot.data!.headers.toString()),
    //           ),
    //         ],
    //       );
    //     } else if (snapshot.hasError) {
    //       return ListView(
    //         children: [
    //           ListTile(
    //             title: const Text("Error"),
    //             subtitle: Text(snapshot.error.toString()),
    //           ),
    //         ],
    //       );
    //     } else {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //   },
    // ),
    // );
  }
}
