part of '../main.dart';

class APIDebugPage extends StatefulWidget {
  const APIDebugPage({Key? key}) : super(key: key);

  @override
  _APIDebugPageState createState() => _APIDebugPageState();
}

class _APIDebugPageState extends State<APIDebugPage> {
  Future<APIConnector>? connector;
  Future<String>? response;

  final TextEditingController _urlController = TextEditingController();
  String method = "GET";

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

  @override
  Widget build(BuildContext context) {
    // return Text("test");

    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: const Text("API Debug"),
        //   ),
        //   body:
        Padding(
            padding: EdgeInsets.all(16),
            child: Column(children: [
              Row(children: [
                DropdownButton(
                  items: [
                    DropdownMenuItem(value: "GET", child: const Text("GET")),
                    DropdownMenuItem(value: "POST", child: const Text("POST")),
                    DropdownMenuItem(value: "PUT", child: const Text("PUT")),
                    DropdownMenuItem(
                        value: "DELETE", child: const Text("DELETE")),
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
                            minLines: 1, maxLines: 5))
              ]),
              const SizedBox(height: 8),
              FilledButton(onPressed: connector != null ? () {
                setState(() {
                  response = connector!.then((c) {
                    switch(method) {
                      case "GET":
                        return c.get(_urlController.text);
                      case "POST":
                        return c.post(_urlController.text);
                      case "PUT":
                        return c.put(_urlController.text);
                      case "DELETE":
                        return c.delete(_urlController.text);
                    }
                    throw Exception("Unknown method $method");
                  })
                  .then((value) {
                    return const JsonEncoder.withIndent("  ").convert(value);
                  });
                });
              } : null, child: const Text("Send")),
              const SizedBox(height: 16),
              FutureBuilder(future: response,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Expanded(child: Text(snapshot.error.toString()));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  return Expanded(child: SelectableText(snapshot.data.toString()));
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
