import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/model/fetch_result.dart';

class LoadStability extends InheritedWidget {
  final bool isLoading;
  final FetchResult<void> anchor;
  final DateTime? lastUpdateInitiation;
  final bool isRoot;

  const LoadStability({
    required this.isLoading,
    required this.anchor,
    required this.lastUpdateInitiation,
    required this.isRoot,
    required Widget child,
    Key? key
  }) : super(child: child, key: key);

  factory LoadStability.combine({
    required Widget child,
    required LoadStability? prev,
    required bool isThisLoading,
    required DateTime? lastUpdateInitiation,
    required List<FetchResult<void>> anchors,
    required bool isRoot,
    Key? key
  }) {
    return LoadStability(
      isLoading: isThisLoading || (prev?.isLoading ?? false),
      anchor: FetchResult.mergeMany([prev?.anchor, ...anchors].whereNotNull()),
      lastUpdateInitiation: lastUpdateInitiation,
      key: key,
      child: child,
      isRoot: isRoot,
    );
  }
  
  // static LoadStability? of(BuildContext context) {
  //   return context.dependOnInheritedWidgetOfExactType<LoadStability>();
  // }

  static LoadStability? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LoadStability>();
  }

  @override
  bool updateShouldNotify(LoadStability oldWidget) {
    return isLoading != oldWidget.isLoading
    || anchor != oldWidget.anchor;
  }


}