import 'package:flutter_test/flutter_test.dart';
import 'package:smoking_app/app/notifications.dart';

void main() {
  test('quiet hours move notifications to 10:00', () {
    expect(Notifications.daytime(DateTime(2026, 1, 5, 15, 30)), DateTime(2026, 1, 5, 15, 30));
    expect(Notifications.daytime(DateTime(2026, 1, 5, 3)), DateTime(2026, 1, 5, 10));
    expect(Notifications.daytime(DateTime(2026, 1, 5, 22)), DateTime(2026, 1, 6, 10));
    expect(Notifications.daytime(DateTime(2026, 1, 31, 20, 30)), DateTime(2026, 2, 1, 10));
  });
}
