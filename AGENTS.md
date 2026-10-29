# Project instructions

- Before making changes, read `docs/ROADMAP.md` for current product decisions and `CLAUDE.md` for project-specific technical notes. Update the roadmap when a feature or task changes status.
- Explain work in Russian, in plain language. The owner is not a programmer. Ask only about decisions that materially affect the product or require an on-device check.
- Keep user-facing text in `lib/l10n/app_ru.arb`; regenerate `lib/l10n/app_localizations*.dart` after changing it. Keep app content in `assets/content/<locale>/`.
- Medical facts and statistics must be accurate and sourced. Keep the app's calm, non-judgmental tone and gender-neutral language.
- This Flutter app stores personal quit-attempt data locally. Friends and chats use Firebase; keep `firestore.rules` aligned with every data-model change. Explain when the owner needs to publish updated rules in Firebase Console.
- Keep the Android application id and iOS bundle id unchanged. Increase the build number in `pubspec.yaml` for a distributable build. Install updates over the existing app so its local data is retained.
- Use `dart format -l 120`. Regenerate Drift code with `dart run build_runner build` after database schema changes. See `CLAUDE.md` for build, emulator, and release details.
