import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';

import '../log.dart';
import '../model/api_connector.dart';
import '../components/api_access.dart';
import '../components/actions/sib_appbar.dart';


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
    final apiConnector = APIAccess.of(context).connector;
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
            return c.getSimple(url, version: ApiVersion.v2);
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
        // WithSIBAppBar(actions: const [], child: 
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: ListView(children: [
              const SizedBox(height: 16),
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
                Expanded(
                    child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'URL'),
                  // expands: true, maxLines: null,
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
                    return Text(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                      return SelectableText(snapshot.data.toString());
                  }

                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16)
            ]));
  }
}
