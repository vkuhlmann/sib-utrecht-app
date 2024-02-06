import 'package:flutter/material.dart';

class AppbarSuppression extends InheritedWidget {
  final bool suppressTitle;
  final bool suppressMenu;
  final bool suppressBackbutton;

  const AppbarSuppression(
      {Key? key, required Widget child, required this.suppressTitle,
      required this.suppressMenu, required this.suppressBackbutton,})
      : super(key: key, child: child);

  static AppbarSuppression? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppbarSuppression>();
  }

  static AppbarSuppression of(BuildContext context) {
    final AppbarSuppression? result = maybeOf(context);
    if (result == null) {
      throw Exception('No AppbarSuppression found in context');
    }

    // assert(result != null, 'No AppbarSuppression found in context');
    return result;
  }

  @override
  bool updateShouldNotify(AppbarSuppression oldWidget) =>
      suppressTitle != oldWidget.suppressTitle;
}
