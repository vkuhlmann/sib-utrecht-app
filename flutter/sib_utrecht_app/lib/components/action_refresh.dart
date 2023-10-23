import 'dart:async';
import 'dart:convert';
// import 'dart:math';
import "package:collection/collection.dart";
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sib_utrecht_app/components/sib_appbar.dart';
import 'package:sib_utrecht_app/view_model/events_calendar_list.dart';

import '../globals.dart';
import '../model/api_connector.dart';
import '../components/api_access.dart';
import '../model/event.dart';
import '../view_model/annotated_event.dart';
import '../view_model/cached_provider.dart';
import '../view_model/event_participation.dart';
import '../view_model/async_patch.dart';
import '../view_model/event_placement.dart';
import '../components/event_group.dart';
import '../components/alerts_panel.dart';

// Contains code from https://www.kindacode.com/article/flutter-spinning-animation/

class ActionRefreshButton extends StatefulWidget {
  final Future<DateTime>? refreshFuture;
  final void Function() triggerRefresh;

  const ActionRefreshButton(
      {super.key, required this.refreshFuture, required this.triggerRefresh});

  @override
  State<StatefulWidget> createState() => _ActionRefreshButtonState();
}

class ActionRefreshButtonWithState extends StatefulWidget {
  final AsyncSnapshot<void> snapshot;
  final bool isResultNew;
  final void Function() triggerRefresh;

  const ActionRefreshButtonWithState(
      {super.key,
      required this.snapshot,
      required this.isResultNew,
      required this.triggerRefresh});

  @override
  State<StatefulWidget> createState() => _ActionRefreshButtonWithState();
}

class _ActionRefreshButtonWithState extends State<ActionRefreshButtonWithState>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat();

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void didUpdateWidget(covariant ActionRefreshButtonWithState oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.snapshot.connectionState != ConnectionState.waiting) {
      if (_controller.isAnimating) {
        _controller.duration = const Duration(milliseconds: 300);
        _controller.forward();
      }
    }

    if (widget.snapshot.connectionState == ConnectionState.waiting) {
      _controller.duration = const Duration(seconds: 2);
      _controller.repeat();
    }

    // var fut = widget.refreshFuture;

    // if (fut != )
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Center(child: RotationTransition(
          turns: _animation,
          child: const Icon(Icons.refresh, size: 24)));

    // if (widget.snapshot.connectionState == ConnectionState.waiting) {
    //   icon 
    // }

    // if (widget.snapshot.hasError) {
    //   icon = Stack(children: [
    //     icon,
    //     const Positioned(
    //         top: 0,
    //         right: 0,
    //         // child: Icon(Icons.close, color: Colors.red, size: 20, weight: 64)
    //         child: Icon(Icons.error, color: Colors.red, size: 16)
    //         )
    //   ]);
    // }
    if (widget.snapshot.hasError) {
      icon = 
      OverflowBox(
        maxWidth: 38,
        maxHeight: 38,
        child: Stack(children: [
        icon,
        // const Positioned(
        //     top: 0,
        //     right: 1,
        //     // child: Icon(Icons.close, color: Colors.red, size: 20, weight: 64)
        //     child: Icon(Icons.error, color: Colors.red, size: 14)
        //     )
        const Positioned(
              bottom: 4,
              left: 4,
              // child: Icon(Icons.close, color: Colors.red, size: 20, weight: 64)
              // child: Icon(Icons.check, color: Colors.green, size: 18)
              // child: Icon(Icons.check_circle, color: Colors.green, size: 18)
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 8,
                child: Icon(Icons.close, color: Colors.white, size: 12)
              )
              )
      ]));
    }

    if (widget.snapshot.connectionState == ConnectionState.done
    && !widget.snapshot.hasError) {
      if (widget.isResultNew) {
        icon = OverflowBox(
        maxWidth: 38,
        maxHeight: 38,
        child: Stack(children: [
          icon,
          const Positioned(
              bottom: 4,
              left: 4,
              // child: Icon(Icons.close, color: Colors.red, size: 20, weight: 64)
              // child: Icon(Icons.check, color: Colors.green, size: 18)
              // child: Icon(Icons.check_circle, color: Colors.green, size: 18)
              child: CircleAvatar(
                backgroundColor: Colors.green,
                radius: 8,
                child: Icon(Icons.check, color: Colors.white, size: 12)
              )
              )
        ]));
      }
    }

    return IconButton(onPressed: () {
      widget.triggerRefresh();
    }, icon: SizedBox(height: 24, width: 24, child: icon));
    

    // return IconButton(
    //     onPressed: () {
    //       // alertsPanelController.dismissedMessages.clear();
    //       // calendar.refresh();
    //       widget.triggerRefresh();
    //     },
    //     icon: const Icon(Icons.refresh));
  }
}

class _ActionRefreshButtonState extends State<ActionRefreshButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilderPatched(
        future: widget.refreshFuture, 
        builder: (context, snapshot) =>
        FutureBuilderPatched(future: 
        widget.refreshFuture?.whenComplete(() => Future.delayed(const Duration(seconds: 10))),
        builder: (delayContext, delaySnapshot) => 
        ActionRefreshButtonWithState(
            snapshot: snapshot,
            isResultNew: delaySnapshot.connectionState == ConnectionState.waiting,
            triggerRefresh: widget.triggerRefresh)));
  }
}
