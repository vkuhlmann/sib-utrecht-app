import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sib_utrecht_app/log.dart';
import 'package:sib_utrecht_app/utils.dart';
import '../../view_model/async_patch.dart';

// Contains code from https://www.kindacode.com/article/flutter-spinning-animation/

class ActionRefreshButton extends StatefulWidget {
  final Future<DateTime>? refreshFuture;
  final void Function(DateTime) triggerRefresh;

  const ActionRefreshButton(
      {super.key, required this.refreshFuture, required this.triggerRefresh});

  @override
  State<StatefulWidget> createState() => _ActionRefreshButtonState();
}

class ActionRefreshButtonWithState extends StatefulWidget {
  final AsyncSnapshot<void> snapshot;
  final bool isResultNew;
  final void Function(DateTime) triggerRefresh;

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

  void updateAnimation() {
    if (widget.snapshot.connectionState == ConnectionState.waiting) {
      _controller.duration = const Duration(seconds: 2);
      _controller.repeat();
      return;
    }

    if (!widget.isResultNew) {
      _controller.reset();
      return;
    }

    if (_controller.isAnimating) {
      // Duration prevDur = _controller.duration!;

      // (1 - _controller.value) * newDurationMs = 500
      // newDurationMs = 500 / (1 - _controller.value)

      // double speedUp = max(1, ((1 - _controller.value) * 500) / prevDur.inMilliseconds);

      _controller.duration = const Duration(
          // milliseconds: (500 / max(0.1, 1 - _controller.value)).floor(),);
          milliseconds: 1000);
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ActionRefreshButtonWithState oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateAnimation();
    // var fut = widget.refreshFuture;

    // if (fut != )
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = Center(
        child: RotationTransition(
            turns: _animation, child: const Icon(Icons.refresh, size: 24)));

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
      log.warning(
          "Error in ActionRefreshButtonWithState: ${widget.snapshot.error}");

      icon = Tooltip(
          message: formatErrorMsg(widget.snapshot.error?.toString()),
          triggerMode: TooltipTriggerMode.longPress,
          child: OverflowBox(
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
                        child:
                            Icon(Icons.close, color: Colors.white, size: 12)))
              ])));
    }

    if (widget.snapshot.connectionState == ConnectionState.done &&
        !widget.snapshot.hasError) {
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
                      child: Icon(Icons.check, color: Colors.white, size: 12)))
            ]));
      }
    }

    return IconButton(
        onPressed: () {
          widget.triggerRefresh(DateTime.now());
        },
        icon: SizedBox(height: 24, width: 24, child: icon));
  }
}

class _ActionRefreshButtonState extends State<ActionRefreshButton>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FutureBuilderPatched(
        future: widget.refreshFuture,
        builder: (context, snapshot) => FutureBuilderPatched(
            future: widget.refreshFuture?.then((value) {
              // if (value.isAfter(DateTime.now().subtract(const Duration(seconds: 30)))) {
              //   return Future.delayed(const Duration(seconds: 10));
              // }

              DateTime noveltyExpiration =
                  value.add(const Duration(seconds: 10));
              log.info("Novelty expiration: $noveltyExpiration");

              DateTime now = DateTime.now();
              if (noveltyExpiration.isAfter(now)) {
                return Future.delayed(noveltyExpiration.difference(now));
              }

              // return false;
              return Future.value();
              // return Future.delayed([
              //   Duration.zero, noveltyExpiration.difference(DateTime.now())
              // ].max);
            }).catchError((error, stackTrace) {
              return Future.delayed(const Duration(seconds: 10));
              // return true;
            }),
            // whenComplete(() => Future.delayed(const Duration(seconds: 10))),
            builder: (delayContext, delaySnapshot) =>
                ActionRefreshButtonWithState(
                    snapshot: snapshot,
                    isResultNew: delaySnapshot.connectionState ==
                        ConnectionState.waiting,
                    triggerRefresh: widget.triggerRefresh)));
  }
}
