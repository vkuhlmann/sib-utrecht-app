import 'dart:math';

import 'package:flutter/material.dart';

class CenteredPageScroll extends StatelessWidget {
  final List<Widget> slivers;
  final double horizontalPadding;
  final double anchor;
  final Key? center;

  const CenteredPageScroll(
      {Key? key,
      required this.slivers,
      this.horizontalPadding = 18,
      this.anchor = 0.0,
      this.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        //   child: ConstrainedBox(
        //       constraints: const BoxConstraints(maxWidth: 700),
        child: CustomScrollView(
            anchor: anchor,
            center: center,
            slivers: slivers
                .map<Widget>((e) =>
                    // SliverConstrainedCrossAxis(maxExtent: 700, sliver: e)
                    // SliverCrossAxisGroup(slivers: [
                    //   SliverCrossAxisExpanded(flex: 1, sliver: SliverToBoxAdapter(child: Container())),
                    //   SliverConstrainedCrossAxis(maxExtent: 700, sliver: e),
                    //   // e,
                    //   SliverCrossAxisExpanded(flex: 1, sliver: SliverToBoxAdapter(child: Container())),
                    // ])
                    SliverLayoutBuilder(builder: (context, constraints) {
                      // contraints.ma
                      // return SliverPadding(padding: EdgeInsets.fromLTRB(left, top, right, bottom),)
                      double padding = max(
                          (constraints.crossAxisExtent - 700) / 2,
                          horizontalPadding);

                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
                        sliver: e,
                      );
                      // return e;
                    }))
                .toList()));
  }
}
