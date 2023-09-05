part of 'main.dart';

class NavigationShell extends InheritedWidget {
  const NavigationShell({Key? key, required this.shell, required child})
      : super(key: key, child: child);

  final StatefulNavigationShell shell;

  static NavigationShell? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<NavigationShell>();
  }

  @override
  bool updateShouldNotify(NavigationShell oldWidget) {
    return shell != oldWidget.shell;
  }
}


