import 'package:sib_utrecht_app/model/fragment.dart';

class FragmentsBundle {
  List<Fragment> fragments;

  FragmentsBundle(this.fragments);

  factory FragmentsBundle.fromComplete(Map json) {
    return FragmentsBundle(
        json.entries.map((e) => Fragment(key: e.key, value: e.value)).toList());
  }

  Map toPayload() {
    return Map.fromEntries(fragments.map((e) => MapEntry(e.key, e.value)));
  }
}
