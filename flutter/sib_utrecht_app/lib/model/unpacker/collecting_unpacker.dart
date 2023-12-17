import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/direct_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker_base.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class CollectingUnpacker extends DirectUnpacker {
  // Unpacker base;
  ResourcePoolBase? pool;
  FetchResult<void> anchor;

  CollectingUnpacker({required this.pool, required this.anchor});

  @override
  T parse<T extends CacheableResource>(Map data)
  {
    var val = super.parse<T>(data);

    final pool = this.pool;
    if (pool != null) {
      pool.collect<T>(anchor.withValue(val));
    }
    return val;
  }

  // @override
  // FetchResult<T> parse<T extends CacheableResource>(FetchResult<Map> data) {
  //   // var val = data.mapValue((p0) => base.parseUser(data) User.fromJson(p0));
  //   var val = super.parse<T>(data);

  //   final pool = this.pool;
  //   if (pool != null) {
  //     pool.collect<T>(val);
  //   }
  //   return val;
  // }
}
