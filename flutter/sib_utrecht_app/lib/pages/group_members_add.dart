import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/model/api/groups.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/provider/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/wp_users_provider.dart';

class GroupMembersAddPage extends StatefulWidget {
  final String groupName;

  const GroupMembersAddPage({Key? key, required this.groupName})
      : super(key: key);

  @override
  State<GroupMembersAddPage> createState() => _GroupMembersAddPageState();
}

class _GroupMembersAddPageState extends State<GroupMembersAddPage> {
  void reportError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void reportSuccess(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> addMember(User user, Locale loc) async {
    log.info("Adding member ${user.id} to group ${widget.groupName}");
    // ResourcePool? pool = ResourcePoolAccess.maybeOf(context)?.pool;
    final connector = await APIAccess.of(context).connector;

    try {
      await Groups(connector).addMember(
          groupName: widget.groupName, userId: user.id, role: "member");
    } catch (e) {
      reportError("Failed to add member: $e");
      return;
    }

    reportSuccess(
        "Added ${user.getLocalShortName(loc)} to ${widget.groupName}");

    // if (!mounted) {
    //   return;
    // }

    // final pool = ResourcePoolAccess.maybeOf(context);
    // if (pool != null) {
    // }
  }

  Future<void> removeMember(User user, Locale loc) async {
    log.info("Removing member ${user.id} from group ${widget.groupName}");
    final connector = await APIAccess.of(context).connector;

    try {
      await Groups(connector).removeMember(
          groupName: widget.groupName, userId: user.id, role: "member");
    } catch (e) {
      reportError("Failed to remove member: $e");
      return;
    }

    reportSuccess(
        "Removed ${user.getLocalShortName(loc)} from ${widget.groupName}");
  }

  @override
  Widget build(BuildContext context) {
    Locale loc = Localizations.localeOf(context);

    return
        // AlertDialog(
        //   title: const Text('Add members'),
        //   content:
        //  SizedBox(
        //     // constraints: BoxConstraints(maxHeight: 300, maxWidth: 200),
        //     width: min(MediaQuery.sizeOf(context).width - 16, 500),
        //     height: MediaQuery.sizeOf(context).height - 70,
        //     child:

        ActionSubscriptionAggregator(
            child: GroupMembersProvider(
                groupName: widget.groupName,
                builder: (context, members, _) {
                  final memberNames = members.memberships.map((e) => e.entity);

                  Color selectedColor =
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 133, 211, 248)
                          : Colors.blue.withAlpha(100);

                  return WPUsersProvider(builder: (context, userIds, _)
                  => UserProvider.Multiplexed(
                    query: userIds,
                    builder: (context, usersResults) {
                      final users = usersResults.map((e) => e.value).toList();

                    return CenteredPageScroll(slivers: [
                      // Column(children: [
                      //   Expanded(
                      //       child:
                      // return
                      // ListView(children: [
                      //   Text("AAA"),
                      //   Text("BBB"),
                      //   Text("CCC"),
                      // ]);
                      // Text("AAA")
                      // SliverToBoxAdapter(
                      //     child: Padding(
                      //         padding: const EdgeInsets.all(16),
                      //         child: Text(
                      //             "Select members of ${widget.groupName}",
                      //             style: Theme.of(context).textTheme.headlineSmall
                      //             ))),

                      SliverAppBar(
                        title: Text("Select members of ${widget.groupName}"),
                        automaticallyImplyLeading: false,
                        pinned: true,
                      ),
                      SliverList.builder(
                        // shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          // return Text("test");

                          final user = users[index];
                          final bool isMember = user.entityName != null &&
                              memberNames.contains(user.entityName);

                          log.fine("User ${user.id} is member: $isMember");

                          return Card(
                              color: isMember ? selectedColor : null,
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                title: Text(user.longName),
                                subtitle: Text(user.email ?? ""),
                                onTap: isMember
                                    ? () => removeMember(user, loc)
                                    : () => addMember(user, loc),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (MediaQuery.sizeOf(context).width > 500)
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: isMember
                                              ? Colors.grey.withAlpha(70)
                                              : Colors.green,
                                          // weight: isMember
                                          //     ? null
                                          //     : 5.0,
                                        ),
                                        onPressed: isMember
                                            ? null
                                            : () => addMember(user, loc),
                                      ),
                                    if (MediaQuery.sizeOf(context).width > 500)
                                      IconButton(
                                        icon: Icon(Icons.remove,
                                            color: isMember
                                                ? Colors.red
                                                : Colors.grey.withAlpha(70)),
                                        onPressed: isMember
                                            ? () => removeMember(user, loc)
                                            : null,
                                      ),
                                  ],
                                ),
                                // subtitle: Text(user.email),
                                // onTap: () {
                                //   // Navigator.pop(
                                //   //         context);
                                //   router.pop();
                                // },
                              ));
                        },
                      )
                    ]);
                  }));
                }));
    //       ),
    //   actions: [
    //     TextButton(
    //         onPressed: () {
    //           // Navigator.pop(
    //           //         context);
    //           router.pop();
    //           // "delete_confirmed");
    //         },
    //         child: const Text('Done')),
    //     // TextButton(
    //     //     onPressed: () {
    //     //       // Navigator.pop(
    //     //       //         context);
    //     //       router.pop();
    //     //     },
    //     //     child: const Text('Cancel'))
    //   ],
    // );
  }
}
