import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class Fragment {
  final String key;
  final dynamic value;

  const Fragment({required this.key, required this.value});

  Fragment.copy(Fragment fragment)
      : key = fragment.key,
        value = jsonDecode(jsonEncode(fragment.value));
}
