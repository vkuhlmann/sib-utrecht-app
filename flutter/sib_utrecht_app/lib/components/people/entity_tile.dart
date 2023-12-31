import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/model/entity.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/annotated_user.dart';
import 'package:badges/badges.dart' as badges;

class EntityTile extends StatelessWidget {
  final Entity entity;

  const EntityTile({Key? key, required this.entity}) : super(key: key);

  Widget getCaption() {
    final ent = entity;
    if (ent is User) {
      return Text(
        ent.shortNameUnique,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (ent is Group) {
      return Builder(
          builder: (context) =>
              Text(ent.getLocalTitle(Localizations.localeOf(context))));
    }

    return const Text("Unknown");
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = EntityIcon(entity: entity);
    final ent = entity;

    String? comment;
    if (ent is AnnotatedUser && ent.comment?.isNotEmpty == true) {
      comment = ent.comment;
    }

    if (comment != null) {
      icon = Tooltip(
          message: comment,
          verticalOffset: 48,
          triggerMode: TooltipTriggerMode.longPress,
          child: badges.Badge(
              badgeContent:
                  const Icon(Icons.comment, size: 16, color: Colors.white),
              badgeStyle: badges.BadgeStyle(
                  padding: const EdgeInsets.all(4),
                  shape: badges.BadgeShape.circle,
                  badgeColor: (Theme.of(context).brightness == Brightness.light)
                      ? const Color.fromARGB(255, 255, 155, 74)
                      : const Color.fromARGB(255, 185, 84, 0),
                  elevation: 0),
              position: badges.BadgePosition.bottomEnd(bottom: 0),
              child: icon));
    }

    return GestureDetector(
        onTap: () {
          String? profilePage = ent.profilePage;

          showDialog(
              context: context,
              builder: (context) => 
              SelectionArea(child: AlertDialog(
                    title: Text(entity
                        .getLocalLongName(Localizations.localeOf(context))),
                    // content: Text("Entity: ${entity.runtimeType}\n\n${entity.toString()}"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (comment != null)
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Comment:"),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 8, 32),
                                        child: Text(comment))
                                  ])),
                        if (profilePage != null)
                          FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                GoRouter.of(context).go(profilePage);
                              },
                              child: const Text("Open profile")),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Close"))
                    ],
                  )));
        },
        child: SizedBox(
            width: 90,
            height: 100,
            child: Container(
                color: Colors.transparent,
                child: Column(children: [
                  Padding(padding: const EdgeInsets.all(8), child: icon),
                  // const SizedBox(height: 3,),
                  getCaption(),
                ]))));
  }
}
