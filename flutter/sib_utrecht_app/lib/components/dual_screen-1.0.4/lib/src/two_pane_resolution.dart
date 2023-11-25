
import 'package:flutter/material.dart';
import 'two_pane.dart';

class TwoPaneResolution extends InheritedWidget {
  final TwoPanePriority resolvedPanePriority;

  const TwoPaneResolution(
      {Key? key, required Widget child, required this.resolvedPanePriority})
      : super(key: key, child: child);

  static TwoPaneResolution? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TwoPaneResolution>();
  }

  static TwoPaneResolution of(BuildContext context) {
    final TwoPaneResolution? result = maybeOf(context);
    assert(result != null, 'No TwoPaneResolution found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TwoPaneResolution oldWidget) =>
      resolvedPanePriority != oldWidget.resolvedPanePriority;

}
