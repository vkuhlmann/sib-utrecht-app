import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';

class LoginState {
  final APIConnector connector;
  final Map<String, Map<String, dynamic>> profiles;

  final String? activeProfileName;
  final Map<String, dynamic>? activeProfile;

  const LoginState(
      {required this.connector,
      required this.profiles,
      required this.activeProfileName,
      required this.activeProfile});
}
