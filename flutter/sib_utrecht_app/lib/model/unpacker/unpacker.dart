import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

abstract interface class Unpacker {
  // ResourcePoolBase? pool;

  // Unpacker({this.pool});

  // static Unpacker get direct => Unpacker();

  FetchResult<T> parse<T extends CacheableResource>(FetchResult<Map> data);

  String abstract<T extends CacheableResource>(FetchResult<dynamic> data);
}
