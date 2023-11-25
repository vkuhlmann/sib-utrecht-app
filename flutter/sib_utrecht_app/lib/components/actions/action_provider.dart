
// import 'package:flutter/material.dart';
// import 'package:sib_utrecht_app/log.dart';

// class ActionsController with ChangeNotifier {
//   List<Widget> _widgets = [];

//   List<Widget> get widgets => _widgets;
//   set widgets(List<Widget> value) {
//     if (_widgets == value) {
//       return;
//     }

//     log.info("ActionsController: setting widgets to $value");
    
//     _widgets = value;
//     notifyListeners();
//   }
// }

// class ActionProvider extends InheritedWidget {
//   const ActionProvider({Key? key, required Widget child, required this.controller})
//       : super(key: key, child: child);

//   // final List<(int, String, List<Widget>)> actions;
//   // final ValueSetter<List<Widget>>? _actionsNotifier;
//   final ActionsController controller;

//   static ActionProvider? maybeOf(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<ActionProvider>();
//   }

//   static ActionProvider of(BuildContext context) {
//     final ActionProvider? result = maybeOf(context);
//     assert(result != null, 'No ActionProvider found in context');
//     return result!;
//   }

//   @override
//   bool updateShouldNotify(ActionProvider oldWidget) =>
//       controller != oldWidget.controller;
//       // || actions.widgets != oldWidget.actions.widgets;
// }
