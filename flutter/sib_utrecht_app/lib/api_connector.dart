part of 'main.dart';

// For authorization:
//   Contains code from https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
//   answer by https://stackoverflow.com/users/9597706/richard-heap
//   Modified

class APIConnector {
  String apiAddress = apiUrl;

  final String? user; // = "vincent";
  // final String apiSecret = "PuNZ ZO31 bZCP har0 VYwo cNKP";
  late final String? basicAuth;
  late Map<String, String> headers;
  late Future<Box<dynamic>> boxFuture;

  APIConnector({this.user, String? apiSecret}) {
    // Hive.init(Directory.current.path);
    Hive.init(null);
    boxFuture = Hive.openBox("api_cache");
    // box = Hive.box("api_cache");

    headers = {};
    if (user != null) {
      basicAuth = 'Basic ${base64.encode(utf8.encode('$user:$apiSecret'))}';

      headers["authorization"] = basicAuth!;
    }
  }

  Map _handleResponse(http.Response response) {
    if (response.statusCode != 200) {
      dynamic message;
      try {
        message = (jsonDecode(response.body) as Map)["message"];
      } catch (e) {
        throw Exception(
            "Got status code ${response.statusCode}: ${response.body}");
      }

      throw Exception("$message");
    }

    if (response.body.startsWith('<div id="error">')) {
      throw Exception("Unhandled error on server, please contact Vincent");
    }
    if (response.body.startsWith('<br />')) {
      throw Exception("Unhandled error on server, please contact Vincent");
    }

    Map obj = jsonDecode(response.body);
    if (obj.containsKey("error")) {
      if (obj.containsKey("details")) {
        throw Exception("${obj['error']} (${obj['details'].join(', ')})");
      }
      throw Exception("${obj['error']}");
      // throw Exception("Request returned error: ${obj['error']}");
    }

    return obj;
  }

  Future<Map?> getCached(url) async {
    var box = await boxFuture;
    return box.get(url)?["response"];
  }

  Future<Map> get(url) async {
    log.info("Doing GET on $url");
    // await Future.delayed(Duration(seconds: 3));

    http.Response response;
    try {
      response =
          await http.get(Uri.parse("$apiAddress/$url"), headers: headers);
    } on http.ClientException catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw Exception("Cannot connect to server.");
      }
      throw Exception("Cannot connect to server: ${e.message}");
    }
    var ans = _handleResponse(response);
    var box = await boxFuture;
    box.put(url, {
      "response": ans,
      "time": DateTime.now().millisecondsSinceEpoch,
    });
    return ans;
  }

  Future<Map> post(url) async {
    // var response;
    // try {
    log.info("Doing POST on $url");
    // await Future.delayed(Duration(seconds: 3));
    final response =
        await http.post(Uri.parse("$apiAddress/$url"), headers: headers);
    // } catch (e) {
    //   print("HTTP post errored");
    // }

    return _handleResponse(response);
  }

  Future<Map> put(url) async {
    log.info("Doing PUT on $url");
    // await Future.delayed(Duration(seconds: 3));
    final response =
        await http.put(Uri.parse("$apiAddress/$url"), headers: headers);

    return _handleResponse(response);
  }

  Future<Map> delete(url) async {
    log.info("Doing DELETE on $url");
    final response =
        await http.delete(Uri.parse("$apiAddress/$url"), headers: headers);

    return _handleResponse(response);
  }
}
