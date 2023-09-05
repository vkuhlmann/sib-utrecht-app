import 'dart:async';
import 'dart:convert';
// import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:tuple/tuple.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:photo_view/photo_view_gallery.dart';
import 'package:logging/logging.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:flutter_html/flutter_html.dart';
// import 'package:flutter_html/style.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

part 'login_manager.dart';
part 'api_connector.dart';
part 'async_patch.dart';
part 'pages/activities.dart';
part 'pages/debug.dart';
part 'pages/info.dart';
part 'pages/authorize.dart';
part 'pages/event.dart';
part 'pages/login.dart';
part 'pages/new-login.dart';
part 'utils.dart';
part 'shell.dart';
part 'router.dart';

part 'event.dart';
part 'locale_date_format.dart';

late Future<void> dateFormattingInitialization;
// const String wordpressUrl = "http://192.168.50.200/wordpress";
const String wordpressUrl = "https://sib-utrecht.nl";
const String apiUrl = "$wordpressUrl/wp-json/sib-utrecht-wp-plugin/v1";
const String authorizeAppUrl =
    "$wordpressUrl/wp-admin/authorize-application.php";

final log = Logger("main.dart");
late LoginManager loginManager;

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  dateFormattingInitialization = Future.delayed(const Duration(seconds: 0))
      .then((_) => Future.wait([
            initializeDateFormatting("nl_NL"),
            initializeDateFormatting("en_GB")
          ]));

  GoogleFonts.config.allowRuntimeFetching = true;

  // Seems like LicenseRegistry is not available in my current version of Flutter =/
  //
  LicenseRegistry.addLicense(() async* {
    final license2 = await rootBundle.loadString('LICENSE');
    yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license2);

    final license = await rootBundle.loadString('assets/fonts/RobotoMono/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  // LicenseRegistry.addLicense(() async* {
  //   final license = await rootBundle.loadString('LICENSE');
  //   yield LicenseEntryWithLineBreaks(['sib_utrecht_app'], license);
  // });
  // .then((_) => Future.value());
  // .then((_) => runApp(const MyApp()));
  loginManager = LoginManager();
  runApp(const MyApp());
}



class Preferences extends InheritedWidget {
  const Preferences({super.key, required super.child, required this.locale});

  final String locale;

  static Preferences? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Preferences>();
  }

  static Preferences of(BuildContext context) {
    final Preferences? result = maybeOf(context);
    assert(result != null, 'No Preferences found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Preferences old) => locale != old.locale;
}
