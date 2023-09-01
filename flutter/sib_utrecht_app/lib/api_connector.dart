part of 'main.dart';

// For authorization:
//   Contains code from https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
//   answer by https://stackoverflow.com/users/9597706/richard-heap
//   Modified

class APIConnector {
  String apiAddress =
      "http://192.168.50.200/wordpress/wp-json/sib-utrecht-wp-plugin/v1";

  final String? user;// = "vincent";
  // final String apiSecret = "PuNZ ZO31 bZCP har0 VYwo cNKP";
  late final String? basicAuth;
  late Map<String, String> headers;

  APIConnector({this.user, String? apiSecret}) {
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

    Map obj = jsonDecode(response.body);
    if (obj.containsKey("error")) {
      throw Exception("Request returned error: ${obj['error']}");
    }

    return obj;
  }

  Future<Map> get(url) async {
    print("Doing GET on $url");
    // await Future.delayed(Duration(seconds: 2));
    final response = await http.get(Uri.parse("$apiAddress/$url"), headers: headers);
    return _handleResponse(response);
  }

  Future<Map> post(url) async {
    // var response;
    // try {
    print("Doing POST on $url");
    // await Future.delayed(Duration(seconds: 3));
    final response = await http.post(Uri.parse("$apiAddress/$url"),
        headers: headers);
    // } catch (e) {
    //   print("HTTP post errored");
    // }

    return _handleResponse(response);
  }

  Future<Map> put(url) async {
    print("Doing PUT on $url");
    // await Future.delayed(Duration(seconds: 3));
    final response = await http.put(Uri.parse("$apiAddress/$url"),
        headers: headers);

    return _handleResponse(response);
  }

  Future<Map> delete(url) async {
    final response = await http.delete(Uri.parse("$apiAddress/$url"),
        headers: headers);

    return _handleResponse(response);
  }
}
