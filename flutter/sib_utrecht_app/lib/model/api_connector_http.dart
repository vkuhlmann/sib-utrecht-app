import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

import 'api_error.dart';
import '../log.dart';

// For authorization:
//   Contains code from https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
//   answer by https://stackoverflow.com/users/9597706/richard-heap
//   Modified

class HTTPApiConnector extends APIConnector {
  late http.Client client;
  String apiAddress;

  final String? user;
  late final String? basicAuth;

  late Map<String, String> headers;

  String get channelName => "$apiAddress:${user ?? 'null'}";

  HTTPApiConnector({this.user, String? apiSecret, required this.apiAddress}) {
    client = http.Client();
    headers = {};
    if (user != null) {
      basicAuth = 'Basic ${base64.encode(utf8.encode('$user:$apiSecret'))}';

      headers["authorization"] = basicAuth!;
    }
  }

  Uri getUri(String url, ApiVersion? version) {
    if (url.startsWith("/")) {
      url = url.substring(1);
    }

    return Uri.parse("$apiAddress/${(version ?? ApiVersion.v1).name}/$url");
  }

  Map handleResponse(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
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
    if (response.body.startsWith('<style type="text/css"> .wp-die-message')) {
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


  // @override
  // Future<FetchResult<Map>> getWithFetchResult(String url) async {
  //   var result = await get(url);
  //   return FetchResult(result, DateTime.now());
  // }

  @override
  Future<FetchResult<Map>> get(String url, {required version}) async {
    log.info("Doing GET on $url");

    final Stopwatch stopwatch = Stopwatch()..start();

    http.Response response;
    try {
      response = await client.get(getUri(url, version), headers: headers);
    } on http.ClientException catch (e) {
      if (e.message == "XMLHttpRequest error.") {
        throw Exception("Cannot connect to server.");
      }
      throw Exception("Cannot connect to server: ${e.message}");
    }
    var elapsedTime = stopwatch.elapsedMilliseconds;
    log.fine("Doing GET on $url took $elapsedTime ms");

    var ans = handleResponse(response);
    // var box = await boxFuture;
    // box.put(url, {
    //   "response": ans,
    //   "time": DateTime.now().millisecondsSinceEpoch,
    // });
    return FetchResult(ans, DateTime.now());
  }

  @override
  Future<Map> post(url, {version, Map? body}) async {
    log.info("Doing POST on $url");
    http.Response response;
    if (body != null) {
      response = await client.post(
        getUri(url, version),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.post(getUri(url, version), headers: headers);
    }

    return handleResponse(response);
  }

  @override
  Future<Map> put(url, {version, Map? body}) async {
    log.info("Doing PUT on $url");
    http.Response response;
    if (body != null) {
      response = await client.put(
        getUri(url, version),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.put(getUri(url, version), headers: headers);
    }

    return handleResponse(response);
  }

  @override
  Future<Map> delete(url, {Map? body, version}) async {
    log.info("Doing DELETE on $url");
    // final response =
    //     await client.delete(getUri(url), headers: headers);

    http.Response response;
    if (body != null) {
      response = await client.delete(
        getUri(url, version),
        headers: {
          ...headers,
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } else {
      response = await client.delete(getUri(url, version), headers: headers);
    }

    return handleResponse(response);
  }
}
