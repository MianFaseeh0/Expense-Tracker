import 'package:flutter/widgets.dart';

/// Gives any [State] a safe, boilerplate-free busy flag.
///
/// Every form screen in this app (sign in, sign up, add expense) used to
/// hand-roll its own `bool _isLoading` plus a `setState` call guarded by a
/// `mounted` check. Mixing this in removes that duplication and the
/// occasional bug of forgetting the `mounted` guard.
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isBusy = false;

  bool get isBusy => _isBusy;

  /// Runs [task], flipping [isBusy] on before and off after — even if
  /// [task] throws. The caller is still responsible for handling/reporting
  /// the error itself; this mixin only owns the loading flag.
  Future<R> withLoading<R>(Future<R> Function() task) async {
    _setBusy(true);
    try {
      return await task();
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    if (!mounted) return;
    setState(() => _isBusy = value);
  }
}
