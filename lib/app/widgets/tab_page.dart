import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A bottom-bar tab without a title bar (owner feedback): keeps the body clear of the status bar
/// and colors the status bar icons for the current theme, as an AppBar would.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(body: SafeArea(bottom: false, child: body)),
    );
  }
}
