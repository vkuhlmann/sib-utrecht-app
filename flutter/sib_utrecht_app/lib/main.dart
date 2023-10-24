// import 'dart:html';
// import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:tuple/tuple.dart';

// import 'package:intl/date_symbol_data_local.dart';

// import 'package:material_symbols_icons/symbols.dart';
import 'package:logging/logging.dart';

// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart';
import 'package:google_fonts/google_fonts.dart';

import 'shell.dart';


late MyApp app;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time} [${record.loggerName}] ${record.message}');
  });

  GoogleFonts.config.allowRuntimeFetching = true;

  LicenseRegistry.addLicense(() async* {
    final license2 = await rootBundle.loadString('../../LICENSE');
    yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license2);

    final license = await rootBundle.loadString('assets/fonts/RobotoMono/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);

    final license3 = await rootBundle.loadString('assets/fonts/Roboto/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license3);
  });

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
    assert(result != null, 'No Preferences found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Preferences oldWidget) => locale != oldWidget.locale;
}
