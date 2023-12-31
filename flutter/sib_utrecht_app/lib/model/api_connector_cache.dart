import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:hive/hive.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class CacheMissException implements Exception {
  final String message;

  CacheMissException(this.message);

  @override
  String toString() {
    return message;
  }
}

// class CacheApiConnector extends APIConnector {
//   late Future<Box<dynamic>> boxFuture;
//   String? channelName;

//   CacheApiConnector({this.channelName}) {
//     Hive.init(null);
//     boxFuture = Hive.openBox("api_cache");
//   }

//   @override
//   Future<Map> delete(url, {Map? body}) {
//     throw CacheMissException("No caching available for DELETE operations");
//   }

//   @override
//   Future<FetchResult<Map>> get(String url) async {
//     var box = await boxFuture;
//     Map? res = box.get(getKeyName(url));
//     Map? response = res?["response"];
//     int? time = res?["time"];
//     // Map? res = box.get(getKeyName(url))?["response"];

//     if (response == null) {
//       throw CacheMissException("Cache miss for $url");
//     }


//     DateTime? timestamp;
//     if (time != null) {
//       timestamp = DateTime.fromMillisecondsSinceEpoch(time);
//     }

//     return FetchResult(response, timestamp);
//   }

//   String getKeyName(String url) {
//     if (channelName == null) {
//       return url;
//     }

//     return "$channelName:$url";
//   }

//   Future<void> setGetResult(String url, FetchResult<Map> ans) async {
//     var box = await boxFuture;
//     box.put(getKeyName(url), {
//       "response": ans.value,
//       "time": ans.timestamp?.millisecondsSinceEpoch,
//     });
//   }

//   @override
//   Future<Map> post(url, {Map? body}) {
//     throw CacheMissException("No caching available for POST operations");
//   }

//   @override
//   Future<Map> put(url, {Map? body}) {
//     throw CacheMissException("No caching available for PUT operations");
//   }
// }
