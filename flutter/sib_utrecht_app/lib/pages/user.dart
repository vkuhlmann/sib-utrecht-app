import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/user_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class UserPageContents extends StatelessWidget {
  final User user;

  final double _appBarMinHeight = 72;
  final double _appBarMaxHeight = 200;

  const UserPageContents({Key? key, required this.user}) : super(key: key);

  Matrix4 getNameHeaderTransform(Animation<double> animation) {
    final scale = Tween<double>(begin: 80, end: 4).evaluate(
        CurvedAnimation(parent: animation, curve: Curves.easeInQuart));

    final rotation = Tween<double>(begin: 0, end: pi / 2)
        .evaluate(CurvedAnimation(parent: animation, curve: Curves.easeInCirc));

    Vector3 translationVector = Matrix4.diagonal3(Vector3.all(scale)) *
        Matrix4.rotationZ(rotation).transform3(Vector3(1, 0, 0));

    return Matrix4.translation(translationVector);
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: _appBarMinHeight,
          pinned: true,
          expandedHeight: _appBarMaxHeight,
          flexibleSpace: LayoutBuilder(builder: (context, constraints) {
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
                          child: Text(user.longName,
                              style:
                                  Theme.of(context).textTheme.headlineSmall)))),
            ]);
          }),
        ),
        SliverCrossAxisConstrained(
            maxCrossAxisExtent: 700,
            child: SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(children: [
                    UserCard(user: user),
                    Center(child: EntityTile(entity: user)),
                    Center(
                        child: Text(user.entityName ?? "Missing entity name")),
                    const SizedBox(
                        height: 1000, child: Center(child: Text("Hello")))
                  ]),
                )))
      ],
    ));
  }
}

class UserPage extends StatefulWidget {
  final String entityName;

  const UserPage({Key? key, required this.entityName}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // late GroupsProvider groupsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // groupsProvider = GroupsProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBar(title: Text("Groups")),
    //     body: GroupsPageContents.fromProvider(groupsProvider));
    // var provGroups = ResourcePoolAccess.of(context).pool.groupsProvider;
    return
        // WithSIBAppBar(
        //     actions: const [],
        //     child:
        UserProvider.Single(
            query: widget.entityName,
            builder: (context, user) => UserPageContents(user: user));
  }
}
