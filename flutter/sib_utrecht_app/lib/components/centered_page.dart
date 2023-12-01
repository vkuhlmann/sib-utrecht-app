import 'package:flutter/material.dart';

class CenteredPage extends StatelessWidget {
  final Widget child;
  
  const CenteredPage({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: child,
      ),
    );
  }
}
