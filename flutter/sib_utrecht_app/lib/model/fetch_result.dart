import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

@immutable
class FetchResult<T> {
  final T value;
  final DateTime? timestamp;
  final bool invalidated;

  const FetchResult(this.value, this.timestamp, {this.invalidated = false});

  FetchResult<U> mapValue<U>(U Function(T) f) {
    return FetchResult(f(value), timestamp, invalidated: invalidated);
  }

  FetchResult<U> withValue<U>(U value) {
    return mapValue((_) => value);
  }

  Future<FetchResult<U>> mapValueAsync<U>(FutureOr<U> Function(T) f) async {
    return FetchResult(await f(value), timestamp, invalidated: invalidated);
  }

  FetchResult<T> asInvalidated() {
    return FetchResult(value, timestamp, invalidated: true);
  }

  static FetchResult<void> merge(FetchResult<void> one, FetchResult<void> two) {
    DateTime? timestamp = one.timestamp;
    if (timestamp == null || two.timestamp?.isAfter(timestamp) == true) {
      timestamp = two.timestamp;
    }

    return FetchResult<void>(null, timestamp,
        invalidated: one.invalidated || two.invalidated);
  }

  static FetchResult<void> mergeMany(Iterable<FetchResult<void>> vals) {
    return vals.fold(const FetchResult<void>(null, null), (previousValue, element) => FetchResult.merge(previousValue, element));
  }

  // Future<FetchResult<T>> wait()

  bool isObsolete({Duration expireTime = const Duration(minutes: 5)}) {
    return invalidated ||
        timestamp?.isBefore(DateTime.now().subtract(expireTime)) != false;
  }

  Map toJson(dynamic Function(T) serialize) => {
        "value": serialize(value),
        "timestamp": timestamp?.toIso8601String(),
        "invalidated": invalidated
      };

  static FetchResult<T> fromJson<T>(Map json, T Function(dynamic) parse) {
    DateTime? timestamp;

    String? ts = json["timestamp"] as String?;
    if (ts != null) {
      timestamp = DateTime.parse(ts);
    }

    return FetchResult(parse(json["value"]), timestamp,
        invalidated: json["invalidated"] as bool? ?? false);
  }

  @override
  String toString() {
    return "FetchResult($value, $timestamp, $invalidated)";
  }
}

