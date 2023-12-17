import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sib_utrecht_app/components/actions/action_subscriber.dart';
import 'package:sib_utrecht_app/components/actions/sib_appbar.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/centered_page_scroll.dart';
import 'package:sib_utrecht_app/components/people/group_card.dart';
import 'package:sib_utrecht_app/components/resource_pool_access.dart';
import 'package:sib_utrecht_app/model/api/users.dart';
import 'package:sib_utrecht_app/model/group.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/groups_provider.dart';
import 'package:sib_utrecht_app/view_model/provider/wp_users_provider.dart';

class UsersPageContents extends StatelessWidget {
  final List<User> users;

  const UsersPageContents({Key? key, required this.users}) : super(key: key);

  // static UsersPageContents fromProvider(UsersProvider provider, {Key? key}) {
  //   return UsersPageContents(
  //     key: key,
  //     groups: provider.groups,
  //     groupsProvider: provider,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    return SelectionArea(
        child: CenteredPageScroll(
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(10, 18, 10, 32),
            sliver: SliverList.list(
                children: users.map((el) {
              final entityName = el.entityName;

              return Card(
                  child: ListTile(
                title: Text(el.longName),
                subtitle: Text(el.data["wp_user"]?["user_email"]),
                trailing: entityName == null
                    ? IconButton(
                        onPressed: () async {
                          final conn = await APIAccess.of(context).connector;

                          late String value;
                          try {
                            value = await Users(conn)
                                .getOrCreateUser(wpId: el.wpId);
                          } catch (error) {
                            messenger.showSnackBar(
                                SnackBar(content: Text("Error: $error")));
                            return;
                          }

                          router.pushNamed("user_page",
                              pathParameters: {"entity_name": value});
                        },
                        icon: const Icon(Icons.add))
                    : IconButton(
                        onPressed: () {
                          GoRouter.of(context).pushNamed("user_page",
                              pathParameters: {"entity_name": entityName});
                        },
                        icon: const Icon(Icons.arrow_forward_ios)),
              ));
            }).toList()))
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

    return ActionSubscriptionAggregator(
        child: WPUsersProvider(
            builder: (context, provUsers, _) =>
                // WithSIBAppBar(actions: const [], child:
                Column(children: [
                  Expanded(child: UsersPageContents(users: provUsers)),
                ]
                    // ),
                    )));
  }
}
