import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Section buttons in rows of three, synced with the surrounding [DefaultTabController].
class _SectionPicker extends StatelessWidget {
  const _SectionPicker({required this.tabs, required this.dotOn});

  final List<String> tabs;

  /// Section with a red dot (something waits there), if any.
  final String? dotOn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        // Follows the swipe: the next button lights up halfway through.
        final current = controller.animation!.value.round();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            spacing: 8,
            children: [
              for (var row = 0; row < tabs.length; row += 3)
                Row(
                  spacing: 8,
                  children: [
                    for (var i = row; i < row + 3 && i < tabs.length; i++)
                      Expanded(
                        child: Badge(
                          isLabelVisible: tabs[i] == dotOn,
                          offset: const Offset(-4, 2),
                          child: Material(
                            color: i == current ? scheme.primaryContainer : scheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => controller.animateTo(i),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      l.healthSub(tabs[i]),
                                      maxLines: 1,
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        color: i == current ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
                                        fontWeight: i == current ? FontWeight.bold : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
