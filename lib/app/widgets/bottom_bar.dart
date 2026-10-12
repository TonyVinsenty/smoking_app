import 'package:flutter/material.dart';

/// One tab of [EvenBottomBar].
class BarItem {
  const BarItem({required this.icon, required this.selectedIcon, required this.label, this.dot = false});

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// A small red dot on the icon: something here waits for the user.
  final bool dot;
}

/// Looks like the Material 3 NavigationBar, but spreads the tabs with equal gaps between them and the
/// screen edges. NavigationBar gives every tab the same width, so a short first label («Главная») sits
/// visibly farther from its edge than a long last one («Настройки»).
class EvenBottomBar extends StatelessWidget {
  const EvenBottomBar({super.key, required this.items, required this.selectedIndex, required this.onSelected});

  final List<BarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final (i, item) in items.indexed)
                _BarButton(item: item, selected: i == selectedIndex, onTap: () => onSelected(i)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  const _BarButton({required this.item, required this.selected, required this.onTap});

  final BarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The pill may stick out past a short label: the gaps are measured between labels.
              SizedBox(
                width: 24,
                height: 32,
                child: OverflowBox(
                  maxWidth: 64,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 32,
                    decoration: BoxDecoration(
                      color: selected ? scheme.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Badge(
                      isLabelVisible: item.dot,
                      child: Icon(
                        selected ? item.selectedIcon : item.icon,
                        color: selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
