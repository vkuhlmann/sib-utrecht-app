import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';

class Entities {
  final APIConnector apiConnector;

  Entities(this.apiConnector);

  Future<Entity> getEntity({required String entityName}) async {
    var raw = await apiConnector.getSimple("/entities/@$entityName");

    var a = (raw["data"]["entity"] as Map).entries.first;
    var type = a.key;
    var data = a.value as Map;

    if (type == "user") {
      return User.fromJson(
          data.map((key, value) => MapEntry<String, dynamic>(key, value)));
    }

    if (type == "group") {
      return Group.fromJson(
          data.map((key, value) => MapEntry<String, dynamic>(key, value))
      );
    }

    throw Exception("Unknown entity type: $type");
  }
}
