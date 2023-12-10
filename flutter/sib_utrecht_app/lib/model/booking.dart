import 'package:sib_utrecht_app/view_model/annotated_user.dart';

class Booking {
  String eventId;
  String? userId;
  String? comment;

  AnnotatedUser user;

  Booking({required this.eventId,
  required this.userId, required this.comment, required this.user});
}
