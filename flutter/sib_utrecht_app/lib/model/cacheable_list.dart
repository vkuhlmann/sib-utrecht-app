import 'dart:collection';

import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:quiver/collection.dart';
import 'package:sib_utrecht_app/model/unpacker/anchored_unpacker.dart';
import 'package:sib_utrecht_app/model/unpacker/unpacker.dart';

class CacheableList<T extends CacheableResource> extends DelegatingList<String>
    with CacheableResource {
  @override
  final String id;
  final List<String> _list;

  CacheableList(this.id, this._list);

  factory CacheableList.fromJson(Map json, AnchoredUnpacker unpacker) {
    return CacheableList(
        json['id'],
        List.unmodifiable(
            (json['data'] as Iterable).map((e) => unpacker.abstract<T>(e))));
  }

  @override
  List<String> get delegate => _list;

  @override
  Map toJson() {
    return {
      'id': id,
      'data': _list,
    };
  }
}
