import 'package:flutter/material.dart';
import '../model/login_state.dart';

class APIAccess extends InheritedWidget {
  const APIAccess({super.key, required super.child, required this.state});

  final Future<LoginState> state;

  static APIAccess? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<APIAccess>();
  }

  static APIAccess of(BuildContext context) {
    final APIAccess? result = maybeOf(context);
    assert(result != null, 'No APIAccess found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(APIAccess oldWidget) => state != oldWidget.state;
}
