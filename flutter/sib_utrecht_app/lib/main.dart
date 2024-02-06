import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:sib_utrecht_app/log.dart';

import 'shell.dart';


late MyApp app;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time} [${record.loggerName}] ${record.message}');
  });

  GoogleFonts.config.allowRuntimeFetching = true;

  LicenseRegistry.addLicense(() async* {
    final license2 = await rootBundle.loadString('assets/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license2);

    final license = await rootBundle.loadString('assets/fonts/RobotoMono/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);

    final license3 = await rootBundle.loadString('assets/fonts/Roboto/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license3);

    // final license4 = await rootBundle.loadString('lib/components/dual_screen-1.0.4/LICENSE');
    final license4 = await rootBundle.loadString('assets/dual_screen-LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['dual_screen'], license4);
  });

  // BEGIN Source: https://stackoverflow.com/questions/64552637/how-can-i-solve-flutter-problem-in-release-mode
  // answer by https://stackoverflow.com/users/9512756/nikhil-vadoliya
  // Modified
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() { inDebug = true; return true; }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) {
      return ErrorWidget(details.exception);
    }
    log.severe("Encountered error: ${details.exception}\n${details.stack}");

    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
       'Error: ${details.exception}\n${details.stack}',
        style: const TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };
  // END Source

  var a = const MyApp();
  app = a;
  runApp(a);
}

class Preferences extends InheritedWidget {
  const Preferences({super.key, required super.child, required this.locale, required this.debugMode});

  final Locale locale;
  final bool debugMode;

  static Preferences? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Preferences>();
  }

  static Preferences of(BuildContext context) {
    final Preferences? result = maybeOf(context);
    if (result == null) {
      throw Exception('No Preferences found in context');
    }

    // assert(result != null, 'No Preferences found in context');
    return result;
  }

  @override
  bool updateShouldNotify(Preferences oldWidget) => locale != oldWidget.locale;
}
