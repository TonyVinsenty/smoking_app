# SmokingAPP — помощник для отказа от курения (Flutter, Android + iOS)

Видимое название приложения: **Zero** (может поменяться; имя пакета остаётся `smoking_app`). Цель, решения по продукту, что сделано и что дальше — в **`docs/ROADMAP.md`** (читать в начале каждой сессии; обновлять после каждого сделанного пункта). Копилка идей контента — `docs/content-ideas.md`.

## Как работать
- Владелец не программист: объяснять просто, без техники, по-русски; спрашивать только о важных решениях или когда нужен тест на устройстве. Код, идентификаторы и сообщения коммитов — на английском.
- Экономить токены (тариф $10): мало субагентов, дешёвые модели (контент и дизайн-советы → Sonnet low, проверки → Haiku). В каждой сессии давать примерную оценку размера контекста и говорить, когда пора начать новую.
- Регулярно коммитить (каждый пункт — отдельный коммит) и пушить; репозиторий: https://github.com/TonyVinsenty/smoking_app (публичный).
- Проект не зависит от соседнего MoneyAPP (D:\Projects\Claude\MoneyAPP); оттуда можно брать только опыт по выпуску сборок.
- Тон текстов в приложении: на «вы», гендерно-нейтрально, без упрёков. Факты и статистика — только реальные, с источниками.

## Технологии
Flutter (Dart 3.13), всё хранится на телефоне: drift (SQLite) — данные, flutter_riverpod — состояние, gen-l10n (ARB) — строки интерфейса, flutter_local_notifications. Сервера нет до фазы 3.

## Локализация
Пока только русский, но всё переводимо: строки интерфейса в `lib/l10n/app_ru.arb` (никогда не писать текст для пользователя прямо в коде), контент в `assets/content/<locale>/` (JSON + статьи в markdown).

## Контент
`assets/content/ru/`: health_milestones.json, achievements.json, levels.json, quotes.json, sos_tips.json, trigger_tips.json, articles/index.json + *.md. После изменений достижений/уровней — перезапустить симуляцию `dart run tool/xp_simulation.dart --fit`.

## Сборка и выпуск
- Версия 0.1.0; для каждой новой сборки поднимать номер сборки в pubspec (`0.1.0+N`). Владелец ставит новую версию поверх старой, не удаляя (иначе пропадут данные) — напоминать.
- Android: релизный APK подписан своим ключом (D:/Android/keys/zero-release.jks). Переменная ZERO_KEYSTORE_PROPERTIES = `D:\Android\keys\zero-keystore.properties` — в Bash задать вручную через export, без неё сборка падает. Владелец хранит резервную копию D:/Android/keys. Готовый файл: `build/app/outputs/flutter-apk/app-release.apk` → копировать в папку `releases/` (не в git) как `Zero-0.1.0-buildN.apk`.
- iOS: неподписанный .ipa через GitHub Actions «iOS build» (владелец запускает вручную после push) → Sideloadly (тот же Apple ID, что для Zuno). Bundle id `com.tonyvinsenty.smokingApp` — никогда не менять. Подробности: D:/Projects/Claude/MoneyAPP/docs/how-to-iphone.md.

## Заметки для разработки
- Эмулятор: `Pixel_8` (`flutter emulators --launch Pixel_8`). adb: D:/Android/Sdk/platform-tools/adb.exe. Скриншоты: `adb exec-out screencap -p > файл.png` (в Git Bash задать `MSYS_NO_PATHCONV=1`, иначе пути вида /sdcard ломаются).
- Экономия токенов при проверке: искать кнопки и тапать по ним через `adb shell uiautomator dump` (у Flutter-виджетов текст лежит в content-desc, есть координаты bounds), скриншоты — только чтобы оценить вид. Ошибки «налезания» в логах ловятся ненадёжно — смотреть глазами.
- Быстрая проверка: `flutter build apk --debug` + `adb install -r` (`flutter run` в фоне не держится). Отладочная сборка стартует ~10 с — ждать появления элементов, а не делать скриншот сразу.
- Крупный шрифт: `adb shell settings put system font_scale 2.0`, после проверки вернуть `1.0`.
- На эмуляторе стоит ещё Zuno: кнопка «Назад» с главной закрывает Zero, и следующий тап может попасть в другое приложение.
- После правки ARB — `flutter gen-l10n`; после изменений БД — `dart run build_runner build`; форматирование `dart format -l 120`; Python на машине нет; нужен `kotlin.incremental=false` (диски C:/D:).
- Полезные места в коде: таймер/экономия — lib/domain/stats.dart; карта тяги — lib/domain/craving_stats.dart; уведомления — lib/app/notifications.dart; проверка достижений — HomeShell (каждую секунду); барабан времени — lib/app/widgets/wheel_time_picker.dart; переход к достижениям — showAchievementsProvider (lib/features/health/health_screen.dart).
