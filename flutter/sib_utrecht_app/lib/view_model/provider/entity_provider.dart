import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/entities.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';

class EntityProvider {
  static Widget Multiplexed(
          {query,
          required Widget Function(BuildContext, List<FetchResult<Entity>>) builder}) =>
      MultiplexedProvider(
        query: query,
        builder: builder,
        // changeListener: (p) => Listenable.merge([p._users, p._groups]),
        errorTitle: (loc) => loc.couldNotLoad(loc.dataEntity),
        obtain: (String q, c) => Entities(c).getEntity(entityName: q),
      );
}
