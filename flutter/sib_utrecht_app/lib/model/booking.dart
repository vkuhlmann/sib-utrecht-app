import 'package:sib_utrecht_app/model/cacheable_resource.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';

class Booking {
  String eventId;
  String entityId;
  String? comment;

  // AnnotatedUser user;

  Booking({required this.eventId,
  required this.entityId, required this.comment});
}
