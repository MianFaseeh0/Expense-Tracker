import 'package:flutter/widgets.dart';

/// Tracks any number of [TextEditingController]s and disposes all of them
/// automatically, so form screens can't forget to clean one up.
///
/// Usage: call [registerController] once per controller (typically as a
/// field initializer or in `initState`) instead of calling `.dispose()`
/// manually for each one.
mixin DisposableControllersMixin<T extends StatefulWidget> on State<T> {
  final List<TextEditingController> _managedControllers = [];

  TextEditingController registerController([String initialText = '']) {
    final controller = TextEditingController(text: initialText);
    _managedControllers.add(controller);
    return controller;
  }

  @override
  void dispose() {
    for (final controller in _managedControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
