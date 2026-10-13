import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/choice.dart';
import '../../app/widgets/tab_page.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'body_map_tab.dart';
import 'diary_tab.dart';
import 'facts_tab.dart';
import 'milestones_tab.dart';
import 'normal_tab.dart';
import 'not_inhaled_tab.dart';

/// «Здоровье»: sections as swipeable tabs; all section buttons stay visible in two rows on top.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  static const _tabs = ['stages', 'facts', 'normal', 'body', 'notInhaled', 'diary'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TabPage(
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            _SectionPicker(tabs: _tabs, dotOn: ref.watch(diaryDueProvider) ? 'diary' : null),
            const Expanded(
              child: TabBarView(
                children: [MilestonesTab(), FactsTab(), NormalTab(), BodyMapTab(), NotInhaledTab(), DiaryTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section menu: one plate with an icon and a name per section, rows of three (fewer with a large system
/// font, so names never break inside a word). Synced with the surrounding [DefaultTabController].
class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.tabs, required this.dotOn});

  final List<String> tabs;

  /// Section with a red dot (something waits there), if any.
  final String? dotOn;

  static (IconData, IconData) _icons(String tab) => switch (tab) {
    'stages' => (Icons.route_outlined, Icons.route),
    'facts' => (Icons.fact_check_outlined, Icons.fact_check),
    'normal' => (Icons.eco_outlined, Icons.eco),
    'body' => (Icons.favorite_border, Icons.favorite),
    'notInhaled' => (Icons.smoke_free, Icons.smoke_free),
    _ => (Icons.edit_calendar_outlined, Icons.edit_calendar),
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final controller = DefaultTabController.of(context);
    final labelStyle = theme.textTheme.labelMedium?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w700);
    final iconSize = MediaQuery.textScalerOf(context).scale(22).clamp(22.0, 32.0);
    // The menu stays compact with a large system font: text grows up to 1.5×.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.light ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: LayoutBuilder(
              builder: (context, box) {
                final labels = [for (final t in tabs) l.healthSub(t)];
                // Three per row, or fewer when a word would not fit (8 dp padding on each side of a label).
                var perRow = 3;
                while (perRow > 1 &&
                    !wordsFit(context, labels, labelStyle, (box.maxWidth - 4 * (perRow - 1)) / perRow - 16)) {
                  perRow--;
                }
                return AnimatedBuilder(
                  animation: controller.animation!,
                  builder: (context, _) {
                    // Follows the swipe: the next button lights up halfway through.
                    final current = controller.animation!.value.round();
                    Widget item(int i) {
                      final on = i == current;
                      final (off, filled) = _icons(tabs[i]);
                      final color = on ? scheme.onPrimary : scheme.onSurfaceVariant;
                      return Semantics(
                        selected: on,
                        button: true,
                        child: Material(
                          color: on ? scheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => controller.index =
                                i, // jump straight there: animateTo would scroll through the tabs in between
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 2,
                                children: [
                                  Badge(
                                    isLabelVisible: tabs[i] == dotOn,
                                    child: Icon(on ? filled : off, size: iconSize, color: color),
                                  ),
                                  Text(
                                    labels[i],
                                    textAlign: TextAlign.center,
                                    style: labelStyle?.copyWith(
                                      color: color,
                                      fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      spacing: 4,
                      children: [
                        for (var row = 0; row < tabs.length; row += perRow)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: 4,
                              children: [
                                for (var i = row; i < row + perRow; i++)
                                  Expanded(child: i < tabs.length ? item(i) : const SizedBox()),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
