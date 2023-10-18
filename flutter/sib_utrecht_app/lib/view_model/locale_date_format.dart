import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocaleDateFormat extends StatelessWidget {
  const LocaleDateFormat({Key? key, required this.date, this.format = "yMMMMEEEEd"})
      : super(key: key);

  final DateTime date;
  final String format;

  @override
  Widget build(BuildContext context) {
    // return Text(AppLocalizations.of(context).null.of(context).toString());
    return Text(DateFormat(format, Localizations.localeOf(context).toString()).format(date));
    // return Text(DateFormat(format, "nl_NL").format(date));
    // return Text(DateFormat(format).format(date) + Intl.getCurrentLocale()
    // + Localizations.localeOf(context).toString());
    // return FutureBuilder(future: dateFormattingInitialization,
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         return Text(
    //               DateFormat(format, Preferences.of(context).locale)
    //                       .format(date));
    //       } else {
    //         try{
    //           return Text(DateFormat(format).format(date));
    //         } catch (e) {
    //           // return const Text("...");
    //           return Text(date.toString());
    //         }
    //         // return Text("Loading...");
    //       }
    //     });
    // return Text(format.format(date));
  }
}

