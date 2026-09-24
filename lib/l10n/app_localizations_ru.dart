// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Zero';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabHealth => 'Здоровье';

  @override
  String get tabKnowledge => 'Знания';

  @override
  String get tabLeaderboard => 'Рейтинг';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get comingSoon => 'Скоро здесь что-то появится';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get done => 'Готово';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get onbWelcomeTitle => 'Привет! Это начало свободы';

  @override
  String get onbWelcomeText =>
      'Я помогу пройти путь без сигарет маленькими шагами: покажу, как восстанавливается организм, сколько денег остаётся в кармане, и поддержу, когда будет тяжело.\n\nСначала пара вопросов — это займёт минуту.';

  @override
  String get onbStart => 'Начнём';

  @override
  String get onbProductsTitle => 'Что вы курите?';

  @override
  String get onbProductsHint => 'Можно выбрать несколько';

  @override
  String productName(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'cigarettes': 'Сигареты',
      'sticks': 'Стики (IQOS, glo и др.)',
      'disposable': 'Одноразовые вейпы',
      'liquid': 'Вейп',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String productUnits(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'cigarettes': 'Сколько сигарет',
      'sticks': 'Сколько стиков',
      'disposable': 'Сколько одноразок',
      'liquid': 'Сколько флаконов жидкости',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String productPackPrice(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'cigarettes': 'Цена пачки, ₽',
      'sticks': 'Цена пачки стиков, ₽',
      'disposable': 'Цена одноразки, ₽',
      'liquid': 'Цена флакона жидкости, ₽',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get productUnitsPerPack => 'Штук в пачке';

  @override
  String periodName(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'day': 'в день',
      'week': 'в неделю',
      'month': 'в месяц',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get onbConsumptionTitle => 'Сколько и почём';

  @override
  String get onbConsumptionHint =>
      'Это нужно, чтобы считать сэкономленные деньги. Примерно — тоже хорошо.';

  @override
  String get onbQuitTitle => 'Когда вы бросили?';

  @override
  String get onbQuitNow => 'Прямо сейчас';

  @override
  String get onbQuitEarlier => 'Раньше — укажу дату';

  @override
  String onbQuitChosen(String date) {
    return 'Бросил(а): $date';
  }

  @override
  String get onbQuitTimeHelp => 'Во сколько примерно?';

  @override
  String get onbQuitTimeUnknown => 'Не помню';

  @override
  String get onbFinish => 'Поехали!';

  @override
  String get invalidNumber => 'Введите число больше нуля';

  @override
  String homeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'дня',
      many: 'дней',
      few: 'дня',
      one: 'день',
    );
    return '$_temp0';
  }

  @override
  String unitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'года',
      many: 'лет',
      few: 'года',
      one: 'год',
    );
    return '$_temp0';
  }

  @override
  String unitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'месяца',
      many: 'месяцев',
      few: 'месяца',
      one: 'месяц',
    );
    return '$_temp0';
  }

  @override
  String unitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'недели',
      many: 'недель',
      few: 'недели',
      one: 'неделя',
    );
    return '$_temp0';
  }

  @override
  String homeTotal(String value) {
    return 'всего $value';
  }

  @override
  String get homeSavingsInfoTitle => 'Как считаем';

  @override
  String homeSavingsInfo(String perDay, String perHour) {
    return 'По вашим ответам вы тратили примерно $perDay ₽ в день — это около $perHour ₽ в час. Каждая минута без курения добавляет деньги в копилку.';
  }

  @override
  String homeSmokeFreeSince(String date) {
    return 'без курения с $date';
  }

  @override
  String homeLevel(int level) {
    return 'Уровень $level';
  }

  @override
  String homeXpToNext(int xp) {
    return '$xp XP до следующего уровня';
  }

  @override
  String get homeMaxLevel => 'Максимальный уровень — вы легенда!';

  @override
  String get homeMoneySaved => 'Сэкономлено';

  @override
  String get homeNotSmoked => 'Не выкурено';

  @override
  String money(String amount) {
    return '$amount ₽';
  }

  @override
  String unitsAvoided(String type, String count) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'cigarettes': '$count сиг.',
      'sticks': '$count стик.',
      'disposable': '$count одноразок',
      'liquid': '$count флак.',
      'other': '$count',
    });
    return '$_temp0';
  }

  @override
  String get homeNoAttemptTitle => 'Новая попытка';

  @override
  String get homeNoAttemptText =>
      'Каждая попытка делает вас сильнее. Опыт и значки остаются с вами.';

  @override
  String get homeStartAttempt => 'Начать с этой минуты';

  @override
  String get homeNextQuote => 'Следующая мысль';

  @override
  String get sosButton => 'SOS';

  @override
  String get sosTriggerTitle => 'Что сейчас происходит?';

  @override
  String get sosTriggerHint =>
      'Один тап — и я запомню, когда вас тянет сильнее всего';

  @override
  String get sosSkip => 'Пропустить';

  @override
  String triggerName(String trigger) {
    String _temp0 = intl.Intl.selectLogic(trigger, {
      'stress': 'Стресс',
      'alcohol': 'Алкоголь',
      'company': 'Компания',
      'coffee': 'Кофе',
      'afterMeal': 'После еды',
      'boredom': 'Скука',
      'ritual': 'Привычный момент',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String get sosBreatheIn => 'Вдох';

  @override
  String get sosHold => 'Задержка';

  @override
  String get sosBreatheOut => 'Выдох';

  @override
  String get sosWaveHint =>
      'Тяга — как волна: она нарастает и спадает за 3–5 минут. Просто продержитесь.';

  @override
  String get sosAnotherTip => 'Другой совет';

  @override
  String get sosResisted => 'Справился!';

  @override
  String sosResistedToast(int xp) {
    return 'Вы сильнее тяги! +$xp XP';
  }

  @override
  String durMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '$count минута',
    );
    return '$_temp0';
  }

  @override
  String durHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '$count час',
    );
    return '$_temp0';
  }

  @override
  String durDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String durWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели',
      many: '$count недель',
      few: '$count недели',
      one: '$count неделя',
    );
    return '$_temp0';
  }

  @override
  String durMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца',
      many: '$count месяцев',
      few: '$count месяца',
      one: '$count месяц',
    );
    return '$_temp0';
  }

  @override
  String durYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года',
      many: '$count лет',
      few: '$count года',
      one: '$count год',
    );
    return '$_temp0';
  }

  @override
  String get healthTabRecovery => 'Восстановление';

  @override
  String get healthTabAchievements => 'Достижения';

  @override
  String get healthDisclaimer =>
      'Сроки примерные и основаны на данных ACS, CDC и ВОЗ. Организм у каждого восстанавливается по-своему. Приложение не заменяет консультацию врача.';

  @override
  String get healthReached => 'Уже произошло';

  @override
  String healthRemaining(String time) {
    return 'Осталось: $time';
  }

  @override
  String get healthNoAttempt =>
      'Начните новую попытку на главном экране — и отсчёт восстановления пойдёт заново.';

  @override
  String healthSource(String source) {
    return 'Источник: $source';
  }

  @override
  String achUnlockedCount(int unlocked, int total) {
    return 'Открыто $unlocked из $total';
  }

  @override
  String achUnlockedAt(String date) {
    return 'Получено $date';
  }

  @override
  String achHowTo(String condition) {
    return 'Как получить: $condition';
  }

  @override
  String achCondSmokeFree(String time) {
    return 'продержаться без курения: $time';
  }

  @override
  String achCondMoney(String amount) {
    return 'сэкономить $amount ₽';
  }

  @override
  String achCondCravings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'справиться с тягой $count раза',
      many: 'справиться с тягой $count раз',
      few: 'справиться с тягой $count раза',
      one: 'справиться с тягой $count раз',
    );
    return '$_temp0';
  }

  @override
  String achCondArticles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'прочитать $count статьи',
      many: 'прочитать $count статей',
      few: 'прочитать $count статьи',
      one: 'прочитать $count статью',
    );
    return '$_temp0';
  }

  @override
  String achCondAttempts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'начать $count попытки',
      many: 'начать $count попыток',
      few: 'начать $count попытки',
      one: 'начать первую попытку',
    );
    return '$_temp0';
  }

  @override
  String achCondComeback(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'вернуться после срыва $count раза',
      many: 'вернуться после срыва $count раз',
      few: 'вернуться после срыва $count раза',
      one: 'вернуться после срыва',
    );
    return '$_temp0';
  }

  @override
  String achCondUnits(String count) {
    return 'не выкурить $count шт.';
  }

  @override
  String tierName(String tier) {
    String _temp0 = intl.Intl.selectLogic(tier, {
      'bronze': 'Бронза',
      'silver': 'Серебро',
      'gold': 'Золото',
      'other': 'Платина',
    });
    return '$_temp0';
  }

  @override
  String get achCelebrateTitle => 'Новое достижение!';

  @override
  String get achCelebrateOk => 'Ура!';

  @override
  String achNewMany(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count достижения',
      many: 'Открыто $count достижений',
      few: 'Открыто $count достижения',
      one: 'Открыто $count достижение',
    );
    return '$_temp0 — загляните во вкладку «Здоровье»';
  }

  @override
  String get settingsAppearance => 'Цветовой тон';

  @override
  String themeModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'system': 'Системный',
      'light': 'Светлый',
      'dark': 'Тёмный',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get settingsLargeText => 'Крупный текст';

  @override
  String get settingsLargeTextHint => 'Увеличивает текст во всём приложении';

  @override
  String get settingsData => 'Мои данные';

  @override
  String get settingsReset => 'Полный сброс';

  @override
  String get settingsResetHint =>
      'Удалить все данные и начать с первого экрана';

  @override
  String get settingsResetConfirmTitle => 'Удалить все данные?';

  @override
  String get settingsResetConfirmText =>
      'Попытки, достижения, дневник и ответы о курении будут удалены навсегда. Приложение начнётся заново с первого экрана.';

  @override
  String get settingsResetConfirm => 'Удалить всё';
}
