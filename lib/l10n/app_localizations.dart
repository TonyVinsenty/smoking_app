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

  /// No description provided for @comingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро здесь что-то появится'**
  String get comingSoon;

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
  /// **'Штук в пачке'**
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
  /// **'Уровень {level}'**
  String homeLevel(int level);

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

  /// No description provided for @sosHold.
  ///
  /// In ru, this message translates to:
  /// **'Задержка'**
  String get sosHold;

  /// No description provided for @sosBreatheOut.
  ///
  /// In ru, this message translates to:
  /// **'Выдох'**
  String get sosBreatheOut;

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
  /// **'Справился!'**
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

  /// No description provided for @healthTabRecovery.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление'**
  String get healthTabRecovery;

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

  /// No description provided for @achUnlockedCount.
  ///
  /// In ru, this message translates to:
  /// **'Открыто {unlocked} из {total}'**
  String achUnlockedCount(int unlocked, int total);

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
  /// **'не выкурить {count} шт.'**
  String achCondUnits(String count);

  /// No description provided for @tierName.
  ///
  /// In ru, this message translates to:
  /// **'{tier, select, bronze{Бронза} silver{Серебро} gold{Золото} other{Платина}}'**
  String tierName(String tier);

  /// No description provided for @achCelebrateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое достижение!'**
  String get achCelebrateTitle;

  /// No description provided for @achCelebrateOk.
  ///
  /// In ru, this message translates to:
  /// **'Ура!'**
  String get achCelebrateOk;

  /// No description provided for @achNewMany.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Открыто {count} достижение} few{Открыто {count} достижения} many{Открыто {count} достижений} other{Открыто {count} достижения}} — загляните во вкладку «Здоровье»'**
  String achNewMany(int count);

  /// No description provided for @settingsAppearance.
  ///
  /// In ru, this message translates to:
  /// **'Цветовой тон'**
  String get settingsAppearance;

  /// No description provided for @themeModeName.
  ///
  /// In ru, this message translates to:
  /// **'{mode, select, system{Системный} light{Светлый} dark{Тёмный} other{}}'**
  String themeModeName(String mode);

  /// No description provided for @settingsLargeText.
  ///
  /// In ru, this message translates to:
  /// **'Крупный текст'**
  String get settingsLargeText;

  /// No description provided for @settingsLargeTextHint.
  ///
  /// In ru, this message translates to:
  /// **'Увеличивает текст во всём приложении'**
  String get settingsLargeTextHint;

  /// No description provided for @settingsData.
  ///
  /// In ru, this message translates to:
  /// **'Мои данные'**
  String get settingsData;

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
