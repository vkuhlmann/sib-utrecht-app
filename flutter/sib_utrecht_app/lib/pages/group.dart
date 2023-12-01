import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/view_model/group_provider.dart';

class GroupAppBar extends StatelessWidget {
  final Group group;

  const GroupAppBar({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) => SliverAppBar(
        automaticallyImplyLeading: false,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          EntityIcon(entity: group),
          const SizedBox(width: 16),
          Text(group.getLocalTitle(Localizations.localeOf(context)))
        ]),
        pinned: true,
        expandedHeight: 200,
        flexibleSpace: LayoutBuilder(
            builder: (context, constraints) => Center(
                    child: ScaleTransition(
                  scale: AlwaysStoppedAnimation(constraints.maxHeight / 60),
                  child: EntityIcon(entity: group),
                ))),
      );
}

class GroupPage extends StatelessWidget {
  final String entityName;

  const GroupPage({Key? key, required this.entityName}) : super(key: key);

  @override
  Widget build(BuildContext context) => GroupProvider.Single(
      query: entityName,
      builder: (context, group) => SelectionArea(
              child: CenteredPageScroll(
            slivers: [
              GroupAppBar(group: group),
              SliverToBoxAdapter(
                  child: Column(children: [
                GroupCard(group: group),
                Center(child: EntityTile(entity: group)),
                Center(child: Text(group.groupName)),
                FilledButton(onPressed: () {
                  GoRouter.of(context).goNamed("group_members", pathParameters: {
                    "group_name": group.groupName,
                  });
                }, child: const Text("See members"))
              ])),
            ],
          )));
}
