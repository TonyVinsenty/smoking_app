# SmokingAPP — quit-smoking helper (Flutter, Android + iOS)

Owner is a non-coder: keep explanations non-technical (in Russian), ask only on important decisions or when device testing is needed. Economize tokens ($10 plan): few subagents, cheap models (content → Sonnet low, checks → Haiku). Give a rough context-size estimate each session and say when to start a new one. Commit regularly; repo: https://github.com/TonyVinsenty/smoking_app (public). Independent from sister project MoneyAPP (D:\Projects\Claude\MoneyAPP).

App name: **Zero** (may change later; package name stays `smoking_app`).

## Stack
Flutter (Dart 3.13), local-first: drift (SQLite) for data, flutter_riverpod for state, gen-l10n (ARB) for UI strings, flutter_local_notifications. No backend until phase 3.

## Localization
Russian only for now, but everything is translatable: UI strings in `lib/l10n/app_ru.arb` (never hardcode user-facing text), content in `assets/content/<locale>/` (JSON + markdown articles).

## Product decisions
- Tabs: Главная · Здоровье · Знания · Рейтинг · Настройки.
- Onboarding: what the user smokes (cigarettes / heated sticks / disposable vape / refillable vape liquid — several allowed), consumption per day/week/month, price per unit (pack / pack of sticks / disposable / liquid bottle), quit date (can be in the past). Used for money-saved stats.
- Home: smoke-free timer, level + XP bar, money saved, units not consumed, motivational quote.
- **SOS «Хочу курить»**: floating button on every screen (+ home-screen widget later). Flow: one tap "what's happening" (trigger → craving map) → breathing exercise + quick tips → "справился" (logged, gives XP). Craving map shows personal patterns (time of day / trigger).
- Health: recovery milestones timeline with progress + achievements/badges. Medical disclaimer required.
- Levels: XP = 1/smoke-free hour (cumulative across attempts, never lost) + 10/resisted craving + achievement xp. Owner wants progress to feel tangible, not stingy: 50 levels (level-ups ~daily in week 1, ~monthly after a year), 70 achievements with generous XP (thresholds modelled on a typical user).
- Content voice: «вы», gender-neutral, never shaming.
- New-badge celebration animation for 1–3 live unlocks; retroactive batches just get a snackbar. Owner wants more smoothness/animations overall — phase 2 polish.
- «Я закурил» lives in Настройки only. One confirmation against accidental tap, then kind "no-guilt diary": trigger (stress, alcohol, company, coffee, after meal, boredom, ritual, other) + 3 short optional questions (what happened / what would have helped / what I'll try next time). Ends current attempt; badges stay in attempt history; best record kept. Never shaming.
- Notifications in MVP: rare, only supportive, never annoying.
- Accessibility: dark theme + large-font option.
- Premium subscription (later, near release): all core features free; premium = theme customization, special leaderboard badge, special achievement, extra fun features.
- Visual style: calm, "healthy" (green/teal), light + dark theme.

## Phases
1. MVP offline (current): skeleton → onboarding → home/money/levels → health/achievements → SOS → relapse + triggers + history → knowledge base → notifications → settings (theme, my data, full reset) → device test.
2. Polish: animations, craving-map stats, more articles, icon; content/SOS tips tailored to product type (vape/IQOS); home-screen widget (timer/money) + shareable milestone cards; weekly light challenges (+XP); badge showcase ("shelf"); "what kind of smoker am I" test at onboarding; honest vape/IQOS article series; anonymized user stories.
3. Leaderboard & friends (friend code) on Firebase/Supabase free tier; anonymous opt-in "relays"; "second pilot" (opt-in support contact gets kind notifications); then premium (themes, icon packs, badge frames, premium badge, extended stats/export, share-card templates), store release.
Open question for later: a growing tree / pet as a progress metaphor (owner unsure — discuss).

## Progress (MVP)
Done: skeleton, onboarding, home (timer, savings, level/XP, quote — tap for next), SOS (trigger → breathing → resisted, FAB on all tabs), app name Zero, dynamic calendar timer (years/months/weeks/days + clock + total days), savings ⓘ explanation, larger text app-wide, Settings (theme mode, «Крупный текст», «Полный сброс»), achievement unlocking (HomeShell checks every second; time badges per attempt, others cumulative) + Health tab (recovery timeline, badge grid), onboarding quit time «Не помню» = 10:00, Settings «Цветовой тон» (Системный · Тёмный · Светлый), SOS FAB 75% opaque, timer dividers, savings «Подробнее» sheet (today / calendar week / calendar month / total + forecast; ⓘ «Как считаем» next to piggy icon), SOS rework (3 exercises: calm breathing 4/6 no hold, countdown 10→0, grounding 5-4-3-2-1; picker in SOS + Settings, remembered in prefs; tips in «вы»; button «Тяга прошла!»), «Я закурил(а)» in Settings → «Моя попытка» (confirm → no-guilt diary: time, trigger, 3 questions; relapse also logged as unresisted craving; then «Начать новую попытку сейчас» / «Начну позже») + «История попыток» (record, total, count, per-attempt badges, trigger, diary), per-attempt smoking habits (schema v2: products.attemptId; new attempt asks «Оставить / Изменить» and reuses onboarding product steps via `OnboardingScreen.editProducts`; `productsOf`/`latestProducts` in stats.dart), Knowledge tab (25 articles incl. new category «Помощь и лечение» (therapy), category chips, «Прочитано X из N», article counts as read when scrolled to the end, «Следующая статья», disclaimer). Runs on emulator `Pixel_8` (`flutter emulators --launch Pixel_8`).
Settings «Мои данные» → «Мои привычки» (edit products of current attempt via `db.replaceProducts`, snackbar).
Next: notifications → craving-map stats. Labels use gender-neutral forms («Я закурил(а)», «Тяга прошла!»).
Dev notes: adb at D:/Android/Sdk/platform-tools/adb.exe (screenshots: `adb exec-out screencap -p`); run `flutter gen-l10n` after editing ARB, `dart run build_runner build` after DB changes; no Python on this machine; `kotlin.incremental=false` needed (C:/D: drives).

## Content
`assets/content/ru/`: health_milestones.json, achievements.json, levels.json, quotes.json, sos_tips.json, articles/index.json + *.md. Ideas backlog: docs/content-ideas.md.
