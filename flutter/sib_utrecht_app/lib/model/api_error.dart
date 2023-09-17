part of '../main.dart';

class APIError implements Exception {
  final String message;
  final APIConnector connector;
  final int statusCode;
  final String responseBody;

  APIError(
      this.message,
      {
      required this.connector,
      required this.statusCode,
      required this.responseBody});

  @override
  String toString() {
    return message;
  }
}
