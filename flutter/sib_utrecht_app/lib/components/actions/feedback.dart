
import 'package:flutter/material.dart';

class ActionFeedback {
  final Function(String) sendConfirm;
  final Function(String) sendError;

  ActionFeedback({required this.sendConfirm, required this.sendError});

  static void sendConfirmToast(BuildContext context, String message) {
    // Based on https://stackoverflow.com/questions/45948168/how-to-create-toast-in-flutter
    // answer by https://stackoverflow.com/users/8394265/r%c3%a9mi-rousselet
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) => createErrorDialog(text));
  }

  static Widget createErrorDialog(String text) {
    return AlertDialog(
        title: const Text('Error'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(text),
            ],
          ),
        ),
        actions: <Widget>[
          Builder(
              builder: (context) => TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })),
        ]);
  }
}

