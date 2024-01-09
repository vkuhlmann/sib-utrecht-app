import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/provider/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/wp_users_provider.dart';

class UsersPageContents extends StatelessWidget {
  final List<User> users;
  final Set<String> members;
  final Set<String> alumni;
  final Future Function(User, String role, String prevRole) setRole;
  final Map<String, Future> pendingChanges;

  const UsersPageContents(
      {Key? key,
      required this.users,
      required this.members,
      required this.alumni,
      required this.setRole,
      required this.pendingChanges})
      : super(key: key);

  String getRole(User user) {
    final entityName = user.entityName;
    if (members.contains(entityName)) {
      return "member";
    }
    if (alumni.contains(entityName)) {
      return "alumnus";
    }
    return "unknown";
  }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final brightness = Theme.of(context).brightness;

    Color selectedColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 133, 211, 248)
        : Colors.blue.withAlpha(100);

    Color alumnusColor =
        // Theme.of(context).brightness == Brightness.light
        //     ? const Color.fromARGB(255, 248, 177, 133)
        // :
        const Color.fromARGB(255, 115, 255, 0).withAlpha(100);

    Map<String, Color?> colors = {
      "member": selectedColor,
      "alumnus": alumnusColor,
      "unknown": null
    };

    return SelectionArea(
        child: CenteredPageScroll(
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 32),
            sliver: SliverList.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  // children: users.map((el) {
                  final user = users[index];
                  final entityName = user.entityName;

                  // final isMember = members.contains(entityName);
                  // final isAlumnus = alumni.contains(entityName);
                  // final state =
                  //     isMember ? "member" : (isAlumnus ? "alumnus" : "unknown");
                  final state = getRole(user);

                  final pendingChange = pendingChanges[user.id];

                  Color? color = colors[state];
                  if (brightness == Brightness.light && color != null) {
                    color = HSLColor.fromColor(color.withAlpha(255))
                        .withLightness(0.9)
                        .toColor();
                  }

                  Color? highlightColor = color?.withAlpha(255);
                  if (highlightColor != null) {
                    highlightColor = HSLColor.fromColor(highlightColor)
                        .withLightness(brightness == Brightness.light
                            ? 0.7
                            : (state == "alumnus" ? 0.3 : 0.4))
                        .toColor();
                  }

                  return 
                  Padding(padding: const EdgeInsets.symmetric(vertical: 4), child:
                  Card(
                      key: ValueKey(user.id),
                      clipBehavior: Clip.antiAlias,
                      color: color,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.only(left: 16, bottom: 16, top: 12, right: 16),
                        title: Text(user.longName),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.email ?? ""),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                // mainAxisAlignment: ,
                                children: [
                                  SegmentedButton(
                                    showSelectedIcon: false,
                                    style: (Theme.of(context)
                                                .segmentedButtonTheme
                                                .style ??
                                            const ButtonStyle())
                                        .copyWith(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => states.contains(
                                                      MaterialState.selected)
                                                  ? highlightColor
                                                  : null),
                                      // shadowColor:
                                      //     MaterialStateProperty.all(Colors.red),
                                      // // backgroundColor: MaterialStateProperty.all(Colors.orange),
                                      // surfaceTintColor:
                                      //     MaterialStateProperty.all(
                                      //         Colors.yellow),
                                      // overlayColor: MaterialStateProperty.all(
                                      //     Colors.orange),
                                      // shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    )
                                    // Theme.of(context)
                                    //     .segmentedButtonTheme
                                    //     .style
                                    //     ?.copyWith(
                                    //         shadowColor:
                                    //             MaterialStateProperty.all(
                                    //                 Colors.red),
                                    //         elevation: MaterialStateProperty.all(30)
                                    //         //  Colors.red,
                                    //         ),
                                    ,
                                    segments: const [
                                      ButtonSegment(
                                        label: Text("Unknown"),
                                        value: "unknown",
                                        // icon: Icon(Icons.question_mark)
                                      ),
                                      ButtonSegment(
                                          label: Text("Member"),
                                          value: "member"),
                                      ButtonSegment(
                                          label: Text("Alumnus"),
                                          value: "alumnus")
                                    ],
                                    selected: {state},
                                    onSelectionChanged: (p0) {
                                      // log.fine(p0);
                                      setRole(user, p0.first, state);
                                    },
                                  ),
                                  if (pendingChange != null)
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        // child: SizedBox(
                                        //     width: 16,
                                        //     height: 16,
                                        child: Center(
                                            child: FutureBuilderPatched(
                                                future: pendingChange,
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasError) {
                                                    return Tooltip(
                                                        message:
                                                            "Error: ${snapshot.error}",
                                                        child: const Icon(Icons
                                                            .error_outline));
                                                  }

                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ));
                                                  }

                                                  return const Icon(
                                                      Icons.question_mark);
                                                })))
                                  // const SizedBox(width: 8),
                                  // OutlinedButton(
                                  //     onPressed: () {}, child: Text("Member")),
                                  // OutlinedButton(
                                  //     onPressed: () {}, child: Text("Alumnus")),
                                ],
                              ),
                              // const SizedBox(height: 8)
                            ]),
                        onTap: () async {
                          final conn = await APIAccess.of(context).connector;

                          String id = user.id;
                          if (id.startsWith("wp-user-")) {
                            id = await Users(conn)
                                .getOrCreateUser(wpId: user.wpId);
                          }

                          router.pushNamed("user_page",
                              pathParameters: {"entity_name": id});
                        },
                        // trailing: entityName == null
                        //     ? IconButton(
                        //         onPressed: () async {
                        //           final conn =
                        //               await APIAccess.of(context).connector;

                        //           late String value;
                        //           try {
                        //             value = await Users(conn)
                        //                 .getOrCreateUser(wpId: user.wpId);
                        //           } catch (error) {
                        //             messenger.showSnackBar(SnackBar(
                        //                 content: Text("Error: $error")));
                        //             return;
                        //           }

                        //           router.pushNamed("user_page",
                        //               pathParameters: {"entity_name": value});
                        //         },
                        //         icon: const Icon(Icons.add))
                        //     : IconButton(
                        //         onPressed: () {
                        //           GoRouter.of(context).pushNamed("user_page",
                        //               pathParameters: {
                        //                 "entity_name": entityName
                        //               });
                        //         },
                        //         icon: const Icon(Icons.arrow_forward_ios)),
                      )));
                } //).toList()
                ))
      ],
    ));
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Map<String, Future> _pendingChanges;

  @override
  void initState() {
    super.initState();

    _pendingChanges = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _doSetMembership(
      {required String userId,
      required String longName,
      required String group,
      required bool val,
      required APIConnector conn}) async {
    if (val) {
      await Groups(conn)
          .addMember(groupName: group, userId: userId, role: "member");
      return;
    }

    await Groups(conn)
        .removeMember(groupName: group, userId: userId, role: "member");
  }

  // Future<void> _doSetAlumnus(User user, bool val, APIConnector conn) async {
  //   if (val) {
  //     await Groups(conn)
  //         .addMember(groupName: "alumni", userId: user.id, role: "member");
  //     return;
  //   }

  //   await Groups(conn)
  //       .removeMember(groupName: "alumni", userId: user.id, role: "member");
  // }

  Future<void> setRole(User user, String role, String prevRole) async {
    final fut = _doSetRole(user, role, prevRole);
    setState(() {
      _pendingChanges[user.id] = fut;
    });

    try {
      await fut;
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to change role for ${user.longName}: $e"),
      ));
      return;
    }

    // final isSuccess = await fut;
    if (mounted && _pendingChanges[user.id] == fut) {
      log.fine("Removing pending change for ${user.id}");

      setState(() {
        _pendingChanges.remove(user.id);
      });
    }
  }

  Future<void> _doSetRole(User user, String role, String prevRole) async {
    final connector = await APIAccess.of(context).connector;
    String userId = user.id;

    if (userId.startsWith("wp-user-")) {
      // late String value;
      // try {
      userId = await Users(connector).getOrCreateUser(wpId: user.wpId);
      // } catch (error) {
      //   messenger.showSnackBar(SnackBar(content: Text("Error: $error")));
      //   return;
      // }
      // router.pushNamed("user_page", pathParameters: {"entity_name": value});
    }

    // try {
    await Future.wait([
      if (prevRole == "member" || role == "member")
        _doSetMembership(
            userId: userId,
            longName: user.longName,
            val: role == "member",
            conn: connector,
            group: "members"),
      if (prevRole == "alumnus" || role == "alumnus")
        _doSetMembership(
            userId: userId,
            longName: user.longName,
            val: role == "alumnus",
            conn: connector,
            group: "alumni"),
      // _doSetAlumnus(userId, user.longName, role == "alumnus", connector)
    ], eagerError: false);
    // if (role == "member")

    // else
    //   await Groups(connector).removeMember(
    //       groupName: "members", userId: user.id, role: "member");

    // await Groups(connector)
    //     .addMember(groupName: groupName, userId: user.id, role: role);
    // } catch (e) {
    //   if (!mounted) {
    //     return false;
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text("Failed to change role for ${user.longName}: $e"),
    //   ));
    //   return false;
    // }

    // if (!mounted) {
    //   return true;
    // }
    // // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // //   content: Text("Added ${user.longName} to $groupName"),
    // // ));
    // return true;
  }

  @override
  Widget build(BuildContext context) {
    return ActionSubscriptionAggregator(
        child: WPUsersProvider(
            builder: (context, userIds, _) => UserProvider.Multiplexed(
                query: userIds,
                builder: (context, usersResults) => GroupMembersProvider(
                    groupName: "members",
                    builder: (context, members, _) => GroupMembersProvider(
                        groupName: "alumni",
                        builder: (context, alumni, _) => Column(children: [
                              Expanded(
                                  child: UsersPageContents(
                                      users: usersResults
                                          .map((e) => e.value)
                                          .toList()
                                          .sortedBy(
                                              (element) => element.longName.toLowerCase()),
                                      pendingChanges: _pendingChanges,
                                      setRole: setRole,
                                      members: members.memberships
                                          .map((e) => e.entity)
                                          .toSet(),
                                      alumni: alumni.memberships
                                          .map((e) => e.entity)
                                          .toSet())),
                            ]))))));
  }
}
