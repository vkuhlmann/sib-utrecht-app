import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/view_model/cached_provider_t.dart';

abstract class UnpackerBase implements Unpacker {

  @override
  String abstract<T extends CacheableResource>(FetchResult<dynamic> data) {
    final v = data.value;
    if (v is String) {
      return v;
    }
    T val = parse<T>(data.mapValue((p0) => p0 as Map)).value;
    return val.id;
  }
}
