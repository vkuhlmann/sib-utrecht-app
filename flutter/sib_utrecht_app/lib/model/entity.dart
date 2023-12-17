
import 'dart:ui';

import 'package:sib_utrecht_app/model/cacheable_resource.dart';

abstract class Entity implements CacheableResource {
  String getLocalShortName(Locale loc);
  String getLocalLongName(Locale loc);

  String? get profilePage;
}

