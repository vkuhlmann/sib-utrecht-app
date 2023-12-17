import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker_base.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

class DirectUnpacker implements AnchoredUnpacker {
  // @override
  // FetchResult<T> parse<T extends CacheableResource>(FetchResult<Map> data) {
  //   return data.mapValue((p0) => CacheableResource.fromJson<T>(
  //       data.value, AnchoredUnpacker(anchor: data, base: this)));
  // }

  @override
  T parse<T extends CacheableResource>(Map data)
  {
    return CacheableResource.fromJson<T>(data, this);
  }

  @override
  String abstract<T extends CacheableResource>(dynamic data)
  {
    final v = data;
    if (v is String) {
      return v;
    }
    T val = parse<T>(data as Map);
    return val.id;
  }
}
