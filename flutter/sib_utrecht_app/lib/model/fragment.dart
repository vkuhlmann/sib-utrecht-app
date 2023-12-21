import 'package:flutter/foundation.dart';

@immutable
class Fragment {
  final String key;
  final dynamic value;

  const Fragment({required this.key, required this.value});
}
