import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'dart:math' as math;

Widget EntityAppBar(Entity entity) {
  const double appBarMinHeight = 72;
  const double appBarMaxHeight = 200;

  return SliverAppBar(
    automaticallyImplyLeading: false,
    toolbarHeight: appBarMinHeight,
    pinned: true,
    expandedHeight: appBarMaxHeight,
    flexibleSpace: EntityHeader(
        user: entity,
        appBarMinHeight: appBarMinHeight,
        appBarMaxHeight: appBarMaxHeight),
  );
}

class EntityHeader extends StatelessWidget {
  final Entity user;
  final double _appBarMinHeight;
  final double _appBarMaxHeight;

  const EntityHeader(
      {Key? key,
      required this.user,
      required double appBarMinHeight,
      required double appBarMaxHeight})
      : _appBarMinHeight = appBarMinHeight,
        _appBarMaxHeight = appBarMaxHeight,
        super(key: key);

  Matrix4 getNameHeaderTransform(Animation<double> animation) {
    final scale = Tween<double>(begin: 80, end: 4).evaluate(
        CurvedAnimation(parent: animation, curve: Curves.easeInQuart));

    final rotation = Tween<double>(begin: 0, end: math.pi / 2)
        .evaluate(CurvedAnimation(parent: animation, curve: Curves.easeInCirc));

    Vector3 translationVector = Matrix4.diagonal3(Vector3.all(scale)) *
        Matrix4.rotationZ(rotation).transform3(Vector3(1, 0, 0));

    return Matrix4.translation(translationVector);
  }

  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final expansionRatio = clampDouble(
            (constraints.maxHeight - _appBarMinHeight) /
                (_appBarMaxHeight - _appBarMinHeight),
            0,
            1);

        final animation = AlwaysStoppedAnimation(expansionRatio);

        return Stack(children: [
          Align(
              alignment: AlignmentTween(
                begin: Alignment.topLeft,
                end: Alignment.center,
              ).evaluate(animation),
              child: Transform.translate(
                  offset: Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: const Offset(0, -20),
                  ).evaluate(animation),
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Transform.scale(
                        scale: Tween<double>(
                          begin: 1,
                          end: 2.2,
                        ).evaluate(animation),
                        child: EntityIcon(entity: user),
                      )))),
          Align(
              alignment: AlignmentTween(
                begin: Alignment.centerLeft,
                end: Alignment.bottomCenter,
              ).evaluate(animation),
              child: Transform.translate(
                  offset: Tween<Offset>(
                    begin: const Offset(0, 0),
                    end: const Offset(0, -20),
                  ).evaluate(animation),
                  child: Transform(
                      alignment: AlignmentTween(
                        begin: Alignment.centerLeft,
                        end: Alignment.topCenter,
                      ).evaluate(animation),
                      transform: getNameHeaderTransform(animation),
                      child: Text(user.getLocalLongName(Localizations.localeOf(context)),
                          style: Theme.of(context).textTheme.headlineSmall)))),
        ]);
      });
}
