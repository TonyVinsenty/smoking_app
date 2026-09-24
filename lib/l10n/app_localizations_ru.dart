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
  String get homeSavingsMore => 'Подробнее';

  @override
  String get savingsToday => 'Сегодня';

  @override
  String get savingsWeek => 'На этой неделе';

  @override
  String get savingsMonth => 'В этом месяце';

  @override
  String get savingsTotal => 'Всего';

  @override
  String get savingsPeriodsHint =>
      'Неделя считается с понедельника, месяц — с 1-го числа.';

  @override
  String savingsForecast(String perMonth, String perYear) {
    return 'Если так продолжать — около $perMonth в месяц и $perYear в год.';
  }

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
  String get sosBreatheOut => 'Выдох';

  @override
  String get sosChangeExercise => 'Упражнение можно сменить';

  @override
  String get sosPickExercise => 'Выберите упражнение';

  @override
  String sosExerciseName(String exercise) {
    String _temp0 = intl.Intl.selectLogic(exercise, {
      'breathing': 'Спокойное дыхание',
      'countdown': 'Отсчёт 10 → 0',
      'grounding': 'Заземление 5-4-3-2-1',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String sosExerciseDesc(String exercise) {
    String _temp0 = intl.Intl.selectLogic(exercise, {
      'breathing': 'Вдох на 4 счёта, выдох на 6. Без задержек — просто следите за кругом.',
      'countdown':
          'Крупные числа от 10 до 0. Ничего делать не нужно — просто смотрите.',
      'grounding': 'Пять простых шагов, чтобы вернуться в «здесь и сейчас».',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sosCountdownHint => 'Просто смотрите на числа';

  @override
  String get sosCountdownDone => 'Вот и всё. Можно ещё раз.';

  @override
  String get sosAgain => 'Ещё раз';

  @override
  String sosGroundStep(String step) {
    String _temp0 = intl.Intl.selectLogic(step, {
      'see': 'Найдите глазами 5 вещей вокруг',
      'hear': 'Прислушайтесь: 4 звука, которые вы слышите',
      'touch': 'Коснитесь 3 предметов и почувствуйте их',
      'smell': 'Уловите 2 запаха',
      'taste': 'Заметьте 1 вкус',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get sosGroundHint => 'Не спешите. Можно назвать про себя.';

  @override
  String get sosNext => 'Дальше';

  @override
  String get sosGroundDone => 'Вы здесь и сейчас. Вы справляетесь.';

  @override
  String get sosWaveHint =>
      'Тяга — как волна: она нарастает и спадает за 3–5 минут. Просто продержитесь.';

  @override
  String get sosAnotherTip => 'Другой совет';

  @override
  String get sosResisted => 'Тяга прошла!';

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
  String get settingsSos => 'SOS';

  @override
  String get settingsSosExercise => 'Упражнение по умолчанию';

  @override
  String get settingsAttempt => 'Моя попытка';

  @override
  String get relapseButton => 'Я закурил(а)';

  @override
  String get relapseButtonHint => 'Без упрёков: отметим и начнём заново';

  @override
  String get historyButton => 'История попыток';

  @override
  String historyButtonHint(String best) {
    return 'Рекорд: $best';
  }

  @override
  String get relapseConfirmTitle => 'Отметить срыв?';

  @override
  String get relapseConfirmText =>
      'Текущий отсчёт остановится. Опыт, уровень и награды останутся с вами.';

  @override
  String get relapseConfirm => 'Да, отметить';

  @override
  String get relapseTitle => 'Дневник без упрёков';

  @override
  String get relapseIntro =>
      'Спасибо, что отметили честно. Срыв — не провал, а подсказка: он показывает, что именно сработало против вас.';

  @override
  String get relapseWhen => 'Когда это было?';

  @override
  String get relapseJustNow => 'Только что';

  @override
  String get relapsePickTime => 'Выбрать время';

  @override
  String get relapseTrigger => 'Что к этому привело?';

  @override
  String get relapseQ1 => 'Что произошло?';

  @override
  String get relapseQ2 => 'Что могло бы помочь?';

  @override
  String get relapseQ3 => 'Что попробую в следующий раз?';

  @override
  String get relapseOptional => 'Всё необязательно — можно просто сохранить.';

  @override
  String get relapseSave => 'Сохранить';

  @override
  String get relapseDoneTitle => 'Это часть пути';

  @override
  String relapseDoneText(String duration, String best) {
    return 'Без курения вы продержались $duration. Ваш рекорд — $best. Опыт, уровень и награды остаются с вами, а следующая попытка начнётся уже с этим знанием.';
  }

  @override
  String get relapseStartNow => 'Начать новую попытку сейчас';

  @override
  String get relapseLater => 'Начать новую попытку позже';

  @override
  String get historyTitle => 'История попыток';

  @override
  String get historyBest => 'Рекорд';

  @override
  String get historyTotal => 'Всего без курения';

  @override
  String get historyCount => 'Попыток';

  @override
  String historyAttempt(int n) {
    return 'Попытка $n';
  }

  @override
  String get historyNow => 'идёт сейчас';

  @override
  String historyBadges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count награды',
      many: '$count наград',
      few: '$count награды',
      one: '$count награда',
    );
    return '$_temp0';
  }

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

  @override
  String get productsEditTitle => 'Что вы курите';

  @override
  String get newAttemptTitle => 'Настройки курения';

  @override
  String get newAttemptText =>
      'Оставить прошлые настройки? По ним считаются сэкономленные деньги. Если за это время вы перешли на другое — измените.';

  @override
  String get newAttemptKeep => 'Оставить';

  @override
  String get newAttemptChange => 'Изменить';

  @override
  String productSummary(
    String amount,
    String period,
    String price,
    String type,
  ) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'cigarettes': 'за пачку',
      'sticks': 'за пачку',
      'disposable': 'за штуку',
      'liquid': 'за флакон',
      'other': '',
    });
    return '$amount $period · $price ₽ $_temp0';
  }

  @override
  String knowledgeProgress(int read, int total) {
    return 'Прочитано $read из $total';
  }

  @override
  String get knowledgeAll => 'Все';

  @override
  String articleCategory(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'addiction': 'Зависимость',
      'health': 'Здоровье',
      'practice': 'Практика',
      'myths': 'Мифы',
      'vape': 'Вейпы и IQOS',
      'money': 'Деньги',
      'other': 'Другое',
    });
    return '$_temp0';
  }

  @override
  String articleMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get articleRead => 'Прочитано';

  @override
  String get articleReadSnack => 'Статья прочитана';

  @override
  String get articleNext => 'Следующая статья';

  @override
  String get articleDisclaimer =>
      'Статья носит справочный характер и не заменяет консультацию врача.';
}
