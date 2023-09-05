part of 'main.dart';

String formatErrorMsg(String? error) {
  if (error == null) {
    return "An error occurred";
  }

  var m = RegExp(
      r"^(Exception: )?(<strong>Error:</strong> )?(?<message>.*)$")
  .firstMatch(error);

  return m?.namedGroup("message") ?? error;
}

Widget formatError(Object? error) {
    return Text(formatErrorMsg(error?.toString()));
}
