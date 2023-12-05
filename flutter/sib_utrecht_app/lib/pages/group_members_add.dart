import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/globals.dart';
import 'package:sib_utrecht_app/view_model/provider/group_members_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/wp_users_provider.dart';

class GroupMembersAddPage extends StatefulWidget {
  final String groupName;

  const GroupMembersAddPage({Key? key, required this.groupName})
      : super(key: key);

  @override
  State<GroupMembersAddPage> createState() => _GroupMembersAddPageState();
}

class _GroupMembersAddPageState extends State<GroupMembersAddPage> {
  @override
  Widget build(BuildContext context) {
    return
        // AlertDialog(
        //   title: const Text('Add members'),
        //   content:
        //  SizedBox(
        //     // constraints: BoxConstraints(maxHeight: 300, maxWidth: 200),
        //     width: min(MediaQuery.sizeOf(context).width - 16, 500),
        //     height: MediaQuery.sizeOf(context).height - 70,
        //     child:
        GroupMembersProvider(
            groupName: widget.groupName,
            builder: (context, members) {
              final memberNames = members.map((e) => e["entity"]);

              Color selectedColor = Theme.of(context).brightness == Brightness.light ?
                const Color.fromARGB(255, 133, 211, 248)
              : Colors.blue.withAlpha(100);

              return WPUsersProvider(builder: (context, users) {
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
                      final bool isMember = user["entity_name"] != null &&
                          memberNames.contains(user["entity_name"]);

                      return Card(
                          color: isMember ? selectedColor : null,
                          child: ListTile(
                        title: Text(user["display_name"]),
                        subtitle: Text(user["user_email"]),
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
                              onPressed: isMember ? null : () {},
                            ),
                            if (MediaQuery.sizeOf(context).width > 500)
                            IconButton(
                              icon: Icon(Icons.remove,
                                  color: isMember
                                      ? Colors.red
                                      : Colors.grey.withAlpha(70)),
                              onPressed: isMember ? () {} : null,
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
              });
            });
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
