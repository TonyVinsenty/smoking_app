import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smoking_app/main.dart';

void main() {
  testWidgets('app starts with bottom navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmokingApp()));
    await tester.pumpAndSettle();
    expect(find.text('Главная'), findsWidgets);
    expect(find.text('Настройки'), findsOneWidget);
  });
}
