part of 'main.dart';

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
  if (
    error is APIError
    && [401, 403].contains(error.statusCode)
    && error.connector.user == null
    )
  {
    return FilledButton(
          onPressed: () {
            router.go("/login?immediate=true");
          },
          child: const Text("Please log in"));
    // return Text(formatErrorMsg(error.message));
  }

  String msg = formatErrorMsg(error?.toString());

  // if (msg.startsWith("Permission denied")) {
  //   return FutureBuilderPatched(builder: (context, snapshot) {
  //     if (snapshot.

  //     return Text("Loading...");
  //   });

  //   return ElevatedButton(
  //     onPressed: () => launch("https://www.lego.com/en-us/account/login"),
  //     child: Text("Log in"),
  //   );
  // }

  return Text(msg);
}

// Get a tuple of the ISO year and week number, e.g.:
//   - 2023-01-01 is in 2022-W52, hence returns (2022, 52)
//   - 2024-12-25 is in 2024-W52, hence returns (2024, 52)
//   - 2024-12-30 is in 2025-W01, hence returns (2025, 1)
//
// The first week of the year contains 4 January. (majority of days in the new
// year)
(int, int) getWeekNumber(DateTime dt) {
  DateTime thursday = dt.add(Duration(days: 4 - dt.weekday));
  int year = thursday.year;
  DateTime firstWeek = DateTime(year, 1, 4)
      .add(Duration(days: (1 - DateTime(year, 1, 4).weekday)));

  return (
    year,
    thursday.difference(firstWeek).inDays ~/ 7 + 1
  );

  // int thisYear = dt.year;
  // DateTime firstWeekStart = DateTime(thisYear, 1, 4)
  //     .add(Duration(days: (1 - DateTime(thisYear, 1, 4).weekday)));

  // if (!dt.isBefore(firstWeekStart)) {
  //   return (thisYear, (dt.difference(firstWeekStart).inDays ~/ 7) + 1);
  // }

  // firstWeekStart = DateTime(thisYear - 1, 1, 4)
  //     .add(Duration(days: (1 - DateTime(thisYear - 1, 1, 4).weekday)));

  // return (thisYear - 1, (dt.difference(firstWeekStart).inDays ~/ 7) + 1);

  // if (!thursday.isBefore(thisYearFirstThursday)) {
  //   return (
  //     thisYearFirstThursday.year,
  //     thursday.difference(thisYearFirstThursday).inDays ~/ 7
  //   );
  // }

  // DateTime lastYearFirstThursday = DateTime(thursday.year - 1, 1, 1)
  //     .add(Duration(days: (4 - DateTime(thursday.year - 1, 1, 1).weekday) % 7));
}

String formatWeekNumber(DateTime dt) {
  var (year, week) = getWeekNumber(dt);
  return "$year-W${week.toString().padLeft(2, '0')}";
}
