import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:sib_utrecht_app/components/api_access.dart';
import 'package:sib_utrecht_app/components/people/entity_icon.dart';
import 'package:sib_utrecht_app/components/people/entity_tile.dart';
import 'package:sib_utrecht_app/components/people/user_card.dart';
import 'package:sib_utrecht_app/components/resource_pool.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/model/api_connector.dart';
import 'package:sib_utrecht_app/model/resource_pool.dart';
import 'package:sib_utrecht_app/model/user.dart';
import 'package:sib_utrecht_app/view_model/provider/user_provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class EditUserDetails extends StatefulWidget {
  final User user;

  const EditUserDetails({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserDetails> createState() => _EditUserDetailsState();
}

class _EditUserDetailsState extends State<EditUserDetails> {
  final TextEditingController _longNameController = TextEditingController();
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _shortNameUniqueController =
      TextEditingController();
  final TextEditingController _pronounsController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _legalFirstNameController =
      TextEditingController();
  final TextEditingController _legalLastNameController =
      TextEditingController();

  late Map origDetails;
  late Map newDetails;
  bool isDirty = false;
  bool isEditingProfileEnabled = true;
  bool isEditingAdministrationEnabled = true;

  Future<Map?>? _submission;

  void setToUser() {
    origDetails = getSubmitPayload();
    _longNameController.text = widget.user.longName;
    _shortNameController.text = widget.user.shortName;
    _shortNameUniqueController.text = widget.user.shortNameUnique;
    _pronounsController.text = widget.user.pronouns ?? "";
    _emailController.text = widget.user.email ?? "";
    _legalFirstNameController.text = widget.user.legalFirstName ?? "";
    _legalLastNameController.text = widget.user.legalLastName ?? "";

    updateSubmissionDetails();
  }

  @override
  void initState() {
    super.initState();
    setToUser();

    _longNameController.addListener(onFieldChanged);
    _shortNameController.addListener(onFieldChanged);
    _shortNameUniqueController.addListener(onFieldChanged);
    _pronounsController.addListener(onFieldChanged);
    _emailController.addListener(onFieldChanged);
    _legalFirstNameController.addListener(onFieldChanged);
    _legalLastNameController.addListener(onFieldChanged);
  }

  @override
  void dispose() {
    _longNameController.dispose();
    _shortNameController.dispose();
    _shortNameUniqueController.dispose();
    _pronounsController.dispose();
    _emailController.dispose();
    _legalFirstNameController.dispose();
    _legalLastNameController.dispose();

    super.dispose();
  }

  void onFieldChanged() {
    updateSubmissionDetails();
  }

  @override
  void didUpdateWidget(covariant EditUserDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      log.info("User page: user changed");
      setToUser();
      log.info("User page: user change complete");
    }
  }

  void updateSubmissionDetails() {
    setState(() {
      newDetails = getSubmitPayload();
      isDirty = !const DeepCollectionEquality().equals(origDetails, newDetails);
      if (isDirty) {
        log.info(
            "User details are dirty:\n orig: $origDetails\n new: $newDetails");
      }
    });
  }

  Map getSubmitPayload() {
    Map data = <String, dynamic>{
      "long_name": _longNameController.text,
      "short_name": _shortNameController.text,
      "short_name_unique": _shortNameUniqueController.text,
      "pronouns": _pronounsController.text,
      "email": _emailController.text,
      "legal_name": <String, dynamic>{
        "first_name": _legalFirstNameController.text,
        "last_name": _legalLastNameController.text,
      }
    };

    if (data["legal_name"]["first_name"] == "") {
      data["legal_name"]["first_name"] = null;
    }
    if (data["legal_name"]["last_name"] == "") {
      data["legal_name"]["last_name"] = null;
    }
    return data;
  }

  Future<Map?> submit() async {
    log.info("Submitting user details");
    String? id = widget.user.id;
    if (id == null) {
      throw Exception("User has no id");
    }

    APIConnector connector = await APIAccess.of(context).connector;

    Map payload = getSubmitPayload();
    var response = await connector.put("/users/@$id", body: payload);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    ResourcePoolBase? pool = ResourcePoolAccess.maybeOf(context)?.pool;

    return Column(children: [
      Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _shortNameController,
                  readOnly: !isEditingProfileEnabled,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Short name'))),
          const SizedBox(width: 16),
          Expanded(
              child: TextField(
                  controller: _shortNameUniqueController,
                  readOnly: !isEditingProfileEnabled,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Short name unique'))),
        ],
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
            flex: 3,
            child: TextField(
                controller: _longNameController,
                readOnly: !isEditingProfileEnabled,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Long name'))),
        const SizedBox(width: 16),
        Expanded(
            flex: 2,
            child: TextField(
                controller: _pronounsController,
                readOnly: !isEditingProfileEnabled,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pronouns (optional)'))),
      ]),
      // const SizedBox(height: 32),
      if (isDirty)
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: FilledButton(
                onPressed: () {
                  final fut = submit();
                  setState(() {
                    _submission = fut;
                  });
                  fut.then((value) {
                    if (!mounted) {
                      return;
                    }

                    if (value != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.userDetailsSaved)));
                    }

                    pool?.users.invalidateId(widget.user.id);
                  });
                  fut.catchError((e) {
                    if (!mounted) {
                      throw e;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .userDetailsSaveFailed(e.toString()))));
                    throw e;
                  });
                },
                child: Text(AppLocalizations.of(context)!.save))),
      // Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // child: Container

      // Card(
      //     child: Padding(
      //         padding: const EdgeInsets.all(16),
      //         child:
      const SizedBox(height: 16),
      ExpansionTile(
          title: const Text("Administrational"),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            // Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child:
            //   Column(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            // Text("Administrational",
            //     style: Theme.of(context).textTheme.bodyLarge),
            // const SizedBox(height: 16),
            TextField(
                controller: _emailController,
                readOnly: !isEditingAdministrationEnabled,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email (optional)')),
            const SizedBox(height: 32),
            const Text("The legal first and last name as would be needed for "
                "the administration of the association and for ordering tickets for events."),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _legalFirstNameController,
                        readOnly: !isEditingAdministrationEnabled,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'First name (optional)'))),
                const SizedBox(width: 16),
                Expanded(
                    child: TextField(
                        controller: _legalLastNameController,
                        readOnly: !isEditingAdministrationEnabled,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Last name (optional)'))),
              ],
            ),
            // const SizedBox(height: 16),
          ]),
      // const SizedBox(height: 16),
      // if (isDirty)
      //   FilledButton(
      //       onPressed: () {
      //         final fut = submit();
      //         setState(() {
      //           _submission = fut;
      //         });
      //         fut.then((value) {
      //           if (value != null) {
      //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //                 content: Text(
      //                     AppLocalizations.of(context)!.userDetailsSaved)));
      //           }
      //         });
      //         fut.catchError((e) {
      //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //               content: Text(AppLocalizations.of(context)!
      //                   .userDetailsSaveFailed(e.toString()))));
      //         });
      //       },
      //       child: Text(AppLocalizations.of(context)!.save)),
      // ListTile(
      //     title: TextButton(
      //         onPressed: () {
      //           widget.user.longName = _longNameController.text;
      //           widget.user.shortName = _shortNameController.text;
      //           widget.user.shortNameUnique = _shortNameUniqueController.text;
      //           widget.user.pronouns = _pronounsController.text;
      //           widget.user.email = _emailController.text;
      //           widget.user.legalFirstName = _legalFirstNameController.text;
      //           widget.user.legalLastName = _legalLastNameController.text;
      //           widget.user.save();
      //         },
      //         child: const Text("Save")))
    ]);
  }
}

class UserPageContents extends StatelessWidget {
  final User user;

  final double _appBarMinHeight = 72;
  final double _appBarMaxHeight = 200;

  const UserPageContents({Key? key, required this.user}) : super(key: key);

  Matrix4 getNameHeaderTransform(Animation<double> animation) {
    final scale = Tween<double>(begin: 80, end: 4).evaluate(
        CurvedAnimation(parent: animation, curve: Curves.easeInQuart));

    final rotation = Tween<double>(begin: 0, end: math.pi / 2)
        .evaluate(CurvedAnimation(parent: animation, curve: Curves.easeInCirc));

    Vector3 translationVector = Matrix4.diagonal3(Vector3.all(scale)) *
        Matrix4.rotationZ(rotation).transform3(Vector3(1, 0, 0));

    return Matrix4.translation(translationVector);
  }

  @override
  Widget build(BuildContext context) {
    String? entityName = user.entityName;

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
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child:
                        // Row(children: [],)
                        Center(
                            child: Text(
                      "User details",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
                maxCrossAxisExtent: 700,
                child: SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                    sliver: MultiSliver(children: [
                      SliverToBoxAdapter(
                        child: Card(
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child: Column(children: [
                                  EditUserDetails(user: user),
                                  const SizedBox(height: 32),
                                  ExpansionTile(
                                      title: const Text("Debug information"),
                                      childrenPadding: const EdgeInsets.all(16),
                                      children: [
                                        UserCard(user: user),
                                        Center(child: EntityTile(entity: user)),
                                        Row(children: [
                                          Text(
                                              "Entity name: ${entityName ?? 'null'}"),
                                          const SizedBox(width: 8),
                                          if (entityName != null)
                                            IconButton(
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: entityName));
                                                },
                                                icon: const Icon(Icons.copy,
                                                    size: 16))
                                        ]),
                                      ]),
                                ]))),
                      )
                    ])))),
        SliverStickyHeader(
            header: Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child: Center(
                        child: Text(
                      "Memberships",
                      style: Theme.of(context).textTheme.titleLarge,
                    )))),
            sliver: SliverCrossAxisConstrained(
              maxCrossAxisExtent: 700,
              child: SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 32),
                  sliver: MultiSliver(children: const [
                    SliverToBoxAdapter(
                        child: Card(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                                child:
                                    Center(child: Text("To be implemented")))))
                  ])),
            ))
        //  SliverToBoxAdapter(
        //   child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         // const SizedBox(height: 48),

        //         const SizedBox(height: 8),
        //         ,
        //         const SizedBox(height: 32),
        //         Text(
        //           "Memberships",
        //           style: Theme.of(context).textTheme.headlineSmall,
        //         ),
        //         const SizedBox(height: 8),
        //         const Card(
        //             child: Padding(
        //                 padding:
        //                     EdgeInsets.fromLTRB(8, 16, 8, 16),
        //                 child: Center(child: Text("To be implemented")))),
        //         const SizedBox(height: 32),
        //         const SizedBox(
        //             height: 1000, child: Center(child: Text("Hello")))
        //       ]),
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
