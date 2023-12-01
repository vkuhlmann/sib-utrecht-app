import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sib_utrecht_app/model/user.dart';

import '../model/event.dart';

@immutable
class AnnotatedUser extends User {
  final String? comment;
  
  AnnotatedUser({
    required User user,
    this.comment
  }) : super(data: user.data);
}
