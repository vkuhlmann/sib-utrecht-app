part of 'main.dart';

// For authorization:
//   Contains code from https://stackoverflow.com/questions/50244416/how-to-pass-basic-auth-credentials-in-api-call-for-a-flutter-mobile-application
//   answer by https://stackoverflow.com/users/9597706/richard-heap
//   Modified

class APIConnector {
  String apiAddress =
      "http://192.168.50.200/wordpress/wp-json/sib-utrecht-wp-plugin/v1";

  final String user = "vincent";
  final String apiSecret = "PuNZ ZO31 bZCP har0 VYwo cNKP";
  late String basicAuth;

  APIConnector() {
    basicAuth = 'Basic ${base64.encode(utf8.encode('$user:$apiSecret'))}';
  }

  Future<Map> get(url) async {
    final response = await http
        .get(Uri.parse("$apiAddress/$url"), headers: <String, String>{
          'authorization': basicAuth
        });

    if (response.statusCode != 200) {
      throw Exception(
          "Got status code ${response.statusCode}, ${response.body}");
    }

    Map obj = jsonDecode(response.body);
    if (obj.containsKey("error")) {
      throw Exception("Request returned error: ${obj['error']}");
    }

    return obj;
  }
}
