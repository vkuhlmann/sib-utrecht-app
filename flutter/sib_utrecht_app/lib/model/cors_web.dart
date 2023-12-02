// Based on https://stackoverflow.com/questions/58710226/how-to-import-platform-specific-dependency-in-flutter-dart-combine-web-with-an
// answer by https://stackoverflow.com/users/17068479/bk3

import 'package:http/browser_client.dart';
import 'package:http/http.dart';

Client? getCorsClient({required bool withCredentials}) =>
    BrowserClient()..withCredentials = withCredentials;
