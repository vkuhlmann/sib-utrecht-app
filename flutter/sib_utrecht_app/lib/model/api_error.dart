part of '../main.dart';

class APIError implements Exception {
  final String message;
  final APIConnector connector;
  final int statusCode;
  final String responseBody;
  // final String? type;
  // final String? data;

  APIError(
      this.message,
      {
      required this.connector,
      required this.statusCode,
      required this.responseBody});

  // static APIError fromJson(Map<String, dynamic> json) {
  //   return APIError(
  //     message: json["message"],
  //     code: json["code"],
  //     type: json["type"],
  //     data: json["data"],
  //   );
  // }

  @override
  String toString() {
    return message;
  }
}
