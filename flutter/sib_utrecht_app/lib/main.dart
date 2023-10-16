import 'dart:async';
import 'dart:convert';
import 'dart:math';
// import 'dart:html';
// import 'dart:collection';

import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:tuple/tuple.dart';

import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:html_unescape/html_unescape.dart';

// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import 'model/cors_fallback.dart'
  if (dart.library.html) 'model/cors_web.dart';

import 'theme_fallback.dart'
  if (dart.library.html) 'theme_web.dart';


part 'utils.dart';
part 'shell.dart';
part 'router.dart';

part 'pages/events.dart';
part 'pages/info.dart';
// part 'pages/authorize.dart';
part 'pages/event.dart';
part 'pages/login.dart';
part 'pages/new_login.dart';
part 'pages/new_login2.dart';
part 'pages/api_debug.dart';
part 'pages/feed.dart';
part 'pages/management.dart';
part 'pages/edit_event.dart';

part 'components/event_tile.dart';
part 'components/event_group.dart';
part 'components/alerts_panel.dart';
part 'components/weekday_indicator.dart';
part 'components/signup_indicator.dart';
part 'components/dialog_page.dart';

part 'view_model/cached_provider.dart';
part 'view_model/async_patch.dart';
part 'view_model/locale_date_format.dart';
part 'view_model/annotated_event.dart';
part 'view_model/event_participation.dart';
part 'view_model/event_placement.dart';

part 'model/login_manager.dart';
part 'model/api_connector.dart';
part 'model/api_error.dart';
part 'model/event.dart';



// late Future<void> dateFormattingInitialization;
// const String wordpressUrl = "http://192.168.50.200/wordpress";
const String wordpressUrl = "https://sib-utrecht.nl";
const String defaultApiUrl = "$wordpressUrl/wp-json/sib-utrecht-wp-plugin/v1";
const String authorizeAppUrl =
    "$wordpressUrl/wp-admin/authorize-application.php";
const String authRedirectTarget = "https://sib-utrecht-editions.vincentk.nl/development/#/new-login";

final log = Logger("main.dart");
late LoginManager loginManager;
late MyApp app;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time} [${record.loggerName}] ${record.message}');
  });

// 2023-01-01 is in 2022-W52, hence returns (2022, 52)
//   - 2024-12-25 is in 2024-W52, hence returns (2024, 52)
//   - 2024-12-30 is in 2025-W01, hence returns (2025, 1)

  // log.info(formatWeekNumber(DateTime(2023, 1, 1)));
  // log.info(formatWeekNumber(DateTime(2024, 12, 25)));
  // log.info(formatWeekNumber(DateTime(2024, 12, 30)));
  // log.info(formatWeekNumber(DateTime(2023, 9, 9)));

  // var dateFormattingInitialization = Future.delayed(const Duration(seconds: 0))
  //     .then((_) => Future.wait([
  //           initializeDateFormatting("nl_NL"),
  //           initializeDateFormatting("en_GB")
  //         ]));

  GoogleFonts.config.allowRuntimeFetching = true;

  LicenseRegistry.addLicense(() async* {
    final license2 = await rootBundle.loadString('../../LICENSE');
    yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license2);

    final license = await rootBundle.loadString('assets/fonts/RobotoMono/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);

    final license3 = await rootBundle.loadString('assets/fonts/Roboto/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license3);
  });

  loginManager = LoginManager();
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
