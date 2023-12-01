import 'dart:math';

import 'package:flutter/material.dart';

class CenteredPageScroll extends StatelessWidget {
  final List<Widget> slivers;

  const CenteredPageScroll({Key? key, required this.slivers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        //   child: ConstrainedBox(
        //       constraints: const BoxConstraints(maxWidth: 700),
        child: CustomScrollView(
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
                      double padding = max((constraints.crossAxisExtent - 700) / 2, 0);

                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(padding, 0, padding, 0),
                        sliver: e,
                      );
                      // return e;
                    }
                    ))
                .toList()));
  }
}
