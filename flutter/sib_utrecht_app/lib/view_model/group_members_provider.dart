import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector_cacher.dart';
import 'package:sib_utrecht_app/model/groups.dart';
// import 'package:sib_utrecht_app/model/event.dart';
// import 'package:sib_utrecht_app/model/events.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/model/users.dart';
import 'package:sib_utrecht_app/utils.dart';
import 'package:sib_utrecht_app/view_model/async_patch.dart';
import 'package:sib_utrecht_app/view_model/cached_provider.dart';

// import '../constants.dart';

class GroupMembersProvider extends StatefulWidget {
  final String groupName;
  final Widget Function(BuildContext context, List<Map> members) builder;

  const GroupMembersProvider(
      {Key? key, required this.groupName, required this.builder})
      : super(key: key);

  @override
  State<GroupMembersProvider> createState() => _GroupMembersProviderState();
}

class _GroupMembersProviderState extends State<GroupMembersProvider> {
  Future<CacherApiConnector>? apiConnector;
  late CachedProvider<List<Map>> members;

  @override
  void initState() {
    super.initState();

    initMembers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // var conn = apiConnector;
    // setState(() {
    var conn = APIAccess.of(context).connector;
    apiConnector = conn;
    log.info('[GroupMembersProvider] didChangeDependencies, conn: $conn');
    // });

    // if (conn != null) {
    setState(() {
      members.setConnector(conn);
    });

    // for (var element in users) {
    //   element.setConnector(conn);
    // }
    // }
  }

  @override
  void didUpdateWidget(GroupMembersProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // var conn = apiConnector;

    // if (conn != null) {
    //   // for (var element in users) {
    //   //   element.setConnector(conn);
    //   // }
    // }
    initMembers();
  }

  void initMembers() {
    setState(() {
      // apiConnector = ResourcePoolAccess.of(context).pool.connector;
      members = CachedProvider<List<Map>>(
        obtain: (c) => Groups(c).listMembers(groupName: widget.groupName),
      );

      var conn = apiConnector;
      if (conn != null) {
        members.setConnector(conn);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // log.info('[GroupMembersProvider] build, conn: ${APIAccess.of(context).connector}');
    return ListenableBuilder(
      listenable: members,
      builder: (context, _) => FutureBuilderPatched(
          future: members.loading,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return formatError(snapshot.error);
            }

            var cached = members.cached;
            if (cached == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return const Center(child: Text('No data'));
            }

            return widget.builder(context, cached);
          }),
    );
  }
}
