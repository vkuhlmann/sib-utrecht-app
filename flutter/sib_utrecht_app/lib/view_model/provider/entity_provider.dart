import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/entities.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';
import 'package:sib_utrecht_app/view_model/multiplexed_provider.dart';

class EntityProvider {
  static Widget Multiplexed(
          {query, required Widget Function(BuildContext, List<Entity>) builder}) =>
      MultiplexedProvider(
          query: query,
          builder: builder,
          errorTitle: (loc) => loc.couldNotLoad(loc.dataEntity),
          obtainProvider: (String q) => CachedProvider(
                obtain: (c) => Entities(c).getEntity(entityName: q),
              ),
          );
}