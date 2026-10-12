import 'package:flutter/material.dart';

/// Shows [child] in a box as big as the largest of [candidates] (laid out but invisible),
/// so swapping texts (tips, quotes) does not make the layout around them jump.
class ReserveLargest extends StatelessWidget {
  const ReserveLargest({super.key, required this.candidates, required this.child});

  final List<Widget> candidates;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (final c in candidates) ExcludeSemantics(child: Visibility.maintain(visible: false, child: c)),
      child,
    ],
  );
}
