import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/api_connector_http.dart';
import 'model/api_error.dart';
import 'package:go_router/go_router.dart';

FutureOr<U> foThen<T, U>(FutureOr<T> fut, FutureOr<U> Function(T) f) {
  if (fut is Future<T>) {
    return fut.then(f);
  }

  return f(fut);
}

FutureOr<T> foCatch<T>(FutureOr<T> fut, T Function(dynamic) onError) {
  if (fut is Future<T>) {
    return fut.catchError(onError);
  }

  return fut;
}

String formatErrorMsg(String? error) {
  if (error == null) {
    return "An error occurred";
  }

  var m = RegExp(r"^(Exception: )?(<strong>Error:</strong> )?(?<message>.*)$")
      .firstMatch(error);

  if (m?.namedGroup("message") == "Sorry, you are not allowed to do that.") {
    return "Permission denied (make sure you are logged in)";
  }

  return m?.namedGroup("message") ?? error;
}

Widget formatError(Object? error) {
  if (error is APIError && [401, 403].contains(error.statusCode)) {
    var c1 = error.connector;

    if (c1 is CacherApiConnector) {
      var c2 = c1.base;
      if (c2 is HTTPApiConnector && c2.user == null) {
        return Builder(
            builder: (context) => FilledButton(
                onPressed: () {
                  GoRouter.of(context).go("/login?immediate=true");
                },
                child: Text(AppLocalizations.of(context)?.loginRequired ??
                    "Please log in")));
      }
    }

    if (error.message.toString() == "Sorry, you are not allowed to do that.") {
      return const Text("Permission denied");
    }
  }

  String msg = formatErrorMsg(error?.toString());

  return Text(msg);
}

extension UtilsIterableExtensions<T> on Iterable<T> {
  // List<(K key, List<T> value)>
  List<MapEntry<K, List<T>>>
  chunkBy<K extends Comparable<K>>(
    K Function(T) keySelector,
    {List<K>? initialKeys}
  ) {
    // Based on: flutter collection package, groupBy function

    var map = <K, List<T>>{
      for (var key in initialKeys ?? []) key: [],
    };


    for (var element in this) {
      (map[keySelector(element)] ??= []).add(element);
    }
    return map.entries.sortedBy((element) => element.key);
  }
}
