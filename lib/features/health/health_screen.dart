import 'package:flutter/material.dart';

import '../../app/widgets/tab_page.dart';
import '../../l10n/app_localizations.dart';
import 'body_map_tab.dart';
import 'facts_tab.dart';
import 'milestones_tab.dart';
import 'normal_tab.dart';
import 'not_inhaled_tab.dart';

/// «Здоровье»: sections as swipeable tabs along the top.
class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  static const _tabs = ['stages', 'facts', 'normal', 'body', 'notInhaled'];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TabPage(
      body: DefaultTabController(
        length: _tabs.length,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [for (final t in _tabs) Tab(text: l.healthSub(t))],
            ),
            const Expanded(
              child: TabBarView(children: [MilestonesTab(), FactsTab(), NormalTab(), BodyMapTab(), NotInhaledTab()]),
            ),
          ],
        ),
      ),
    );
  }
}
