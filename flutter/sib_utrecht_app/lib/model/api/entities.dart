import 'package:sib_utrecht_app/model/api/utils.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class Entities {
  final APIConnector apiConnector;

  Entities(this.apiConnector);

  ResourcePool? get pool => getCollectingPoolForConnector(apiConnector);

  // Future<FetchResult<Entity>> getEntity({required String entityName}) async {
  //   var raw = await apiConnector.getSimple("/entities/@$entityName");

  //   var a = (raw["data"]["entity"] as Map).entries.first;
  //   var type = a.key;
  //   var data = a.value as Map;

  //   if (type == "user") {
  //     return User.fromJson(
  //         data.map((key, value) => MapEntry<String, dynamic>(key, value)));
  //   }

  //   if (type == "group") {
  //     return Group.fromJson(
  //         data.map((key, value) => MapEntry<String, dynamic>(key, value))
  //     );
  //   }

  //   throw Exception("Unknown entity type: $type");
  // }

  Future<FetchResult<Entity>> getEntity({required String entityName}) =>
      retrieve(
          conn: apiConnector,
          fromCached: (pool) =>
              pool.get<User>(entityName) ?? pool.get<Group>(entityName),
          url: "/entities/@$entityName",
          parse: (res, unpacked) =>
              unpacked.parse<Entity>(res["data"]["entity"]));
}
