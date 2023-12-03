import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract interface class ActionEmission {
  Future<DateTime>? get refreshFuture;
  void triggerRefresh();
}

class ActionEmitter extends StatefulWidget {
  final Widget child;
  final Future<DateTime>? refreshFuture;
  final void Function() triggerRefresh;

  const ActionEmitter(
      {Key? key,
      required this.child,
      required this.refreshFuture,
      required this.triggerRefresh})
      : super(key: key);

  @override
  State<ActionEmitter> createState() => _ActionEmitterState();
}

class _ActionEmitterState extends State<ActionEmitter>
    implements ActionEmission {
  @override
  Future<DateTime>? get refreshFuture => widget.refreshFuture;
  @override
  void triggerRefresh() => widget.triggerRefresh();

  ActionSubscriber? subscriber;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    subscriber?.removeSubscription(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    ActionSubscriber? newSubscriber = ActionSubscriber.of(context);
    if (newSubscriber != subscriber) {
      subscriber?.removeSubscription(this);
      subscriber = newSubscriber;
      subscriber?.addSubscription(this);
    }
  }

  @override
  void didUpdateWidget(ActionEmitter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshFuture != widget.refreshFuture) {
      subscriber?.removeSubscription(this);
      subscriber?.addSubscription(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// class ActionSubscription {
//   Future<DateTime>? refreshFuture;
//   void Function() triggerRefresh;

//   ActionSubscription(
//       {required this.refreshFuture, required this.triggerRefresh});
// }

// class ActionProvider extends StatefulWidget {
//   final Widget child;

//   const ActionProvider({Key? key, required this.child}) : super(key: key);

//   @override
//   State<ActionProvider> createState() => _ActionProviderState();
// }

// class _ActionProviderState extends State<ActionProvider> {
//   List<ActionEmission> subscriptions = [];

//   void addSubscription(ActionSubscription subscription) {
//     setState(() {
//       subscriptions.add(subscription);
//     });
//   }

//   void removeSubscription(ActionSubscription subscription) {
//     setState(() {
//       subscriptions.remove(subscription);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ActionSubscriber(
//       addSubscription: addSubscription,
//       removeSubscription: removeSubscription,
//       child: widget.child,
//     );
//   }
// }

class ActionSubscriber extends InheritedWidget {
  final Function(ActionEmission) addSubscription;
  final Function(ActionEmission) removeSubscription;

  const ActionSubscriber(
      {Key? key,
      required this.addSubscription,
      required this.removeSubscription,
      required Widget child})
      : super(key: key, child: child);

  static ActionSubscriber? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ActionSubscriber>();
  }

  @override
  bool updateShouldNotify(ActionSubscriber oldWidget) {
    return false;
  }
}

class ActionSubscriptionBuilder extends StatefulWidget {
  final Widget Function(BuildContext, List<ActionEmission>) builder;

  const ActionSubscriptionBuilder({Key? key, required this.builder})
      : super(key: key);

  @override
  State<ActionSubscriptionBuilder> createState() =>
      _ActionSubscriptionBuilderState();
}

class _ActionSubscriptionBuilderState extends State<ActionSubscriptionBuilder> {
  List<ActionEmission> subscriptions = [];

  void addSubscription(ActionEmission subscription) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        subscriptions.add(subscription);
      });
    });
  }

  void removeSubscription(ActionEmission subscription) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {
        subscriptions.remove(subscription);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ActionSubscriber(
      addSubscription: addSubscription,
      removeSubscription: removeSubscription,
      child: widget.builder(context, subscriptions),
    );
  }
}

// class ActionSubscriptionCollector extends StatefulWidget {
//   final Widget child;

//   const ActionSubscriptionCollector({Key? key, required this.child}) : super(key: key);

//   @override
//   State<ActionSubscriptionCollector> createState() => _ActionSubscriptionCollectorState();
// }

// class _ActionSubscriptionCollectorState extends State<ActionSubscriptionCollector> {
//   List<ActionEmission> subscriptions = [];

//   void addSubscription(ActionEmission subscription) {
//     setState(() {
//       subscriptions.add(subscription);
//     });
//   }

//   void removeSubscription(ActionEmission subscription) {
//     setState(() {
//       subscriptions.remove(subscription);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return
//      ActionSubscriber(
//       addSubscription: addSubscription,
//       removeSubscription: removeSubscription,
//       child: 
//       ActionSubscriptions(
//         subscriptions: subscriptions,
//         child: widget.child,
//       ),
//     );
//   }
// }

// class ActionSubscriptions extends InheritedWidget {
//   final List<ActionEmission> subscriptions;

//   const ActionSubscriptions({Key? key, required this.subscriptions, required Widget child})
//       : super(key: key, child: child);

//   static ActionSubscriptions? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<ActionSubscriptions>();
//   }

//   @override
//   bool updateShouldNotify(ActionSubscriptions oldWidget) {
//     return subscriptions != oldWidget.subscriptions;
//   }
// }

