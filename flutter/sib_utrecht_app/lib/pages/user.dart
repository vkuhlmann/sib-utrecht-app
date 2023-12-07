import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/user_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

// AppBar expansion animation code based on
// https://medium.com/flutter-community/flutter-sliverappbar-snap-those-headers-544e097248c0
// by Lê Dân (https://medium.com/@danledev)

class UserPageContents extends StatelessWidget {
  final User user;

  final double _appBarMinHeight = 72;
  final double _appBarMaxHeight = 200;

  const UserPageContents({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CustomScrollView(
      slivers: [
        SliverAppBar(
          // leading: EntityIcon(entity: user),
          // leading: const SizedBox(),
          automaticallyImplyLeading: false,
          toolbarHeight: _appBarMinHeight,
          // backgroundColor: Colors.greenAccent,
          // shadowColor: Colors.greenAccent,
          // surfaceTintColor: Colors.greenAccent,
          // foregroundColor: Colors.greenAccent,
          // title: Row(mainAxisSize: MainAxisSize.min, children: [
          //   EntityIcon(entity: user),
          //   const SizedBox(width: 16),
          //   Text(user.longName)
          // ]),
          pinned: true,
          expandedHeight: _appBarMaxHeight,
          // stretch: true,
          flexibleSpace:
              // FlexibleSpaceBar(
              //   background: Container(
              //     // color: Colors.blue[800],
              //   child: Center(child:
              LayoutBuilder(builder: (context, constraints) {
            final expansionRatio = clampDouble(
                (constraints.maxHeight - _appBarMinHeight) /
                    (_appBarMaxHeight - _appBarMinHeight),
                0,
                1);

            final animation = AlwaysStoppedAnimation(expansionRatio);

            return
                // Transform.translate(offset:
                // Tween<Offset>(
                //   begin: const Offset(-200, 0),
                //   end: const Offset(0, 100),
                // ).evaluate(animation),
                // Align(
                //     alignment: AlignmentTween(
                //       begin: Alignment.topLeft,
                //       end: Alignment.center,
                //     ).evaluate(animation),
                //     child:
                Container(
                  // color: Colors.black, 
                child:
                Stack(children: [
              // Align(alignment: Alignment.center, child:
              Align(
                  alignment: AlignmentTween(
                    begin: Alignment.topLeft,
                    end: Alignment.center,
                  ).evaluate(animation),
                  child: 
                  Transform.translate(
                    offset: Tween<Offset>(
                      begin: const Offset(0, 0),
                      end: const Offset(0, -20),
                    ).evaluate(animation),
                    child:
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Transform.scale(
                        scale: Tween<double>(
                          begin: 1,
                          end: 2.2,
                        ).evaluate(animation),
                        child:
                            // Transform.translate(
                            //   offset: Tween<Offset>(
                            //     begin: const Offset(0, 0),
                            //     end: const Offset(0, -100),
                            //   ).evaluate(animation),
                            // child:
                            EntityIcon(entity: user),
                        // ),
                      )))),
              // PositionedTransition(
              //     rect: RelativeRectTween(
              //       begin: RelativeRect.fromLTRB(0, 0, 0, 0),
              //       end: RelativeRect.fromLTRB(0, 0, 0, 0),
              //     ).animate(animation),
              //     // child: Align(
              //     //     alignment: AlignmentTween(
              //     //       begin: Alignment.centerRight,
              //     //       end: Alignment.topCenter,
              //     //     ).evaluate(animation),
              //         child:
              Align(
                  alignment: AlignmentTween(
                    begin: Alignment.centerLeft,
                    end: Alignment.bottomCenter,
                  ).evaluate(animation),
                  child: 
                  Transform.translate(
                    offset: Tween<Offset>(
                      begin: const Offset(0, 0),
                      end: const Offset(0, -20),
                    ).evaluate(animation),
                    child:
                  Transform(
                      alignment: AlignmentTween(
                        begin: Alignment.centerLeft,
                        end: Alignment.topCenter,
                      ).evaluate(animation),
                      transform: 
                          Matrix4.translation(
                            Matrix4.diagonal3(Vector3(1, 1, 1) *
                              Tween<double>(begin: 80, end: 4)
                                  .evaluate(CurvedAnimation(parent:
                                            animation,
                                            curve: Curves.easeInQuart
                                            )))
                                  *
                            Matrix4.rotationZ(
                                  Tween<double>(begin: 0, end: 0.5)
                                          .evaluate(
                                            CurvedAnimation(parent:
                                            animation,
                                            curve: Curves.easeInCirc
                                            )
                                            ) *
                                      3.1415926535897932)
                              .transform3(Vector3(1, 0, 0))),
                      child: Container(
                          // color: Colors.blue,
                          // constraints: BoxConstraints(),
                          child: Text(user.longName,
                              style:
                                  Theme.of(context).textTheme.headlineSmall))))),
              // Align(
              //   alignment: AlignmentTween(
              //     begin: Alignment.bottomCenter,
              //     end: Alignment.center,
              //   ).evaluate(animation),
              //   child: Text(user.longName,
              //       style: Theme.of(context).textTheme.headlineSmall),
              // )
            ]));

            // Center(
            //       child: Tween) ScaleTransition(
            //     scale:
            //         AlwaysStoppedAnimation(constraints.maxHeight / 60),
            //     child: EntityIcon(entity: user),
            //   ));
          }
                  // ))

                  // child: Center(child:
                  // EntityIcon(entity: user)))
                  // background: Image.network(
                  //   user.photoUrl,
                  //   fit: BoxFit.cover,
                  // ),
                  ),
        ),
        SliverCrossAxisConstrained(maxCrossAxisExtent: 700, child: 
         SliverPadding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
         sliver: SliverToBoxAdapter(child: Column(children: [
UserCard(user: user),
Center(child: EntityTile(entity: user)),
Center(child: Text(user.entityName ?? "Missing entity name")),
const SizedBox(
                
                height: 1000,
                child: Center(child: Text("Hello")))
         ]),)
         )
        )
        // SliverPadding(
        //     padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        //     sliver: SliverList.list(
        //         children: confidants
        //             .map((user) =>
        //                 UserCard(user: user, key: ValueKey(user.entityName)))
        //             .toList()))
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
