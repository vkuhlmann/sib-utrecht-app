import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import '../model/login_state.dart';

class APIAccess extends InheritedWidget {
  
  const APIAccess({super.key, required super.child, required this.state, required this.pool,
  required this.connector
  });
  // : connector = state.then((s) => 
  
  // s.connector);

  final Future<LoginState> state;
  final Future<CacherApiConnector> connector;
  final ResourcePool pool;

  // Users get users => Users(connector);

  static APIAccess? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<APIAccess>();
  }

  static APIAccess of(BuildContext context) {
    final APIAccess? result = maybeOf(context);
    assert(result != null, 'No APIAccess found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(APIAccess oldWidget) => state != oldWidget.state
  || pool != oldWidget.pool;
}
