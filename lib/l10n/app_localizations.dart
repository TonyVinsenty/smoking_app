import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Zero'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get tabHome;

  /// No description provided for @tabHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get tabHealth;

  /// No description provided for @tabKnowledge.
  ///
  /// In ru, this message translates to:
  /// **'Знания'**
  String get tabKnowledge;

  /// No description provided for @tabLeaderboard.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get tabLeaderboard;

  /// No description provided for @tabSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get tabSettings;

  /// No description provided for @leaderboardText.
  ///
  /// In ru, this message translates to:
  /// **'Добавляйте друзей по коду и поддерживайте друг друга. Всё анонимно и только по желанию.'**
  String get leaderboardText;

  /// No description provided for @next.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next;

  /// No description provided for @back.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Это начало свободы'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeText.
  ///
  /// In ru, this message translates to:
  /// **'Я помогу пройти путь без сигарет маленькими шагами: покажу, как восстанавливается организм, сколько денег остаётся в кармане, и поддержу, когда будет тяжело.\n\nСначала пара вопросов — это займёт минуту.'**
  String get onbWelcomeText;

  /// No description provided for @onbStart.
  ///
  /// In ru, this message translates to:
  /// **'Начнём'**
  String get onbStart;

  /// No description provided for @onbProductsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что вы курите?'**
  String get onbProductsTitle;

  /// No description provided for @onbProductsHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать несколько'**
  String get onbProductsHint;

  /// No description provided for @productName.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{Сигареты} sticks{Стики (IQOS, glo и др.)} disposable{Одноразовые вейпы} liquid{Вейп} other{}}'**
  String productName(String type);

  /// No description provided for @productUnits.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{Сколько сигарет} sticks{Сколько стиков} disposable{Сколько одноразок} liquid{Сколько флаконов жидкости} other{}}'**
  String productUnits(String type);

  /// No description provided for @productPackPrice.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{Цена пачки, ₽} sticks{Цена пачки стиков, ₽} disposable{Цена одноразки, ₽} liquid{Цена флакона жидкости, ₽} other{}}'**
  String productPackPrice(String type);

  /// No description provided for @productUnitsPerPack.
  ///
  /// In ru, this message translates to:
  /// **'В пачке, шт.'**
  String get productUnitsPerPack;

  /// No description provided for @periodName.
  ///
  /// In ru, this message translates to:
  /// **'{period, select, day{в день} week{в неделю} month{в месяц} other{}}'**
  String periodName(String period);

  /// No description provided for @onbConsumptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько и почём'**
  String get onbConsumptionTitle;

  /// No description provided for @onbConsumptionHint.
  ///
  /// In ru, this message translates to:
  /// **'Это нужно, чтобы считать сэкономленные деньги. Примерно — тоже хорошо.'**
  String get onbConsumptionHint;

  /// No description provided for @onbQuitTitle.
  ///
  /// In ru, this message translates to:
  /// **'Когда вы бросили?'**
  String get onbQuitTitle;

  /// No description provided for @onbQuitNow.
  ///
  /// In ru, this message translates to:
  /// **'Прямо сейчас'**
  String get onbQuitNow;

  /// No description provided for @onbQuitEarlier.
  ///
  /// In ru, this message translates to:
  /// **'Раньше — укажу дату'**
  String get onbQuitEarlier;

  /// No description provided for @onbQuitChosen.
  ///
  /// In ru, this message translates to:
  /// **'Бросил(а): {date}'**
  String onbQuitChosen(String date);

  /// No description provided for @onbQuitTimeHelp.
  ///
  /// In ru, this message translates to:
  /// **'Во сколько примерно?'**
  String get onbQuitTimeHelp;

  /// No description provided for @onbQuitTimeUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Не помню'**
  String get onbQuitTimeUnknown;

  /// No description provided for @onbFinish.
  ///
  /// In ru, this message translates to:
  /// **'Поехали!'**
  String get onbFinish;

  /// No description provided for @invalidNumber.
  ///
  /// In ru, this message translates to:
  /// **'Введите число больше нуля'**
  String get invalidNumber;

  /// No description provided for @homeDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{день} few{дня} many{дней} other{дня}}'**
  String homeDays(int count);

  /// No description provided for @unitYears.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{год} few{года} many{лет} other{года}}'**
  String unitYears(int count);

  /// No description provided for @unitMonths.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{месяц} few{месяца} many{месяцев} other{месяца}}'**
  String unitMonths(int count);

  /// No description provided for @unitWeeks.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{неделя} few{недели} many{недель} other{недели}}'**
  String unitWeeks(int count);

  /// No description provided for @homeTotal.
  ///
  /// In ru, this message translates to:
  /// **'всего {value}'**
  String homeTotal(String value);

  /// No description provided for @homeSavingsInfoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как считаем'**
  String get homeSavingsInfoTitle;

  /// No description provided for @homeSavingsInfo.
  ///
  /// In ru, this message translates to:
  /// **'По вашим ответам вы тратили примерно {perDay} ₽ в день — это около {perHour} ₽ в час. Каждая минута без курения добавляет деньги в копилку.'**
  String homeSavingsInfo(String perDay, String perHour);

  /// No description provided for @homeSmokeFreeSince.
  ///
  /// In ru, this message translates to:
  /// **'без курения с {date}'**
  String homeSmokeFreeSince(String date);

  /// No description provided for @homeLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level} · {xp} XP'**
  String homeLevel(int level, String xp);

  /// No description provided for @homeAchievementsCount.
  ///
  /// In ru, this message translates to:
  /// **'Достижения · {count}'**
  String homeAchievementsCount(int count);

  /// No description provided for @homeNextMilestone.
  ///
  /// In ru, this message translates to:
  /// **'До этапа «{title}»'**
  String homeNextMilestone(String title);

  /// No description provided for @homeXpToNext.
  ///
  /// In ru, this message translates to:
  /// **'{xp} XP до следующего уровня'**
  String homeXpToNext(int xp);

  /// No description provided for @homeMaxLevel.
  ///
  /// In ru, this message translates to:
  /// **'Максимальный уровень — вы легенда!'**
  String get homeMaxLevel;

  /// No description provided for @homeMoneySaved.
  ///
  /// In ru, this message translates to:
  /// **'Сэкономлено'**
  String get homeMoneySaved;

  /// No description provided for @homeSavingsMore.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get homeSavingsMore;

  /// No description provided for @savingsToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get savingsToday;

  /// No description provided for @savingsWeek.
  ///
  /// In ru, this message translates to:
  /// **'На этой неделе'**
  String get savingsWeek;

  /// No description provided for @savingsMonth.
  ///
  /// In ru, this message translates to:
  /// **'В этом месяце'**
  String get savingsMonth;

  /// No description provided for @savingsTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего'**
  String get savingsTotal;

  /// No description provided for @savingsPeriodsHint.
  ///
  /// In ru, this message translates to:
  /// **'Неделя считается с понедельника, месяц — с 1-го числа.'**
  String get savingsPeriodsHint;

  /// No description provided for @savingsForecast.
  ///
  /// In ru, this message translates to:
  /// **'Если так продолжать — около {perMonth} в месяц и {perYear} в год.'**
  String savingsForecast(String perMonth, String perYear);

  /// No description provided for @homeNotSmoked.
  ///
  /// In ru, this message translates to:
  /// **'Не выкурено'**
  String get homeNotSmoked;

  /// No description provided for @money.
  ///
  /// In ru, this message translates to:
  /// **'{amount} ₽'**
  String money(String amount);

  /// No description provided for @unitsDisposableShort.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{count} одноразка} few{{count} одноразки} other{{count} одноразок}}'**
  String unitsDisposableShort(int n, String count);

  /// No description provided for @unitsAvoided.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{{count} сиг.} sticks{{count} стик.} disposable{{count} одноразок} liquid{{count} флак.} other{{count}}}'**
  String unitsAvoided(String type, String count);

  /// No description provided for @homeNoAttemptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новая попытка'**
  String get homeNoAttemptTitle;

  /// No description provided for @homeNoAttemptText.
  ///
  /// In ru, this message translates to:
  /// **'Каждая попытка делает вас сильнее. Опыт и значки остаются с вами.'**
  String get homeNoAttemptText;

  /// No description provided for @homeStartAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Начать с этой минуты'**
  String get homeStartAttempt;

  /// No description provided for @homeNextQuote.
  ///
  /// In ru, this message translates to:
  /// **'Следующая мысль'**
  String get homeNextQuote;

  /// No description provided for @sosButton.
  ///
  /// In ru, this message translates to:
  /// **'SOS'**
  String get sosButton;

  /// No description provided for @shortcutSos.
  ///
  /// In ru, this message translates to:
  /// **'Хочу закурить'**
  String get shortcutSos;

  /// No description provided for @widgetSmokeFree.
  ///
  /// In ru, this message translates to:
  /// **'без курения'**
  String get widgetSmokeFree;

  /// No description provided for @widgetClock.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч {minutes} мин'**
  String widgetClock(String hours, String minutes);

  /// No description provided for @sosTriggerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что сейчас происходит?'**
  String get sosTriggerTitle;

  /// No description provided for @sosTriggerHint.
  ///
  /// In ru, this message translates to:
  /// **'Один тап — и я запомню, когда вас тянет сильнее всего'**
  String get sosTriggerHint;

  /// No description provided for @sosSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get sosSkip;

  /// No description provided for @triggerName.
  ///
  /// In ru, this message translates to:
  /// **'{trigger, select, stress{Стресс} alcohol{Алкоголь} company{Компания} coffee{Кофе} afterMeal{После еды} boredom{Скука} ritual{Привычный момент} other{Другое}}'**
  String triggerName(String trigger);

  /// No description provided for @sosBreatheIn.
  ///
  /// In ru, this message translates to:
  /// **'Вдох'**
  String get sosBreatheIn;

  /// No description provided for @sosBreatheOut.
  ///
  /// In ru, this message translates to:
  /// **'Выдох'**
  String get sosBreatheOut;

  /// No description provided for @sosChangeExercise.
  ///
  /// In ru, this message translates to:
  /// **'Сменить'**
  String get sosChangeExercise;

  /// No description provided for @sosPickExercise.
  ///
  /// In ru, this message translates to:
  /// **'Выберите упражнение'**
  String get sosPickExercise;

  /// No description provided for @sosExerciseName.
  ///
  /// In ru, this message translates to:
  /// **'{exercise, select, breathing{Спокойное дыхание} countdown{Отсчёт 10 → 0} grounding{Заземление 5-4-3-2-1} other{}}'**
  String sosExerciseName(String exercise);

  /// No description provided for @sosExerciseDesc.
  ///
  /// In ru, this message translates to:
  /// **'{exercise, select, breathing{Вдох на 4 счёта, выдох на 6. Без задержек — просто следите за кругом.} countdown{Крупные числа от 10 до 0. Ничего делать не нужно — просто смотрите.} grounding{Пять простых шагов, чтобы вернуться в «здесь и сейчас».} other{}}'**
  String sosExerciseDesc(String exercise);

  /// No description provided for @sosCountdownHint.
  ///
  /// In ru, this message translates to:
  /// **'Просто смотрите на числа'**
  String get sosCountdownHint;

  /// No description provided for @sosCountdownDone.
  ///
  /// In ru, this message translates to:
  /// **'Вот и всё. Можно ещё раз.'**
  String get sosCountdownDone;

  /// No description provided for @sosAgain.
  ///
  /// In ru, this message translates to:
  /// **'Ещё раз'**
  String get sosAgain;

  /// No description provided for @sosGroundStep.
  ///
  /// In ru, this message translates to:
  /// **'{step, select, see{Найдите глазами 5 вещей вокруг} hear{Прислушайтесь: 4 звука, которые вы слышите} touch{Коснитесь 3 предметов и почувствуйте их} smell{Уловите 2 запаха} taste{Заметьте 1 вкус} other{}}'**
  String sosGroundStep(String step);

  /// No description provided for @sosGroundHint.
  ///
  /// In ru, this message translates to:
  /// **'Не спешите. Можно назвать про себя.'**
  String get sosGroundHint;

  /// No description provided for @sosNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get sosNext;

  /// No description provided for @sosGroundDone.
  ///
  /// In ru, this message translates to:
  /// **'Вы здесь и сейчас. Вы справляетесь.'**
  String get sosGroundDone;

  /// No description provided for @sosWaveHint.
  ///
  /// In ru, this message translates to:
  /// **'Тяга — как волна: она нарастает и спадает за 3–5 минут. Просто продержитесь.'**
  String get sosWaveHint;

  /// No description provided for @sosAnotherTip.
  ///
  /// In ru, this message translates to:
  /// **'Другой совет'**
  String get sosAnotherTip;

  /// No description provided for @sosResisted.
  ///
  /// In ru, this message translates to:
  /// **'Тяга прошла!'**
  String get sosResisted;

  /// No description provided for @sosResistedToast.
  ///
  /// In ru, this message translates to:
  /// **'Вы сильнее тяги! +{xp} XP'**
  String sosResistedToast(int xp);

  /// No description provided for @durMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} минута} few{{count} минуты} many{{count} минут} other{{count} минуты}}'**
  String durMinutes(int count);

  /// No description provided for @durHours.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} час} few{{count} часа} many{{count} часов} other{{count} часа}}'**
  String durHours(int count);

  /// No description provided for @durDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день} few{{count} дня} many{{count} дней} other{{count} дня}}'**
  String durDays(int count);

  /// No description provided for @durWeeks.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} неделя} few{{count} недели} many{{count} недель} other{{count} недели}}'**
  String durWeeks(int count);

  /// No description provided for @durMonths.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} месяц} few{{count} месяца} many{{count} месяцев} other{{count} месяца}}'**
  String durMonths(int count);

  /// No description provided for @durYears.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} год} few{{count} года} many{{count} лет} other{{count} года}}'**
  String durYears(int count);

  /// No description provided for @healthTabAchievements.
  ///
  /// In ru, this message translates to:
  /// **'Достижения'**
  String get healthTabAchievements;

  /// No description provided for @healthDisclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Сроки примерные и основаны на данных ACS, CDC и ВОЗ. Организм у каждого восстанавливается по-своему. Приложение не заменяет консультацию врача.'**
  String get healthDisclaimer;

  /// No description provided for @healthReached.
  ///
  /// In ru, this message translates to:
  /// **'Уже произошло'**
  String get healthReached;

  /// No description provided for @healthRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Осталось: {time}'**
  String healthRemaining(String time);

  /// No description provided for @healthNoAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Начните новую попытку на главном экране — и отсчёт восстановления пойдёт заново.'**
  String get healthNoAttempt;

  /// No description provided for @healthSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {source}'**
  String healthSource(String source);

  /// No description provided for @healthFilterPassed.
  ///
  /// In ru, this message translates to:
  /// **'Пройденные'**
  String get healthFilterPassed;

  /// No description provided for @healthFilterNearest.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие'**
  String get healthFilterNearest;

  /// No description provided for @healthFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get healthFilterAll;

  /// No description provided for @healthPassedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Пройдено этапов'**
  String get healthPassedLabel;

  /// No description provided for @healthNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующий этап — через {time}'**
  String healthNext(String time);

  /// No description provided for @healthAllPassed.
  ///
  /// In ru, this message translates to:
  /// **'Все этапы пройдены — это огромный путь!'**
  String get healthAllPassed;

  /// No description provided for @healthFirstDays.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас идут первые 8 дней: на них приходится больше всего срывов. Если тянет — нажмите SOS.'**
  String get healthFirstDays;

  /// No description provided for @healthFirstDaysDone.
  ///
  /// In ru, this message translates to:
  /// **'Первые 8 дней позади, а на них приходится больше всего срывов.'**
  String get healthFirstDaysDone;

  /// No description provided for @healthYouAreHere.
  ///
  /// In ru, this message translates to:
  /// **'Вы здесь'**
  String get healthYouAreHere;

  /// No description provided for @healthSmokeFreeFor.
  ///
  /// In ru, this message translates to:
  /// **'{time} без курения'**
  String healthSmokeFreeFor(String time);

  /// No description provided for @healthNonePassed.
  ///
  /// In ru, this message translates to:
  /// **'Первый этап совсем скоро — загляните в «Ближайшие».'**
  String get healthNonePassed;

  /// No description provided for @healthFactsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Факты из исследований'**
  String get healthFactsTitle;

  /// No description provided for @healthSub.
  ///
  /// In ru, this message translates to:
  /// **'{tab, select, stages{Этапы} facts{Факты} normal{Что нормально} body{Карта тела} notInhaled{Не вдохнули} other{Дневник}}'**
  String healthSub(String tab);

  /// No description provided for @normalIntro.
  ///
  /// In ru, this message translates to:
  /// **'Симптомы отмены — знак того, что организм перестраивается. Они временные и проходят сами. Не у всех бывают все симптомы.'**
  String get normalIntro;

  /// No description provided for @normalNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас это нормально'**
  String get normalNow;

  /// No description provided for @normalPast.
  ///
  /// In ru, this message translates to:
  /// **'Обычно уже позади'**
  String get normalPast;

  /// No description provided for @normalPastHint.
  ///
  /// In ru, this message translates to:
  /// **'Если что-то из этого всё ещё беспокоит — так тоже бывает. Если сильно мешает, посоветуйтесь с врачом.'**
  String get normalPastHint;

  /// No description provided for @normalLasts.
  ///
  /// In ru, this message translates to:
  /// **'Обычно: {duration}'**
  String normalLasts(String duration);

  /// No description provided for @normalHelps.
  ///
  /// In ru, this message translates to:
  /// **'Что помогает'**
  String get normalHelps;

  /// No description provided for @normalSources.
  ///
  /// In ru, this message translates to:
  /// **'Сроки — по таблице симптомов отмены MSD Manual (материалы программы Rx for Change, Калифорнийский университет); совет про кашель — NHS.'**
  String get normalSources;

  /// No description provided for @bodyIntro.
  ///
  /// In ru, this message translates to:
  /// **'Пройденные этапы заполняют карту. Нажмите на плитку, чтобы увидеть её этапы.'**
  String get bodyIntro;

  /// No description provided for @bodyArea.
  ///
  /// In ru, this message translates to:
  /// **'{area, select, heart{Сердце} lungs{Лёгкие} circulation{Кровообращение} energy{Энергия} mind{Голова и настроение} taste_smell{Вкус и запах} other{Защита от болезней}}'**
  String bodyArea(String area);

  /// No description provided for @bodyProgress.
  ///
  /// In ru, this message translates to:
  /// **'{done} из {total}'**
  String bodyProgress(int done, int total);

  /// No description provided for @notInhaledTitle.
  ///
  /// In ru, this message translates to:
  /// **'За эту попытку не попало в организм'**
  String get notInhaledTitle;

  /// No description provided for @notInhaledPuffsCig.
  ///
  /// In ru, this message translates to:
  /// **'≈ {count} {n, plural, one{затяжка} few{затяжки} other{затяжек}} дымом'**
  String notInhaledPuffsCig(String count, int n);

  /// No description provided for @notInhaledPuffsCigNote.
  ///
  /// In ru, this message translates to:
  /// **'В среднем на одну сигарету приходится около 12 затяжек (Pennsylvania Adult Smoking Study, Drug and Alcohol Dependence, 2018).'**
  String get notInhaledPuffsCigNote;

  /// No description provided for @notInhaledPuffsSticks.
  ///
  /// In ru, this message translates to:
  /// **'до {count} {n, plural, one{затяжки} other{затяжек}} аэрозолем'**
  String notInhaledPuffsSticks(String count, int n);

  /// No description provided for @notInhaledPuffsSticksNote.
  ///
  /// In ru, this message translates to:
  /// **'Устройство IQOS отключает нагрев стика после 14 затяжек или 6 минут — это верхняя граница.'**
  String get notInhaledPuffsSticksNote;

  /// No description provided for @notInhaledVape.
  ///
  /// In ru, this message translates to:
  /// **'Для вейпов считаем только единицы: число затяжек слишком зависит от устройства и манеры.'**
  String get notInhaledVape;

  /// No description provided for @notInhaledHonest.
  ///
  /// In ru, this message translates to:
  /// **'Смолы и угарный газ мы не считаем: их количество сильно зависит от марки и того, как человек курит, а надёжных данных для точного расчёта нет.'**
  String get notInhaledHonest;

  /// No description provided for @notInhaledNoAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Начните новую попытку на главном экране — и здесь появится счёт.'**
  String get notInhaledNoAttempt;

  /// No description provided for @notInhaledPacks.
  ///
  /// In ru, this message translates to:
  /// **'≈ {count} {n, plural, one{пачка} few{пачки} other{пачек}}'**
  String notInhaledPacks(String count, int n);

  /// No description provided for @notInhaledTime.
  ///
  /// In ru, this message translates to:
  /// **'≈ {time} без перекуров'**
  String notInhaledTime(String time);

  /// No description provided for @notInhaledTimeNote.
  ///
  /// In ru, this message translates to:
  /// **'Время перекуров — наша прикидка: около 5 минут на сигарету и до 6 минут на стик.'**
  String get notInhaledTimeNote;

  /// No description provided for @notInhaledAllTime.
  ///
  /// In ru, this message translates to:
  /// **'За все попытки'**
  String get notInhaledAllTime;

  /// No description provided for @notInhaledWhat.
  ///
  /// In ru, this message translates to:
  /// **'Чего вы не вдыхаете'**
  String get notInhaledWhat;

  /// No description provided for @diaryChannel.
  ///
  /// In ru, this message translates to:
  /// **'Дневник самочувствия'**
  String get diaryChannel;

  /// No description provided for @diaryChannelHint.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания заполнить дневник'**
  String get diaryChannelHint;

  /// No description provided for @diaryNotificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как вы себя чувствуете?'**
  String get diaryNotificationTitle;

  /// No description provided for @diaryNotificationBody.
  ///
  /// In ru, this message translates to:
  /// **'Пара отметок в дневнике самочувствия — и будет видно, как становится лучше.'**
  String get diaryNotificationBody;

  /// No description provided for @settingsDiaryReminder.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать о Дневнике самочувствия'**
  String get settingsDiaryReminder;

  /// No description provided for @settingsDiaryReminderHint.
  ///
  /// In ru, this message translates to:
  /// **'Красная точка на «Здоровье», когда пора заполнить'**
  String get settingsDiaryReminderHint;

  /// No description provided for @settingsDiaryPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Как часто'**
  String get settingsDiaryPeriod;

  /// No description provided for @settingsDiaryTime.
  ///
  /// In ru, this message translates to:
  /// **'Во сколько'**
  String get settingsDiaryTime;

  /// No description provided for @diaryPeriod.
  ///
  /// In ru, this message translates to:
  /// **'{days, select, 1{Каждый день} 3{Раз в 3 дня} other{Раз в неделю}}'**
  String diaryPeriod(String days);

  /// No description provided for @diaryIntro.
  ///
  /// In ru, this message translates to:
  /// **'Отмечайте время от времени, как вы себя чувствуете, — и график покажет, как становится лучше.'**
  String get diaryIntro;

  /// No description provided for @diaryHowNow.
  ///
  /// In ru, this message translates to:
  /// **'Как вы сейчас?'**
  String get diaryHowNow;

  /// No description provided for @diaryQuestion.
  ///
  /// In ru, this message translates to:
  /// **'{q, select, sleep{Сон} breathing{Дыхание} mood{Настроение} other{Вкус и запах}}'**
  String diaryQuestion(String q);

  /// No description provided for @diaryScale.
  ///
  /// In ru, this message translates to:
  /// **'{v, select, 1{Плохо} 2{Так себе} 3{Нормально} 4{Хорошо} other{Отлично}}'**
  String diaryScale(String v);

  /// No description provided for @diarySave.
  ///
  /// In ru, this message translates to:
  /// **'Записать'**
  String get diarySave;

  /// No description provided for @diarySaved.
  ///
  /// In ru, this message translates to:
  /// **'Записано. Спасибо!'**
  String get diarySaved;

  /// No description provided for @diaryDoneToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня уже записано'**
  String get diaryDoneToday;

  /// No description provided for @diaryAgain.
  ///
  /// In ru, this message translates to:
  /// **'Записать ещё раз'**
  String get diaryAgain;

  /// No description provided for @diaryNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующая запись — {date}'**
  String diaryNext(String date);

  /// No description provided for @diaryChart.
  ///
  /// In ru, this message translates to:
  /// **'Как меняется самочувствие'**
  String get diaryChart;

  /// No description provided for @diaryChartEmpty.
  ///
  /// In ru, this message translates to:
  /// **'График появится после двух записей.'**
  String get diaryChartEmpty;

  /// No description provided for @diaryChange.
  ///
  /// In ru, this message translates to:
  /// **'{first} → {last}'**
  String diaryChange(int first, int last);

  /// No description provided for @diaryRemindHint.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания можно включить в Настройках → Уведомления.'**
  String get diaryRemindHint;

  /// No description provided for @diaryLocalNote.
  ///
  /// In ru, this message translates to:
  /// **'Дневник хранится только на этом телефоне.'**
  String get diaryLocalNote;

  /// No description provided for @achProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} из {total}'**
  String achProgress(String current, String total);

  /// No description provided for @achOfDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} дня} other{{count} дней}}'**
  String achOfDays(int count);

  /// No description provided for @achOfHours.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} часа} other{{count} часов}}'**
  String achOfHours(int count);

  /// No description provided for @achOfMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} минуты} other{{count} минут}}'**
  String achOfMinutes(int count);

  /// No description provided for @achOfUnits.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{сигарет} sticks{стиков} disposable{одноразок} liquid{флаконов} other{}}'**
  String achOfUnits(String type);

  /// No description provided for @achUnlockedCount.
  ///
  /// In ru, this message translates to:
  /// **'Открыто {unlocked} из {total} ({percent}%)'**
  String achUnlockedCount(int unlocked, int total, int percent);

  /// No description provided for @achUnlockedAt.
  ///
  /// In ru, this message translates to:
  /// **'Получено {date}'**
  String achUnlockedAt(String date);

  /// No description provided for @achHowTo.
  ///
  /// In ru, this message translates to:
  /// **'Как получить: {condition}'**
  String achHowTo(String condition);

  /// No description provided for @achCondSmokeFree.
  ///
  /// In ru, this message translates to:
  /// **'продержаться без курения: {time}'**
  String achCondSmokeFree(String time);

  /// No description provided for @achCondMoney.
  ///
  /// In ru, this message translates to:
  /// **'сэкономить {amount} ₽'**
  String achCondMoney(String amount);

  /// No description provided for @achCondCravings.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{справиться с тягой {count} раз} few{справиться с тягой {count} раза} many{справиться с тягой {count} раз} other{справиться с тягой {count} раза}}'**
  String achCondCravings(int count);

  /// No description provided for @achCondArticles.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{прочитать {count} статью} few{прочитать {count} статьи} many{прочитать {count} статей} other{прочитать {count} статьи}}'**
  String achCondArticles(int count);

  /// No description provided for @achCondAttempts.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{начать первую попытку} few{начать {count} попытки} many{начать {count} попыток} other{начать {count} попытки}}'**
  String achCondAttempts(int count);

  /// No description provided for @achCondComeback.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{вернуться после срыва} few{вернуться после срыва {count} раза} many{вернуться после срыва {count} раз} other{вернуться после срыва {count} раза}}'**
  String achCondComeback(int count);

  /// No description provided for @achCondUnits.
  ///
  /// In ru, this message translates to:
  /// **'не использовано — {units}'**
  String achCondUnits(String units);

  /// No description provided for @unitsCigarettes.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} сигарета} few{{count} сигареты} many{{count} сигарет} other{{count} сигареты}}'**
  String unitsCigarettes(int count);

  /// No description provided for @unitsSticks.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} стик} few{{count} стика} many{{count} стиков} other{{count} стика}}'**
  String unitsSticks(int count);

  /// No description provided for @unitsDisposable.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} одноразка} few{{count} одноразки} many{{count} одноразок} other{{count} одноразки}}'**
  String unitsDisposable(int count);

  /// No description provided for @unitsLiquid.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} флакон жидкости} few{{count} флакона жидкости} many{{count} флаконов жидкости} other{{count} флакона жидкости}}'**
  String unitsLiquid(int count);

  /// No description provided for @achGroup.
  ///
  /// In ru, this message translates to:
  /// **'{name, select, streak{Без курения} cravings{Победы над тягой} money{Сбережения} units{Не использовано} articles{Знания} other{Путь}}'**
  String achGroup(String name);

  /// No description provided for @achGroupProgress.
  ///
  /// In ru, this message translates to:
  /// **'{unlocked} из {total} ({percent}%)'**
  String achGroupProgress(int unlocked, int total, int percent);

  /// No description provided for @collapseAll.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть все'**
  String get collapseAll;

  /// No description provided for @expandAll.
  ///
  /// In ru, this message translates to:
  /// **'Развернуть все'**
  String get expandAll;

  /// No description provided for @tierName.
  ///
  /// In ru, this message translates to:
  /// **'{tier, select, common{Обычное} uncommon{Необычное} rare{Редкое} epic{Эпическое} other{Легендарное}}'**
  String tierName(String tier);

  /// No description provided for @achCelebrateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое достижение!'**
  String get achCelebrateTitle;

  /// No description provided for @achCelebrateOk.
  ///
  /// In ru, this message translates to:
  /// **'Забрать'**
  String get achCelebrateOk;

  /// No description provided for @achNewMany.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Открыто {count} достижение} few{Открыто {count} достижения} many{Открыто {count} достижений} other{Открыто {count} достижения}} — загляните во вкладку «Здоровье»'**
  String achNewMany(int count);

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeMode.
  ///
  /// In ru, this message translates to:
  /// **'Тема оформления'**
  String get settingsThemeMode;

  /// No description provided for @themeModeName.
  ///
  /// In ru, this message translates to:
  /// **'{mode, select, system{Системный} light{Светлый} dark{Тёмный} other{}}'**
  String themeModeName(String mode);

  /// No description provided for @settingsPalette.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get settingsPalette;

  /// No description provided for @paletteName.
  ///
  /// In ru, this message translates to:
  /// **'{name, select, mint{Мята} graphite{Графит} ocean{Океан} pine{Хвоя} sunset{Закат} twilight{Сумерки} other{}}'**
  String paletteName(String name);

  /// No description provided for @settingsAppIcon.
  ///
  /// In ru, this message translates to:
  /// **'Значок приложения'**
  String get settingsAppIcon;

  /// No description provided for @settingsAppIconHintAndroid.
  ///
  /// In ru, this message translates to:
  /// **'Значок на рабочем столе сменится через несколько секунд. На некоторых телефонах приложение при этом закрывается — просто откройте его снова.'**
  String get settingsAppIconHintAndroid;

  /// No description provided for @settingsAppIconHintIos.
  ///
  /// In ru, this message translates to:
  /// **'iPhone покажет короткое сообщение о том, что значок изменён.'**
  String get settingsAppIconHintIos;

  /// No description provided for @appIconOption.
  ///
  /// In ru, this message translates to:
  /// **'Значок {n} из 4'**
  String appIconOption(int n);

  /// No description provided for @appIconFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не получилось сменить значок. Попробуйте ещё раз.'**
  String get appIconFailed;

  /// No description provided for @settingsSos.
  ///
  /// In ru, this message translates to:
  /// **'SOS'**
  String get settingsSos;

  /// No description provided for @settingsNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsMilestones.
  ///
  /// In ru, this message translates to:
  /// **'Этапы восстановления'**
  String get settingsNotificationsMilestones;

  /// No description provided for @notificationChannel.
  ///
  /// In ru, this message translates to:
  /// **'Этапы восстановления'**
  String get notificationChannel;

  /// No description provided for @notificationChannelHint.
  ///
  /// In ru, this message translates to:
  /// **'Редкие уведомления, когда здоровье делает очередной шаг'**
  String get notificationChannelHint;

  /// No description provided for @settingsNotificationsHint.
  ///
  /// In ru, this message translates to:
  /// **'Редко и только по делу: когда здоровье делает очередной шаг. Ночью не беспокоим'**
  String get settingsNotificationsHint;

  /// No description provided for @settingsSosExercise.
  ///
  /// In ru, this message translates to:
  /// **'Упражнение по умолчанию'**
  String get settingsSosExercise;

  /// No description provided for @settingsAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Моя попытка'**
  String get settingsAttempt;

  /// No description provided for @relapseButton.
  ///
  /// In ru, this message translates to:
  /// **'Я закурил(а)'**
  String get relapseButton;

  /// No description provided for @relapseButtonHint.
  ///
  /// In ru, this message translates to:
  /// **'Без упрёков: отметим и начнём заново'**
  String get relapseButtonHint;

  /// No description provided for @historyButton.
  ///
  /// In ru, this message translates to:
  /// **'История попыток'**
  String get historyButton;

  /// No description provided for @historyButtonHint.
  ///
  /// In ru, this message translates to:
  /// **'Рекорд: {best}'**
  String historyButtonHint(String best);

  /// No description provided for @relapseConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы закурили?'**
  String get relapseConfirmTitle;

  /// No description provided for @relapseConfirmText.
  ///
  /// In ru, this message translates to:
  /// **'Текущий отсчёт остановится. Дальше можно записать, что произошло, и начать новую попытку.'**
  String get relapseConfirmText;

  /// No description provided for @relapseConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждаю'**
  String get relapseConfirm;

  /// No description provided for @relapseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневник без упрёков'**
  String get relapseTitle;

  /// No description provided for @relapseIntro.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо, что отметили честно. Срыв — не провал, а подсказка: он показывает, что именно сработало против вас.'**
  String get relapseIntro;

  /// No description provided for @relapseWhen.
  ///
  /// In ru, this message translates to:
  /// **'Когда это было?'**
  String get relapseWhen;

  /// No description provided for @relapseJustNow.
  ///
  /// In ru, this message translates to:
  /// **'Только что'**
  String get relapseJustNow;

  /// No description provided for @relapsePickTime.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать время'**
  String get relapsePickTime;

  /// No description provided for @relapseTrigger.
  ///
  /// In ru, this message translates to:
  /// **'Что к этому привело?'**
  String get relapseTrigger;

  /// No description provided for @relapseQ1.
  ///
  /// In ru, this message translates to:
  /// **'Что произошло?'**
  String get relapseQ1;

  /// No description provided for @relapseQ2.
  ///
  /// In ru, this message translates to:
  /// **'Что могло бы помочь?'**
  String get relapseQ2;

  /// No description provided for @relapseQ3.
  ///
  /// In ru, this message translates to:
  /// **'Что попробую в следующий раз?'**
  String get relapseQ3;

  /// No description provided for @relapseOptional.
  ///
  /// In ru, this message translates to:
  /// **'Всё необязательно — можно просто сохранить.'**
  String get relapseOptional;

  /// No description provided for @relapseSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get relapseSave;

  /// No description provided for @relapseDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Это часть пути'**
  String get relapseDoneTitle;

  /// No description provided for @relapseDoneText.
  ///
  /// In ru, this message translates to:
  /// **'Без курения вы продержались {duration}. Ваш рекорд — {best}. Следующая попытка начнётся уже с этим знанием, а сохранить награды или начать с чистого листа — решать вам.'**
  String relapseDoneText(String duration, String best);

  /// No description provided for @relapseStartNow.
  ///
  /// In ru, this message translates to:
  /// **'Начать новую попытку сейчас'**
  String get relapseStartNow;

  /// No description provided for @relapseLater.
  ///
  /// In ru, this message translates to:
  /// **'Начать новую попытку позже'**
  String get relapseLater;

  /// No description provided for @historyTitle.
  ///
  /// In ru, this message translates to:
  /// **'История попыток'**
  String get historyTitle;

  /// No description provided for @historyBest.
  ///
  /// In ru, this message translates to:
  /// **'Рекорд'**
  String get historyBest;

  /// No description provided for @historyTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего'**
  String get historyTotal;

  /// No description provided for @historyCount.
  ///
  /// In ru, this message translates to:
  /// **'Попыток'**
  String get historyCount;

  /// No description provided for @historyAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Попытка {n}'**
  String historyAttempt(int n);

  /// No description provided for @historyCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас · попытка {n}'**
  String historyCurrent(int n);

  /// No description provided for @historyNow.
  ///
  /// In ru, this message translates to:
  /// **'идёт сейчас'**
  String get historyNow;

  /// No description provided for @historyBadges.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} награда} few{{count} награды} many{{count} наград} other{{count} награды}}'**
  String historyBadges(int count);

  /// No description provided for @settingsAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get settingsAbout;

  /// No description provided for @settingsDeveloper.
  ///
  /// In ru, this message translates to:
  /// **'Информация о разработчике'**
  String get settingsDeveloper;

  /// No description provided for @settingsDeveloperHint.
  ///
  /// In ru, this message translates to:
  /// **'boosty.to/tony_vinsenty'**
  String get settingsDeveloperHint;

  /// No description provided for @settingsVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version} (сборка {build})'**
  String settingsVersion(String version, String build);

  /// No description provided for @settingsData.
  ///
  /// In ru, this message translates to:
  /// **'Мои данные'**
  String get settingsData;

  /// No description provided for @settingsHabits.
  ///
  /// In ru, this message translates to:
  /// **'Мои привычки'**
  String get settingsHabits;

  /// No description provided for @settingsHabitsHint.
  ///
  /// In ru, this message translates to:
  /// **'Что и сколько вы курили, цены. По ним считается экономия текущей попытки'**
  String get settingsHabitsHint;

  /// No description provided for @settingsHabitsSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено. Экономия пересчитана'**
  String get settingsHabitsSaved;

  /// No description provided for @settingsReset.
  ///
  /// In ru, this message translates to:
  /// **'Полный сброс'**
  String get settingsReset;

  /// No description provided for @settingsResetHint.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные и начать с первого экрана'**
  String get settingsResetHint;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все данные?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmText.
  ///
  /// In ru, this message translates to:
  /// **'Попытки, достижения, дневник и ответы о курении будут удалены навсегда. Приложение начнётся заново с первого экрана.'**
  String get settingsResetConfirmText;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить всё'**
  String get settingsResetConfirm;

  /// No description provided for @productsEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что вы курите'**
  String get productsEditTitle;

  /// No description provided for @freshStartTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как начать новую попытку?'**
  String get freshStartTitle;

  /// No description provided for @freshStartKeep.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get freshStartKeep;

  /// No description provided for @freshStartKeepText.
  ///
  /// In ru, this message translates to:
  /// **'Уровень, опыт, награды, сэкономленные деньги и тяги остаются с вами.'**
  String get freshStartKeepText;

  /// No description provided for @freshStartReset.
  ///
  /// In ru, this message translates to:
  /// **'С чистого листа'**
  String get freshStartReset;

  /// No description provided for @freshStartResetText.
  ///
  /// In ru, this message translates to:
  /// **'Уровень, опыт, деньги, тяги и награды начнутся с нуля. Останутся рекорд, история попыток, прочитанные статьи и награды за путь и статьи.'**
  String get freshStartResetText;

  /// No description provided for @newAttemptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки курения'**
  String get newAttemptTitle;

  /// No description provided for @newAttemptText.
  ///
  /// In ru, this message translates to:
  /// **'Оставить прошлые настройки? По ним считаются сэкономленные деньги. Если за это время вы перешли на другое — измените.'**
  String get newAttemptText;

  /// No description provided for @newAttemptKeep.
  ///
  /// In ru, this message translates to:
  /// **'Оставить'**
  String get newAttemptKeep;

  /// No description provided for @newAttemptChange.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get newAttemptChange;

  /// No description provided for @productSummary.
  ///
  /// In ru, this message translates to:
  /// **'{amount} {period} · {price} ₽ {type, select, cigarettes{за пачку} sticks{за пачку} disposable{за штуку} liquid{за флакон} other{}}'**
  String productSummary(
    String amount,
    String period,
    String price,
    String type,
  );

  /// No description provided for @knowledgeProgress.
  ///
  /// In ru, this message translates to:
  /// **'Прочитано {read} из {total}'**
  String knowledgeProgress(int read, int total);

  /// No description provided for @knowledgeAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get knowledgeAll;

  /// No description provided for @knowledgeGroupRead.
  ///
  /// In ru, this message translates to:
  /// **'{read} из {total}'**
  String knowledgeGroupRead(int read, int total);

  /// No description provided for @articleCategory.
  ///
  /// In ru, this message translates to:
  /// **'{category, select, forYou{Для вас} addiction{Зависимость} health{Здоровье} practice{Практика} myths{Мифы} vape{Вейпы и IQOS} money{Деньги} therapy{Помощь и лечение} other{Другое}}'**
  String articleCategory(String category);

  /// No description provided for @articleMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String articleMinutes(int minutes);

  /// No description provided for @articleRead.
  ///
  /// In ru, this message translates to:
  /// **'Прочитано'**
  String get articleRead;

  /// No description provided for @articleReadSnack.
  ///
  /// In ru, this message translates to:
  /// **'Статья прочитана'**
  String get articleReadSnack;

  /// No description provided for @articleNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующая статья'**
  String get articleNext;

  /// No description provided for @articleDisclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Статья носит справочный характер и не заменяет консультацию врача.'**
  String get articleDisclaimer;

  /// No description provided for @hintGotIt.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get hintGotIt;

  /// No description provided for @hintCravingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как читать карту'**
  String get hintCravingTitle;

  /// No description provided for @hintCravingText.
  ///
  /// In ru, this message translates to:
  /// **'Сюда попадает каждое нажатие SOS и каждая запись «Я закурил(а)». Бирюзовым отмечена тяга, с которой вы справились, серым — когда закурили. Ищите время и поводы, которые повторяются: к ним можно подготовиться заранее.'**
  String get hintCravingText;

  /// No description provided for @hintDiaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как заполнять'**
  String get hintDiaryTitle;

  /// No description provided for @hintDiaryText.
  ///
  /// In ru, this message translates to:
  /// **'Ответьте на четыре вопроса по шкале от 1 до 5: 1 — плохо, 5 — отлично. Хватит раза в день или реже, напоминание можно включить в Настройках. Графики появятся после двух записей.'**
  String get hintDiaryText;

  /// No description provided for @cravingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Карта тяги'**
  String get cravingTitle;

  /// No description provided for @cravingHomeEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Когда потянет курить — нажмите SOS. Здесь появится, когда и почему вас тянет чаще всего.'**
  String get cravingHomeEmpty;

  /// No description provided for @cravingResistedTimes.
  ///
  /// In ru, this message translates to:
  /// **'Справились {resisted} {resisted, plural, one{раз} few{раза} many{раз} other{раза}}'**
  String cravingResistedTimes(int resisted);

  /// No description provided for @cravingOften.
  ///
  /// In ru, this message translates to:
  /// **'Чаще всего — {part}'**
  String cravingOften(String part);

  /// No description provided for @dayPartWhen.
  ///
  /// In ru, this message translates to:
  /// **'{part, select, morning{утром} afternoon{днём} evening{вечером} night{ночью} other{}}'**
  String dayPartWhen(String part);

  /// No description provided for @dayPartName.
  ///
  /// In ru, this message translates to:
  /// **'{part, select, morning{Утро} afternoon{День} evening{Вечер} night{Ночь} other{}}'**
  String dayPartName(String part);

  /// No description provided for @dayPartHours.
  ///
  /// In ru, this message translates to:
  /// **'{part, select, morning{6–12} afternoon{12–18} evening{18–24} night{0–6} other{}}'**
  String dayPartHours(String part);

  /// No description provided for @cravingPeriodWeek.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get cravingPeriodWeek;

  /// No description provided for @cravingPeriodMonth.
  ///
  /// In ru, this message translates to:
  /// **'30 дней'**
  String get cravingPeriodMonth;

  /// No description provided for @cravingPeriodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё время'**
  String get cravingPeriodAll;

  /// No description provided for @cravingSummary.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{раз тяга прошла без сигареты} few{раза тяга прошла без сигареты} many{раз тяга прошла без сигареты} other{раза тяга прошла без сигареты}}'**
  String cravingSummary(int count);

  /// No description provided for @cravingOfTotal.
  ///
  /// In ru, this message translates to:
  /// **'из {total}'**
  String cravingOfTotal(int total);

  /// No description provided for @cravingTimeOfDay.
  ///
  /// In ru, this message translates to:
  /// **'Время суток'**
  String get cravingTimeOfDay;

  /// No description provided for @cravingPeakHour.
  ///
  /// In ru, this message translates to:
  /// **'Самый трудный час — около {from}:00–{to}:00'**
  String cravingPeakHour(String from, String to);

  /// No description provided for @cravingTriggers.
  ///
  /// In ru, this message translates to:
  /// **'Поводы'**
  String get cravingTriggers;

  /// No description provided for @cravingNoTrigger.
  ///
  /// In ru, this message translates to:
  /// **'Повод не указан'**
  String get cravingNoTrigger;

  /// No description provided for @cravingWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get cravingWeekdays;

  /// No description provided for @cravingTipTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чаще всего повод — «{trigger}»'**
  String cravingTipTitle(String trigger);

  /// No description provided for @cravingLegendResisted.
  ///
  /// In ru, this message translates to:
  /// **'справились'**
  String get cravingLegendResisted;

  /// No description provided for @cravingLegendSmoked.
  ///
  /// In ru, this message translates to:
  /// **'закурили'**
  String get cravingLegendSmoked;

  /// No description provided for @cravingNoData.
  ///
  /// In ru, this message translates to:
  /// **'За этот период записей нет. Когда потянет курить, нажмите SOS — каждая запись делает карту точнее.'**
  String get cravingNoData;

  /// No description provided for @cravingSource.
  ///
  /// In ru, this message translates to:
  /// **'Карта строится по нажатиям SOS и записям «Я закурил(а)». Все данные хранятся только на вашем телефоне.'**
  String get cravingSource;

  /// No description provided for @socialJoinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как вас будут видеть друзья?'**
  String get socialJoinTitle;

  /// No description provided for @socialJoinText.
  ///
  /// In ru, this message translates to:
  /// **'Выберите ник — настоящее имя не нужно. Сменить его можно в любой момент.'**
  String get socialJoinText;

  /// No description provided for @socialJoinMore.
  ///
  /// In ru, this message translates to:
  /// **'Другие варианты'**
  String get socialJoinMore;

  /// No description provided for @socialJoinButton.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить как «{nick}»'**
  String socialJoinButton(String nick);

  /// No description provided for @socialNickChangeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый ник'**
  String get socialNickChangeTitle;

  /// No description provided for @socialOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Проверьте интернет и попробуйте ещё раз.'**
  String get socialOffline;

  /// No description provided for @socialRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get socialRetry;

  /// No description provided for @metricXp.
  ///
  /// In ru, this message translates to:
  /// **'Опыт'**
  String get metricXp;

  /// No description provided for @metricBadges.
  ///
  /// In ru, this message translates to:
  /// **'Значки'**
  String get metricBadges;

  /// No description provided for @metricDays.
  ///
  /// In ru, this message translates to:
  /// **'Дни'**
  String get metricDays;

  /// No description provided for @metricMoney.
  ///
  /// In ru, this message translates to:
  /// **'Деньги'**
  String get metricMoney;

  /// No description provided for @valueXp.
  ///
  /// In ru, this message translates to:
  /// **'{xp} XP'**
  String valueXp(String xp);

  /// No description provided for @valueBadges.
  ///
  /// In ru, this message translates to:
  /// **'{count} зн.'**
  String valueBadges(int count);

  /// No description provided for @valueDays.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн.'**
  String valueDays(int count);

  /// No description provided for @socialYou.
  ///
  /// In ru, this message translates to:
  /// **'Вы'**
  String get socialYou;

  /// No description provided for @socialHidden.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} человек не показывает} few{{count} человека не показывают} many{{count} человек не показывают} other{{count} человека не показывают}} этот показатель — и это нормально'**
  String socialHidden(int count);

  /// No description provided for @socialMeHidden.
  ///
  /// In ru, this message translates to:
  /// **'Вы не показываете этот показатель друзьям. Изменить — в «Приватности».'**
  String get socialMeHidden;

  /// No description provided for @socialMyCode.
  ///
  /// In ru, this message translates to:
  /// **'Мой код друга'**
  String get socialMyCode;

  /// No description provided for @socialCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get socialCopy;

  /// No description provided for @socialCodeCopied.
  ///
  /// In ru, this message translates to:
  /// **'Код скопирован в буфер обмена'**
  String get socialCodeCopied;

  /// No description provided for @socialAddFriendShort.
  ///
  /// In ru, this message translates to:
  /// **'Друг'**
  String get socialAddFriendShort;

  /// No description provided for @socialAddFriendTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить друга'**
  String get socialAddFriendTitle;

  /// No description provided for @socialAddFriendText.
  ///
  /// In ru, this message translates to:
  /// **'Попросите у друга его код из вкладки «Рейтинг» и введите его здесь.'**
  String get socialAddFriendText;

  /// No description provided for @socialCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код друга'**
  String get socialCodeLabel;

  /// No description provided for @socialPaste.
  ///
  /// In ru, this message translates to:
  /// **'Вставить'**
  String get socialPaste;

  /// No description provided for @socialAddButton.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get socialAddButton;

  /// No description provided for @socialAddMutual.
  ///
  /// In ru, this message translates to:
  /// **'Вы появитесь и в списке друга. Убрать друга можно долгим нажатием на него в списке.'**
  String get socialAddMutual;

  /// No description provided for @socialCodeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Такого кода нет — проверьте буквы и цифры'**
  String get socialCodeNotFound;

  /// No description provided for @socialCodeSelf.
  ///
  /// In ru, this message translates to:
  /// **'Это ваш собственный код'**
  String get socialCodeSelf;

  /// No description provided for @socialFriendAdded.
  ///
  /// In ru, this message translates to:
  /// **'{nick} теперь в ваших друзьях'**
  String socialFriendAdded(String nick);

  /// No description provided for @socialNoFriends.
  ///
  /// In ru, this message translates to:
  /// **'Пока здесь только вы. Поделитесь своим кодом или добавьте друга по его коду.'**
  String get socialNoFriends;

  /// No description provided for @socialRemoveTitle.
  ///
  /// In ru, this message translates to:
  /// **'Убрать «{nick}» из друзей?'**
  String socialRemoveTitle(String nick);

  /// No description provided for @socialRemoveText.
  ///
  /// In ru, this message translates to:
  /// **'Вы исчезнете из списков друг друга. Снова добавиться можно по коду.'**
  String get socialRemoveText;

  /// No description provided for @socialRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get socialRemove;

  /// No description provided for @privacyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приватность'**
  String get privacyTitle;

  /// No description provided for @privacyPreview.
  ///
  /// In ru, this message translates to:
  /// **'Так вас видят друзья'**
  String get privacyPreview;

  /// No description provided for @privacyOnlyNick.
  ///
  /// In ru, this message translates to:
  /// **'Только ник'**
  String get privacyOnlyNick;

  /// No description provided for @shareXp.
  ///
  /// In ru, this message translates to:
  /// **'Уровень и опыт (XP)'**
  String get shareXp;

  /// No description provided for @shareXpHint.
  ///
  /// In ru, this message translates to:
  /// **'Опыт никогда не сгорает'**
  String get shareXpHint;

  /// No description provided for @shareBadges.
  ///
  /// In ru, this message translates to:
  /// **'Значки'**
  String get shareBadges;

  /// No description provided for @shareBadgesHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько достижений получено'**
  String get shareBadgesHint;

  /// No description provided for @shareDays.
  ///
  /// In ru, this message translates to:
  /// **'Дни без курения'**
  String get shareDays;

  /// No description provided for @shareDaysHint.
  ///
  /// In ru, this message translates to:
  /// **'Текущая попытка'**
  String get shareDaysHint;

  /// No description provided for @shareMoney.
  ///
  /// In ru, this message translates to:
  /// **'Сэкономленные деньги'**
  String get shareMoney;

  /// No description provided for @shareMoneyHint.
  ///
  /// In ru, this message translates to:
  /// **'За текущую попытку'**
  String get shareMoneyHint;

  /// No description provided for @privacyServerNote.
  ///
  /// In ru, this message translates to:
  /// **'На сервере хранятся только ник, код друга, список друзей и отмеченные показатели. Ничего о здоровье и тяге туда не уходит.'**
  String get privacyServerNote;

  /// No description provided for @privacyNotJoined.
  ///
  /// In ru, this message translates to:
  /// **'Вы ещё не в рейтинге. Эти настройки применятся, когда вы выберете ник на вкладке «Рейтинг».'**
  String get privacyNotJoined;

  /// No description provided for @privacyNick.
  ///
  /// In ru, this message translates to:
  /// **'Ник'**
  String get privacyNick;

  /// No description provided for @privacyChangeNick.
  ///
  /// In ru, this message translates to:
  /// **'Сменить'**
  String get privacyChangeNick;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт рейтинга'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteText.
  ///
  /// In ru, this message translates to:
  /// **'Ник, код и друзья будут стёрты с сервера навсегда. Прогресс в приложении останется, вернуться в рейтинг можно позже.'**
  String get privacyDeleteText;

  /// No description provided for @privacyDeleteButton.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get privacyDeleteButton;

  /// No description provided for @privacyDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт рейтинга?'**
  String get privacyDeleteConfirm;

  /// No description provided for @privacyDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт рейтинга удалён'**
  String get privacyDeleted;

  /// No description provided for @chipLevel.
  ///
  /// In ru, this message translates to:
  /// **'Ур. {level} · {xp} XP'**
  String chipLevel(int level, String xp);

  /// No description provided for @chipBadges.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} значок} few{{count} значка} other{{count} значков}}'**
  String chipBadges(int count);

  /// No description provided for @chipDays.
  ///
  /// In ru, this message translates to:
  /// **'{count} дн. без курения'**
  String chipDays(int count);

  /// No description provided for @chipMoney.
  ///
  /// In ru, this message translates to:
  /// **'{money} сэкономлено'**
  String chipMoney(String money);

  /// No description provided for @settingsRating.
  ///
  /// In ru, this message translates to:
  /// **'Рейтинг'**
  String get settingsRating;

  /// No description provided for @settingsPrivacyHint.
  ///
  /// In ru, this message translates to:
  /// **'Ник, что видят друзья, удаление аккаунта'**
  String get settingsPrivacyHint;

  /// No description provided for @thanksRow.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо'**
  String get thanksRow;

  /// No description provided for @thanksRowHint.
  ///
  /// In ru, this message translates to:
  /// **'Люди, которые поддерживают Zero'**
  String get thanksRowHint;

  /// No description provided for @thanksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо'**
  String get thanksTitle;

  /// No description provided for @thanksSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Zero бесплатный и без рекламы благодаря этим людям'**
  String get thanksSubtitle;

  /// No description provided for @thanksTier.
  ///
  /// In ru, this message translates to:
  /// **'{tier, select, coauthors{Соавторы} testers{Тестировщики} supporters{Поддержали} other{}}'**
  String thanksTier(String tier);

  /// No description provided for @thanksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся имена'**
  String get thanksEmpty;

  /// No description provided for @thanksJoin.
  ///
  /// In ru, this message translates to:
  /// **'Хотите в этот список?'**
  String get thanksJoin;

  /// No description provided for @thanksBoosty.
  ///
  /// In ru, this message translates to:
  /// **'Загляните на Boosty'**
  String get thanksBoosty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
