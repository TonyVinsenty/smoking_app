import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Empty space at the end of every scrolling tab, so the last line can scroll clear of the SOS button.
const sosClearance = 96.0;

/// Solid SOS button. It shrinks to a round icon while the user scrolls down and shows «SOS» again on the
/// way up, so it never hides text for long.
class SosFab extends StatelessWidget {
  const SosFab({super.key, required this.extended, required this.label, required this.onPressed});

  final bool extended;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final light = theme.brightness == Brightness.light;
    // Mint in the light theme; bright on dark, where a dark mint would sink into the cards.
    final background = light ? scheme.primaryContainer : scheme.primary;
    final foreground = light ? scheme.onPrimaryContainer : scheme.onPrimary;
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 220);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: background,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: AnimatedSize(
            duration: duration,
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: extended ? 20 : 16, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.air, color: foreground),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a tab body: reports whether the SOS button should be extended, following vertical scrolls.
class SosScrollWatcher extends StatelessWidget {
  const SosScrollWatcher({super.key, required this.onExtended, required this.child});

  final ValueChanged<bool> onExtended;
  final Widget child;

  @override
  Widget build(BuildContext context) => NotificationListener<UserScrollNotification>(
    onNotification: (n) {
      if (n.metrics.axis == Axis.vertical) {
        if (n.direction == ScrollDirection.reverse) onExtended(false);
        if (n.direction == ScrollDirection.forward) onExtended(true);
      }
      return false;
    },
    child: child,
  );
}
