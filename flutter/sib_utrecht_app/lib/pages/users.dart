import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/view_model/groups_provider.dart';
import 'package:sib_utrecht_app/view_model/wp_users_provider.dart';

class UsersPageContents extends StatelessWidget {
  final List<Map> users;

  const UsersPageContents(
      {Key? key, required this.users})
      : super(key: key);

  // static UsersPageContents fromProvider(UsersProvider provider, {Key? key}) {
  //   return UsersPageContents(
  //     key: key,
  //     groups: provider.groups,
  //     groupsProvider: provider,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: CustomScrollView(slivers: [
      SliverPadding(
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 32),
          sliver: SliverList.list(children: 
            users.map((el) => Card(child: ListTile(
              title: Text(el["display_name"]),
              subtitle: Text(el["user_email"] ?? ""),
              trailing: 
                el["entity_name"] == null ? IconButton(onPressed: () {
                  APIAccess.of(context).users.getOrCreateUser(wpId: el["wp_id"])
                  .then((value) => GoRouter.of(context).pushNamed("user_page", pathParameters: {
                    "entity_name": value
                  }))
                  .onError((error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $error")));
                  });
                }, icon: const Icon(Icons.add))
                :
                IconButton(onPressed: () {
                  GoRouter.of(context).pushNamed("user_page", pathParameters: {
                    "entity_name": el["entity_name"]
                  });
                }, icon: const Icon(Icons.arrow_forward_ios)),
            ))).toList()
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
  // late UsersProvider groupsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // groupsProvider = UsersProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //     appBar: AppBar(title: Text("Users")),
    //     body: UsersPageContents.fromProvider(groupsProvider));
    // var provUsers = ResourcePoolAccess.of(context).pool.groupsProvider;
    // return ListenableBuilder(
    //   listenable: provUsers,
    //   builder: (context, _) => 
    //   // WithSIBAppBar(actions: const [], child: 
    //   Column(children: [
    //     Expanded(child: UsersPageContents.fromProvider(provUsers)),
    //   ]),
    // );

    return WPUsersProvider(builder: (context, provUsers) => 
      // WithSIBAppBar(actions: const [], child: 
      Column(children: [
        Expanded(child: UsersPageContents(users: provUsers)),
      ]
      // ),
    ));
  }
}


