import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'api_error.dart';
import '../log.dart';

// For authorization:
//   Contains code from https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
//   answer by https://stackoverflow.com/users/9597706/richard-heap
//   Modified

class APIConnector {
  String apiAddress;

  final String? user;
  late final String? basicAuth;
  late Map<String, String> headers;
  late Future<Box<dynamic>> boxFuture;
  late http.Client client;

  APIConnector({this.user, String? apiSecret, required this.apiAddress}) {
    Hive.init(null);
    boxFuture = Hive.openBox("api_cache");

    client = http.Client();

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
        throw APIError(
            "Got status code ${response.statusCode}: ${response.body}",
            connector: this,
            statusCode: response.statusCode,
            responseBody: response.body);
      }

      throw APIError(message,
          connector: this,
          statusCode: response.statusCode,
          responseBody: response.body);
    }

    if (response.body.startsWith('<div id="error">')) {
      throw APIError("Unhandled error on server, please contact Vincent",
          connector: this,
          statusCode: response.statusCode,
          responseBody: response.body);
    }
    if (response.body.startsWith('<br />')) {
      throw APIError("Unhandled error on server, please contact Vincent",
          connector: this,
          statusCode: response.statusCode,
          responseBody: response.body);
    }

    Map obj = jsonDecode(response.body);
    if (obj.containsKey("error")) {
      if (obj.containsKey("details")) {
        throw APIError(
          "${obj['error']} (${obj['details'].join(', ')})",
          connector: this,
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
      throw APIError(
        "${obj['error']}",
        connector: this,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }

    return obj;
  }

  Future<Map?> getCached(url) async {
    var box = await boxFuture;
    return box.get(url)?["response"];
  }

  Future<Map> get(String url) async {
    log.info("Doing GET on $url");

    final Stopwatch stopwatch = Stopwatch()..start();

    http.Response response;
    try {
      response = await client.get(getUri(url), headers: headers);
    } on http.ClientException catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw Exception("Cannot connect to server.");
      }
      throw Exception("Cannot connect to server: ${e.message}");
    }
    var elapsedTime = stopwatch.elapsedMilliseconds;
    log.fine("Doing GET on $url took $elapsedTime ms");

    var ans = _handleResponse(response);
    var box = await boxFuture;
    box.put(url, {
      "response": ans,
      "time": DateTime.now().millisecondsSinceEpoch,
    });
    return ans;
  }

  Uri getUri(String url) {
    if (url.startsWith("/")) {
      url = url.substring(1);
    }

    return Uri.parse("$apiAddress/$url");
  }

  Future<Map> post(url, {Map? body}) async {
    log.info("Doing POST on $url");
    http.Response response;
    if (body != null) {
      response = await client.post(
        getUri(url),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.post(getUri(url), headers: headers);
    }

    return _handleResponse(response);
  }

  Future<Map> put(url, {Map? body}) async {
    log.info("Doing PUT on $url");
    http.Response response;
    if (body != null) {
      response = await client.put(
        getUri(url),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.put(getUri(url), headers: headers);
    }

    return _handleResponse(response);
  }

  Future<Map> delete(url, {Map? body}) async {
    log.info("Doing DELETE on $url");
    // final response =
    //     await client.delete(getUri(url), headers: headers);

    http.Response response;
    if (body != null) {
      response = await client.delete(
        getUri(url),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.delete(getUri(url), headers: headers);
    }

    return _handleResponse(response);
  }
}
