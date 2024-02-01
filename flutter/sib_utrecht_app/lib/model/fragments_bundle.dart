import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/fragment.dart';

class FragmentsBundle {
  Map<String, Fragment> fragments;

  FragmentsBundle(this.fragments);

  factory FragmentsBundle.fromComplete(Map json) {
    return FragmentsBundle(json
        .map((key, value) => MapEntry(key, Fragment(key: key, value: value))));
  }

  Map toPayload() {
    return fragments.map((key, value) => MapEntry(key, value.value));

    // return Map.fromEntries(fragments.map((e) => MapEntry(e.key, e.value)));
  }

  ({Fragment frag, String subpath})? getFragment(String key) {
    List<String> parts = key.split(".");

    for (int i = 1; i < parts.length + 1; i++) {
      String subKey = parts.sublist(0, i).join(".");

      Fragment? val = fragments[subKey];

      if (val != null) {
        return (frag: val, subpath: parts.sublist(i).join("."));
      }
    }

    return null;
  }

  T? get<T>(List<String> key) {
    for (String k in key) {
      final res = getDynamicOrNull(k, expectReachable: false);
      if (res == null) {
        continue;
      }

      if (res is T) {
        return res;
      }

      if (res is! Map) {
        log.warning("Expected $k to be of type $T, but was $res");
      }
    }

    return null;
  }

  dynamic getDynamicOrNull(String key, {bool expectReachable = true}) {
    final fragment = getFragment(key);

    if (fragment == null) {
      return null;
    }

    dynamic val = fragment.frag;
    List<String> parts = fragment.subpath.split(".");
    if (parts.length == 1 && parts[0] == "") {
      parts = [];
    }

    for (String part in parts) {
      if (val is! Map) {
        if (expectReachable) {
          log.warning("Could not reach $key: came across $val");
        }
        return null;
      }

      val = val[part];
    }
  }
}
