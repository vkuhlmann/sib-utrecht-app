import 'model/login_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import 'router.dart' as router_class;
import 'log.dart' as log_class;

LoginManager loginManager = LoginManager();

// export router;
GoRouter get router => router_class.router;
Logger get log => log_class.log;

