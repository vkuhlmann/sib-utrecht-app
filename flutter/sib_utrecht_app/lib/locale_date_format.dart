part of 'main.dart';

class LocaleDateFormat extends StatelessWidget {
  const LocaleDateFormat({Key? key, required this.date, this.format = "yMMMMEEEEd"})
      : super(key: key);

  final DateTime date;
  final String format;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: dateFormattingInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(
                  DateFormat(format, Preferences.of(context).locale)
                          .format(date));
          } else {
            try{
              return Text(DateFormat(format).format(date));
            } catch (e) {
              // return const Text("...");
              return Text(date.toString());
            }
            // return Text("Loading...");
          }
        });
    // return Text(format.format(date));
  }
}

