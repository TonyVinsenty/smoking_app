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
  /// **'Не курю'**
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
  /// **'{type, select, cigarettes{Сигареты} sticks{Стики (IQOS, glo и др.)} disposable{Одноразовые вейпы} liquid{Жидкость для вейпа} other{}}'**
  String productName(String type);

  /// No description provided for @productUnits.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{Сколько сигарет} sticks{Сколько стиков} disposable{Сколько одноразок} liquid{Сколько флаконов} other{}}'**
  String productUnits(String type);

  /// No description provided for @productPackPrice.
  ///
  /// In ru, this message translates to:
  /// **'{type, select, cigarettes{Цена пачки, ₽} sticks{Цена пачки стиков, ₽} disposable{Цена одноразки, ₽} liquid{Цена флакона, ₽} other{}}'**
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
