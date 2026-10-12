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

/// «Здоровье»: sections as swipeable tabs along the top.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  static const _tabs = ['stages', 'facts', 'normal', 'body', 'notInhaled', 'diary'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final diaryDue = ref.watch(diaryDueProvider);
    return TabPage(
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final t in _tabs)
                  Tab(
                    child: Badge(
                      isLabelVisible: t == 'diary' && diaryDue,
                      offset: const Offset(10, -4),
                      child: Text(l.healthSub(t)),
                    ),
                  ),
              ],
            ),
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
