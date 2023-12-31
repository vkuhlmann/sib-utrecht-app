

import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

abstract interface class AnchoredUnpacker {
  // FetchResult<void> anchor;
  // Unpacker base;

  // AnchoredUnpacker({required this.anchor, required this.base});

  T parse<T extends CacheableResource>(Map data);
  // {
  //   return base.parse<T>(anchor.mapValue((_) => data)).value;
  // }

  String abstract<T extends CacheableResource>(dynamic data);
  // {
  //   return base.abstract<T>(anchor.mapValue((_) => data));
  // }
}
