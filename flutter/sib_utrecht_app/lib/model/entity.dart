
import 'dart:ui';

abstract class Entity {
  String getLocalShortName(Locale loc);
  String getLocalLongName(Locale loc);

  String? get profilePage;
}

