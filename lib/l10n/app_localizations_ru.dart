// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Не курю';

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
      'liquid': 'Жидкость для вейпа',
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
      'liquid': 'Сколько флаконов',
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
      'liquid': 'Цена флакона, ₽',
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
  String get onbFinish => 'Поехали!';

  @override
  String get invalidNumber => 'Введите число больше нуля';
}
