import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smoking_app/data/database.dart';
import 'package:smoking_app/data/providers.dart';
import 'package:smoking_app/main.dart';

void main() {
  testWidgets('first launch shows onboarding', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const SmokingApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Начнём'), findsOneWidget);

    // Let drift close its query streams before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
