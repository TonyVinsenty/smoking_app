# SmokingAPP — quit-smoking helper (Flutter, Android + iOS)

Owner is a non-coder: keep explanations non-technical (in Russian), ask only on important decisions or when device testing is needed. Economize tokens ($10 plan): few subagents, cheap models (content → Sonnet low, checks → Haiku). Give a rough context-size estimate each session and say when to start a new one. Commit regularly; repo: https://github.com/TonyVinsenty/smoking_app (public). Independent from sister project MoneyAPP (D:\Projects\Claude\MoneyAPP).

Working title `smoking_app`, final name TBD (candidates: Выдох, Легко, Дыши, Вдох, Без дыма, Ноль).

## Stack
Flutter (Dart 3.13), local-first: drift (SQLite) for data, flutter_riverpod for state, gen-l10n (ARB) for UI strings, flutter_local_notifications. No backend until phase 3.

## Localization
Russian only for now, but everything is translatable: UI strings in `lib/l10n/app_ru.arb` (never hardcode user-facing text), content in `assets/content/<locale>/` (JSON + markdown articles).

## Product decisions
- Tabs: Главная · Здоровье · Знания · Рейтинг · Настройки.
- Onboarding: what the user smokes (cigarettes / heated sticks / disposable vape / refillable vape liquid — several allowed), consumption per day/week/month, price per unit (pack / pack of sticks / disposable / liquid bottle), quit date (can be in the past). Used for money-saved stats.
- Home: smoke-free timer, level + XP bar, money saved, units not consumed, motivational quote, big **SOS «Хочу курить»** button (breathing exercise + quick tips; resisted craving is logged and gives XP).
- Health: recovery milestones timeline with progress + achievements/badges. Medical disclaimer required.
- Levels: XP = 1/smoke-free hour (cumulative across attempts, never lost) + 10/resisted craving + achievement xp.
- «Я закурил» lives in Настройки only. Ends current attempt; asks for trigger (stress, alcohol, company, coffee, after meal, boredom, ritual, other + note). Badges stay in attempt history; best record kept. Trigger stats shown later.
- Notifications in MVP (milestone reached, etc.).
- Premium subscription (later, near release): all core features free; premium = theme customization, special leaderboard badge, special achievement, extra fun features.
- Visual style: calm, "healthy" (green/teal), light + dark theme.

## Phases
1. MVP offline (current): skeleton → onboarding → home/money/levels → health/achievements → SOS → relapse + triggers + history → knowledge base → notifications → settings (theme, my data, full reset) → device test.
2. Polish: animations, trigger stats, more articles, name + icon.
3. Leaderboard & friends (friend code) on Firebase/Supabase free tier; then premium, store release.

## Content
`assets/content/ru/`: health_milestones.json, achievements.json, levels.json, quotes.json, sos_tips.json, articles/index.json + *.md. Ideas backlog: docs/content-ideas.md.
