// Content of the design review: screenshots, issues, mockups, animations, competitors.

const CAPTIONS = {
  '01_home': 'Главная', '02_home_scrolled': 'Главная, ниже', '03_savings_sheet': 'Окно «Подробнее» об экономии',
  '04_achievements': 'Достижения', '05_achievements_scrolled': 'Достижения, ниже', '05b_achievements_collapsed': 'Достижения: всё свёрнуто',
  '05c_achievements_group': 'Достижения: группа «Знания»', '06_badge_card': 'Карточка полученного значка', '06b_badge_locked': 'Карточка закрытого значка',
  '06c_badge_any': 'Ещё одна карточка значка', '07_sos_reason': 'SOS: выбор повода', '08_sos_ex1': 'SOS: спокойное дыхание (вдох)',
  '08b_sos_ex1_exhale': 'SOS: спокойное дыхание (выдох)', '08c_sos_picker': 'SOS: выбор упражнения', '09_sos_ex2': 'SOS: отсчёт 10 → 0',
  '10_sos_ex3': 'SOS: заземление 5-4-3-2-1', '11_craving_map': 'Карта тяги', '12_craving_map2': 'Карта тяги, ниже', '12b_craving_map3': 'Карта тяги, конец',
  '13_health_path': 'Здоровье: Этапы (Тропа)', '13b_health_path_all': 'Этапы: фильтр «Все»', '14_health_facts': 'Здоровье: Факты', '14b_health_facts2': 'Факты, ниже',
  '15_health_normal': 'Здоровье: Что нормально', '15b_health_normal2': 'Что нормально, ниже', '16_health_body': 'Здоровье: Карта тела',
  '17_body_sheet': 'Шторка плитки «Лёгкие»', '18_health_notinhaled': 'Здоровье: Не вдохнули', '18b_health_notinhaled2': 'Не вдохнули, ниже',
  '19_health_diary': 'Здоровье: Дневник', '19b_health_diary2': 'Дневник, ниже', '20_knowledge': 'Знания', '21_article': 'Статья', '21b_article2': 'Статья, ниже',
  '22_leaderboard': 'Рейтинг', '23_settings': 'Настройки', '24_settings2': 'Настройки, ниже', '25_history': 'История попыток', '25b_history2': 'История, ниже',
  '26_relapse_step1': '«Я закурил(а)»: первый шаг', '27_habits': 'Мои привычки: шаг 1', '27b_habits2': 'Мои привычки: шаг 2', '28_toast': 'Всплывающее сообщение',
};
const SHOTS = {
  l: '01_home 02_home_scrolled 03_savings_sheet 04_achievements 05_achievements_scrolled 05b_achievements_collapsed 05c_achievements_group 06_badge_card 06b_badge_locked 07_sos_reason 08_sos_ex1 08b_sos_ex1_exhale 08c_sos_picker 09_sos_ex2 10_sos_ex3 11_craving_map 12_craving_map2 12b_craving_map3 13_health_path 13b_health_path_all 14_health_facts 14b_health_facts2 15_health_normal 15b_health_normal2 16_health_body 17_body_sheet 18_health_notinhaled 18b_health_notinhaled2 19_health_diary 19b_health_diary2 20_knowledge 21_article 21b_article2 22_leaderboard 23_settings 24_settings2 25_history 25b_history2 26_relapse_step1 27_habits 27b_habits2 28_toast',
  d: '01_home 02_home_scrolled 03_savings_sheet 04_achievements 05_achievements_scrolled 06_badge_card 06c_badge_any 07_sos_reason 08_sos_ex1 08c_sos_picker 09_sos_ex2 10_sos_ex3 11_craving_map 12_craving_map2 12b_craving_map3 13_health_path 14_health_facts 14b_health_facts2 15_health_normal 15b_health_normal2 16_health_body 17_body_sheet 18_health_notinhaled 18b_health_notinhaled2 19_health_diary 19b_health_diary2 20_knowledge 21_article 21b_article2 22_leaderboard 23_settings 24_settings2 25_history 25b_history2 26_relapse_step1 27_habits 27b_habits2 28_toast',
  b: '01_home 02_home_scrolled 04_achievements 07_sos_reason 08_sos_ex1 11_craving_map 13_health_path 16_health_body 18_health_notinhaled 19_health_diary 20_knowledge 21_article 23_settings 24_settings2',
};

// Small line icons (24×24, stroke = currentColor) used inside the mockups.
const GLYPHS = {
  wind: 'M3 8h10a3 3 0 1 0-3-3M3 12h15a3 3 0 1 1-3 3M3 16h7',
  trophy: 'M7 4h10v4a5 5 0 0 1-10 0zM7 5H4v2a3 3 0 0 0 3 3M17 5h3v2a3 3 0 0 1-3 3M12 13v4M8 20h8M10 17h4v3h-4z',
  wallet: 'M4 7h15a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1zM4 7l11-3v3M16 13h2',
  nosmoke: 'M3 14h11v3H3zM16 14h2v3h-2zM19.5 14h1.5v3h-1.5zM16 11c0-2 2-2 2-4M4 4l16 16',
  heart: 'M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z',
  lungs: 'M12 4v8M12 12c-1 1-2 1.5-3 2M12 12c1 1 2 1.5 3 2M9.5 7C6.5 7 4 11 4 15c0 3 2 4 3.5 4S10 18 10 15V9M14.5 7C17.5 7 20 11 20 15c0 3-2 4-3.5 4S14 18 14 15V9',
  leaf: 'M5 19C5 10 10 5 19 5c0 9-5 14-14 14zM5 19l7-7',
  star: 'M12 3l2.6 5.6 6 .7-4.5 4.1 1.2 6L12 16.4 6.7 19.4l1.2-6L3.4 9.3l6-.7z',
  path: 'M6 20c3-1 3-5 6-6s5-3 5-6M17 4.5a1.5 1.5 0 1 0 0 .1M6 20h.1',
  book: 'M4 5a2 2 0 0 1 2-2h13v15H6a2 2 0 0 0-2 2zM4 20V5M8 7h7',
  drop: 'M12 3s6 7 6 11a6 6 0 0 1-12 0c0-4 6-11 6-11z',
  bolt: 'M13 2 4 14h7l-1 8 9-12h-7z',
  shield: 'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z',
  brain: 'M9 4a3 3 0 0 0-3 3 3 3 0 0 0-2 5 3 3 0 0 0 3 5 3 3 0 0 0 6 0V6a2 2 0 0 0-4-2zM15 4a3 3 0 0 1 3 3 3 3 0 0 1 2 5 3 3 0 0 1-3 5',
  taste: 'M8 3v8M5 3v5a3 3 0 0 0 6 0V3M8 11v10M17 3c-2 0-3 3-3 6s1 4 3 4v8',
  check: 'M5 12.5l4.5 4.5L19 7',
  calendar: 'M4 6h16v14H4zM4 10h16M8 3v4M16 3v4',
  bell: 'M6 16V11a6 6 0 0 1 12 0v5l2 2H4zM10 20a2 2 0 0 0 4 0',
  palette: 'M12 3a9 9 0 0 0 0 18c1.5 0 2-1 1.5-2s0-2 1.5-2H18a3 3 0 0 0 3-3c0-6-4-11-9-11zM7.5 12h.1M10 7.5h.1M15 7.5h.1',
  history: 'M4 12a8 8 0 1 0 2.5-5.8M4 4v4h4M12 8v4l3 2',
  sliders: 'M4 7h10M18 7h2M4 17h4M12 17h8M14 5v4M8 15v4',
  pen: 'M4 20h4L19 9l-4-4L4 16zM13 7l4 4',
  podium: 'M9 9h6v12H9zM3 14h6v7H3zM15 12h6v9h-6z',
  lock: 'M6 11h12v9H6zM8.5 11V8a3.5 3.5 0 0 1 7 0v3',
  refresh: 'M20 11a8 8 0 1 0-2 5.3M20 5v6h-6',
};
const g = (name, extra = '') =>
  `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" ${extra}><path d="${GLYPHS[name]}"/></svg>`;
const ring = (size, r, frac, color, track, width = 4) => {
  const c = 2 * Math.PI * r;
  return `<svg viewBox="0 0 ${size} ${size}" aria-hidden="true"><circle cx="${size / 2}" cy="${size / 2}" r="${r}" fill="none" stroke="${track}" stroke-width="${width}"/>
    <circle cx="${size / 2}" cy="${size / 2}" r="${r}" fill="none" stroke="${color}" stroke-width="${width}" stroke-linecap="round" stroke-dasharray="${(c * frac).toFixed(1)} ${c.toFixed(1)}"/></svg>`;
};

// ── Issues ────────────────────────────────────────────────────────────────
// p: 1 important · 2 desirable · 3 minor; e: effort; bug: works incorrectly; shots: [file, vertical crop position %].
const ISSUES = [
  { p: 1, e: 'Быстро', bug: true, title: 'Карта тяги: полоска вылезает за карточку',
    text: 'Полоска «Повод не указан» длиннее карточки и уходит за правый край экрана. Длину полосок сейчас считают от первой строки, а «не указан» бывает больше неё.',
    fix: 'Считать длину от самой длинной полоски. «Повод не указан» ставить последним и показывать приглушённым цветом.',
    shots: [['l_12b_craving_map3', 6]] },
  { p: 1, e: 'Быстро', title: 'Кнопка SOS закрывает текст',
    text: 'Почти на каждом экране кнопка лежит поверх последних строк: в Дневнике под ней прячутся цифры «3 → 4», в «Что нормально» — конец совета. Она полупрозрачная, поэтому текст под ней ещё и просвечивает. В тёмной теме кнопка почти сливается с карточками.',
    fix: 'Раньше вы просили сделать её полупрозрачной, чтобы она меньше мешала. Предлагаю другой способ: при прокрутке вниз кнопка сворачивается в небольшой кружок, а под ней в каждом списке остаётся пустое место. Тогда её можно сделать плотной, и текст не будет просвечивать. Живой пример — в разделе «Анимации».',
    shots: [['l_19_health_diary', 96], ['l_15_health_normal', 96], ['d_18_health_notinhaled', 96]] },
  { p: 1, e: 'Средне', title: 'С крупным шрифтом ломаются переключатели',
    text: 'Кнопки разделов «Здоровья» уменьшают надписи каждая по-своему: «Этапы» крупно, «Что нормально» мелко. В переключателях слова рвутся посередине: «Пройде|нные», «Ближай|шие», «Кровообра|щение». На Карте тяги «Вечер» обрезается до «Вече». На главной «15757 XP» налезает на название уровня, а дата под таймером уезжает влево.',
    fix: 'Надписи переносятся только целыми словами, у всех кнопок один размер. Если места не хватает, переключатель выстраивается в столбик. Для длинных слов вроде «Кровообращение» добавить мягкие переносы. Иконки тоже немного растут вместе со шрифтом.',
    shots: [['b_13_health_path', 4], ['b_16_health_body', 40], ['b_11_craving_map', 92]] },
  { p: 1, e: 'Средне', title: 'Значки не выглядят ценной наградой',
    text: 'Полученный «обычный» значок серый и выглядит как закрытый. Цвета редкости — яркие стандартные зелёный, синий и фиолетовый со свечением, будто из другого приложения. В тёмной теме свечение становится «неоновым». Зелёные подписи под значками плохо читаются (контраст около 3:1 при норме 4,5:1). Закрытые значки ничего не говорят о том, сколько до них осталось.',
    fix: 'Сделать медаль с ободком цвета редкости. Цвета смягчить в сторону бирюзы, редкость видна по ободку, без неона. Подписи под значками — обычным цветом текста. У закрытых значков — контур и тонкое кольцо прогресса «18 из 200 дней». Это мотивирует сильнее, чем серый кружок. Макет — в «Было → стало».',
    shots: [['l_04_achievements', 30], ['l_05_achievements_scrolled', 50], ['d_06_badge_card', 80]] },
  { p: 1, e: 'Средне', title: 'Девять разных «крупных чисел» и нет шкалы шрифтов',
    text: 'Одна и та же роль на разных экранах выглядит по-разному. «7 397 ₽» тонкое, «2 одноразок» жирное, «175 дней» в Истории снова тонкое, «8 дней» в Фактах жирное бирюзовое. Заголовки тем в «Знаниях» — самый крупный текст во всём приложении, крупнее даже заголовков статей.',
    fix: 'Ввести 7 ролей текста и придерживаться их везде: главное число экрана (56, жирный), показатель (30, полужирный, единица мельче рядом), заголовок раздела (20), заголовок карточки (17), основной текст (16), надпись над текстом (13), подпись или источник (12). Числа набирать отдельным шрифтом, см. раздел «Шрифт».',
    shots: [['l_01_home', 52], ['l_25_history', 12], ['l_20_knowledge', 55]] },
  { p: 1, e: 'Быстро', title: 'Главная: карточки уезжают под кнопку «Достижения»',
    text: 'При прокрутке верх карточек обрезается резкой линией прямо под кнопкой. Выглядит как ошибка.',
    fix: 'Сверху сделать плавное затухание, как лёгкий туман: карточки мягко растворяются под кнопкой. На кнопке можно показать число значков: «Достижения · 43».',
    shots: [['l_02_home_scrolled', 4]] },
  { p: 1, e: 'Средне', title: 'Экран SOS: мелочи, которые видны в трудную минуту',
    text: 'С крупным шрифтом совет обрезается (у рамки фиксированная высота). С обычным шрифтом в той же рамке много пустоты. В «Отсчёте» цифры 10 и 9 на мгновение накладываются друг на друга. Название упражнения стоит по центру и сдвигается при каждой смене. Значок на кнопке «Тяга прошла!» (две стрелки) непонятен.',
    fix: 'Рамка совета растёт по тексту, но не меньше нужной высоты, поэтому круг не прыгает. Старая цифра уходит вверх раньше, чем приходит новая. Название упражнения стоит слева, «Сменить» справа. На кнопке «Тяга прошла!» — галочка, сама кнопка повыше.',
    shots: [['b_08_sos_ex1', 85], ['l_09_sos_ex2', 30], ['l_08_sos_ex1', 10]] },
  { p: 2, e: 'Средне', title: 'Мятный цвет везде, поэтому ничего не выделяет',
    text: 'Мятным залиты главный блок, выбранная вкладка, полоски прогресса, плитки, счётчики. На экране «Не вдохнули» выбранная кнопка и две карточки под ней одного цвета. Обычные карточки серо-зелёные и рядом с мятным выглядят «грязными» или выключенными.',
    fix: 'Мятный — только для одного главного блока на экране и для «Вы здесь». Обычные карточки в светлой теме — белые с еле заметной тенью, в тёмной — чуть светлее фона. Советы и подсказки — всегда один и тот же спокойный цвет (сейчас совет на Карте тяги и в SOS разного цвета).',
    shots: [['l_18_health_notinhaled', 25], ['l_01_home', 55], ['l_12b_craving_map3', 45]] },
  { p: 2, e: 'Средне', title: 'Пять разных видов переключателей',
    text: 'Разделы «Здоровья» — шесть отдельных кнопок. Периоды на Карте тяги и тема в Настройках — сегменты с рамкой. Темы в «Знаниях» — фильтры с галочкой. Поводы в SOS — прямоугольные кнопки. В Истории надписи «17 наград» и «Стресс» выглядят как кнопки, но не нажимаются.',
    fix: 'Правило: выбор одного из 2–4 — сегменты, фильтр по темам — фильтры, надписи только для чтения — плоские метки без рамки. Сетку 2×3 в «Здоровье» вы одобрили, её оставляю, но собираю в одну общую плашку с иконками, чтобы она читалась как меню, а не как шесть кнопок.',
    shots: [['l_13_health_path', 4], ['l_20_knowledge', 15], ['l_25_history', 30]] },
  { p: 2, e: 'Быстро', title: 'Карта тела: заливка похожа на сбой',
    text: 'Плитка заполняется снизу, и граница заливки режет подпись пополам. «2 из 5» читается, а сама картинка — нет.',
    fix: 'Плитка остаётся светлой, прогресс показывают точки (●●○○○). Когда все этапы плитки пройдены, она становится мятной с галочкой.',
    shots: [['l_16_health_body', 45], ['d_16_health_body', 45]] },
  { p: 2, e: 'Средне', title: 'График Дневника трудно читать',
    text: 'Подписи по оси «12 окт. — 12 окт.», шкалы нет, две линии лежат друг на друге. Цвета (синий, оранжевый, розовый) не из палитры приложения.',
    fix: 'Четыре маленьких графика, по одному на каждый вопрос, со шкалой 1–5 и подписью «было → стало». Цвета взять из палитры. Пока записей меньше двух, вместо графика показывать подсказку.',
    shots: [['l_19b_health_diary2', 30]] },
  { p: 2, e: 'Быстро', title: 'История попыток: метки похожи на кнопки',
    text: '«17 наград» и «Стресс» в белых рамках, а в тёмной теме это тёмные «дырки». Текущая попытка в тёмной теме мутно-бирюзовая. «Всего без курения» переносится на две строки.',
    fix: 'Плоские метки без рамки. Текущая попытка — обычная карточка с бирюзовой обводкой и надписью «Сейчас». Вместо «Всего без курения» — «Всего».',
    shots: [['l_25_history', 30], ['d_25_history', 30]] },
  { p: 2, e: 'Быстро', title: 'Настройки: переключатель рядом с галочкой',
    text: '«Этапы восстановления» включаются переключателем, а «Напоминать о Дневнике» — галочкой. «Как часто» и «Во сколько» сдвинуты не по линии текста. Иконки многострочных пунктов стоят посередине, а не напротив заголовка.',
    fix: 'Везде переключатели, отступы по одной линии, иконки напротив первой строки. «Цветовой тон» переименовать в «Тема оформления» и перенести в конец, в раздел «Оформление».',
    shots: [['l_23_settings', 55], ['l_24_settings2', 40]] },
  { p: 2, e: 'Быстро', title: '«Рейтинг» — пустая вкладка с одной строкой',
    text: '«Скоро здесь что-то появится» посреди пустого экрана подрывает доверие: кажется, что приложение недоделано.',
    fix: 'Нормальное пустое состояние: картинка, честное объяснение «Здесь появится рейтинг с друзьями по коду. Всё анонимно и по желанию», список того, что будет. Второй вариант — спрятать вкладку до фазы 3. Решать вам.',
    shots: [['l_22_leaderboard', 40]] },
  { p: 2, e: 'Средне', title: 'Иконки внутри приложения: залитые и контурные вперемешку',
    text: 'Копилка, кубок, иконки групп и плиток залитые. Подсказки, галочки и настройки контурные. Логики в этом нет. Некоторые иконки непонятны: облако с чертой у одноразок, «искорки» у Карты тяги.',
    fix: 'Правило: контурные иконки по умолчанию, залитые — только выбранное или полученное. Заменить непонятные иконки на более ясные.',
    shots: [['l_01_home', 45], ['l_18_health_notinhaled', 22]] },
  { p: 3, e: 'Быстро', title: 'Числа и проценты',
    text: '«15757 XP» написано без пробела, хотя деньги везде с пробелом («7 397 ₽»). «1 из 6 (16%)» на самом деле 16,7%, и большинство людей ожидают увидеть 17%.',
    fix: '«15 757 XP». Проценты округлять обычным образом, но 100% показывать только когда всё действительно открыто.',
    shots: [['l_01_home', 75], ['l_05b_achievements_collapsed', 40]] },
  { p: 3, e: 'Быстро', title: 'Мои привычки: пустота и обрезанная подпись',
    text: 'Первый шаг висит посередине экрана, над ним много пустого места. Подпись «Штук в пач…» обрезана. Кнопки «в день / в неделю / в месяц» уже полей ввода.',
    fix: 'Содержимое прижать к верху. Подпись «В пачке, шт.». Кнопки на всю ширину.',
    shots: [['l_27_habits', 40], ['l_27b_habits2', 75]] },
  { p: 3, e: 'Быстро', title: 'Маленькие места для нажатия',
    text: '«Подробнее ›» и значок ⓘ на главной — около 22 dp в высоту. Рекомендуемый минимум 48 dp, иначе легко промахнуться пальцем.',
    fix: 'Сделать нажимаемой всю половину карточки «Сэкономлено».',
    shots: [['l_01_home', 46]] },
];

// ── Before → after mockups ────────────────────────────────────────────────
const BA = [
  {
    title: 'Главная', shot: 'l_01_home', crop: [9 / 16, 18],
    why: [
      'Карточки белые и «приподнятые», мятный остаётся только у главного блока.',
      'Под таймером видно, сколько до следующего этапа. Это связывает главную с «Тропой».',
      'Уровень в кольце прогресса, «15 757 XP» с пробелом.',
      'Сверху мягкое затухание вместо резкого края; на кнопке видно число значков.',
    ],
    after: () => `<div class="mock">
      <div class="m-scrim"></div>
      <span class="m-pill" style="position:relative;z-index:2">${g('trophy', 'width="16" height="16"')} Достижения · 43</span>
      <div class="m-hero">
        <div class="big"><div><b>2</b><span>недели</span></div><div><b>4</b><span>дня</span></div></div>
        <div class="clock">00:15:32</div>
        <div style="font-size:12px;font-weight:500">18 дней без курения · с 24 сентября</div>
        <div class="m-progress"><div style="display:flex;justify-content:space-between;gap:8px"><span>До этапа «Кашель отступает»</span><b>12 дн.</b></div><div class="m-track"><i></i></div></div>
      </div>
      <div class="m-row">
        <div class="m-card"><span class="m-ico">${g('wallet')}</span><span class="m-label">Сэкономлено</span><span class="m-value num">7 397 ₽</span><span class="m-link">Подробнее ›</span></div>
        <div class="m-card"><span class="m-ico">${g('nosmoke')}</span><span class="m-label">Не выкурено</span><span class="m-value num">180 сиг.</span><span class="m-label">и 2 одноразки</span></div>
      </div>
      <div class="m-card m-level">
        <div class="ring">${ring(52, 23, 0.96, 'var(--a-primary)', 'var(--a-high)', 5)}<b class="num">22</b></div>
        <div><span class="m-label">Уровень 22 · 15 757 XP</span><div style="font-weight:700;font-size:15px">Ясность и энергия</div><span class="m-label">43 XP до следующего уровня</span></div>
      </div>
    </div>`,
  },
  {
    title: 'Здоровье: разделы', shot: 'l_13_health_path', crop: [1, 0],
    why: [
      'Сетка 2×3 остаётся, как вы одобрили, но собрана в одну плашку с иконками и читается как меню.',
      'Выбранный раздел — насыщенный бирюзовый, остальные спокойные.',
      'С крупным шрифтом надписи переносятся целыми словами, размер у всех одинаковый.',
      'Сводка — белая карточка с крупным числом в том же стиле, что на главной.',
    ],
    after: () => `<div class="mock">
      <div class="m-tabs">
        <span class="on">${g('path')}Этапы</span><span>${g('star')}Факты</span><span>${g('leaf')}Что нормально</span>
        <span>${g('heart')}Карта тела</span><span>${g('nosmoke')}Не вдохнули</span><span>${g('calendar')}Дневник</span>
      </div>
      <div class="m-card">
        <span class="m-label">Пройдено этапов</span>
        <span class="m-value num">10 <span style="font-size:15px;font-weight:600;color:var(--a-on-var)">из 20</span></span>
        <div class="m-track" style="background:var(--a-high)"><i style="width:50%"></i></div>
        <span class="m-label">Следующий — через 2 недели: «Кашель отступает»</span>
      </div>
      <div class="m-seg"><span>Пройденные</span><span class="on">Ближайшие</span><span>Все</span></div>
    </div>`,
  },
  {
    title: 'Значки', shot: 'l_05_achievements_scrolled', crop: [1, 30],
    why: [
      'Полученный значок — медаль с ободком цвета редкости. Цвета смягчены, без неона.',
      'У закрытого значка кольцо показывает, сколько уже пройдено.',
      'Подписи обычным цветом текста, редкость видна по ободку.',
      'Тёплый «золотой» цвет только у легендарных — у самых ценных наград.',
    ],
    after: () => {
      const b = (cls, on, glyph, name, sub, frac) => `<div class="badge ${cls}"><div class="medal ${on ? 'on' : 'off'}">
          ${!on ? `<span class="prog">${ring(66, 31, frac, 'var(--r)', 'transparent', 3)}</span>` : ''}${g(glyph, 'class="g"')}</div>
          <span>${name}</span>${sub ? `<small>${sub}</small>` : ''}</div>`;
      return `<div class="mock"><div class="badges">
        ${b('r-common', true, 'star', 'Один час свободы', 'Обычное')}
        ${b('r-uncommon', true, 'leaf', 'Самое трудное позади', 'Необычное')}
        ${b('r-rare', true, 'trophy', 'Сто дней', 'Редкое')}
        ${b('r-epic', true, 'heart', 'Пять месяцев', 'Эпическое')}
        ${b('r-rare', false, 'star', 'Двести дней', '18 из 200 дней', 0.09)}
        ${b('r-legend', false, 'trophy', 'Год свободы', '18 из 365 дней', 0.05)}
      </div></div>`;
    },
  },
  {
    title: 'Карта тела', shot: 'l_16_health_body', crop: [1, 18],
    why: [
      'Точки показывают, сколько этапов плитки пройдено. Сразу видно «2 из 5».',
      'Готовая плитка мятная с галочкой — маленький праздник.',
      'Длинные слова переносятся правильно: «Кровообра-щение».',
    ],
    after: () => {
      const t = (glyph, name, done, total) => `<div class="tile ${done === total ? 'done' : ''}"><div class="top"><span class="m-ico" style="width:26px;height:26px">${g(done === total ? 'check' : glyph)}</span><span class="num" style="font-weight:700">${done} из ${total}</span></div>
        <b style="font-size:13px;hyphens:manual">${name}</b><div class="dots">${Array.from({ length: total }, (_, i) => `<i class="${i < done ? 'f' : ''}"></i>`).join('')}</div></div>`;
      return `<div class="mock"><div class="tiles">
        ${t('heart', 'Сердце', 2, 5)}${t('lungs', 'Лёгкие', 2, 4)}${t('drop', 'Кровообра&shy;щение', 3, 4)}
        ${t('bolt', 'Энергия', 0, 1)}${t('brain', 'Голова и настроение', 2, 3)}${t('taste', 'Вкус и запах', 1, 1)}
      </div></div>`;
    },
  },
  {
    title: 'Кнопка SOS', shot: 'l_19_health_diary', crop: [1, 100],
    why: [
      'В списке снизу всегда пустое место под кнопку, поэтому текст не прячется.',
      'При прокрутке вниз кнопка сворачивается в кружок, при прокрутке вверх снова показывает «SOS».',
      'Кнопка плотная, ничего не просвечивает. В тёмной теме она тоже хорошо видна.',
    ],
    after: () => `<div class="mock" style="min-height:300px;align-content:start">
      <div class="m-card"><span class="m-label">Как меняется самочувствие</span>
        <div class="m-bar"><div class="t"><span>Сон</span><b class="num">2 → 4</b></div></div>
        <div class="m-bar"><div class="t"><span>Дыхание</span><b class="num">2 → 4</b></div></div>
        <div class="m-bar"><div class="t"><span>Настроение</span><b class="num">3 → 4</b></div></div>
        <div class="m-bar"><div class="t"><span>Вкус и запах</span><b class="num">2 → 5</b></div></div>
      </div>
      <span class="m-label" style="padding:0 4px">Дневник хранится только на этом телефоне.</span>
      <div style="height:64px" aria-hidden="true"></div>
      <span class="m-fab round" aria-label="SOS">${g('wind')}</span>
    </div>`,
  },
  {
    title: 'Экран SOS', shot: 'l_08_sos_ex1', crop: [9 / 16, 12],
    why: [
      'Название упражнения слева, «Сменить» справа, ничего не прыгает.',
      'Вокруг круга идёт тонкое кольцо-таймер, внутри счёт 4…3…2…1.',
      'Совет в рамке по размеру текста. Кнопка с галочкой, повыше, удобно нажать.',
    ],
    after: () => `<div class="mock" style="justify-items:stretch">
      <div style="display:flex;justify-content:space-between;align-items:center"><b style="font-size:14px;display:flex;gap:6px;align-items:center">${g('wind', 'width="18" height="18"')} Спокойное дыхание</b><span class="m-link">Сменить</span></div>
      <p style="color:var(--a-on-var);text-align:center;font-size:12.5px">Тяга — как волна: она нарастает и спадает за 3–5 минут.</p>
      <div style="display:grid;place-items:center;padding:6px 0"><div class="breath" style="width:130px;height:130px">
        <span class="disc" style="transform:scale(.9)"></span>${ring(130, 60, 0.62, 'var(--a-primary)', 'color-mix(in srgb, var(--a-primary) 15%, transparent)', 4)}
        <span class="lab">Вдох<small class="num">3</small></span></div></div>
      <div class="m-card" style="background:var(--a-sc);box-shadow:none"><span>Погладьте кота, собаку или растение — переключите внимание на что-то живое.</span><span class="m-link" style="justify-self:end">Другой совет</span></div>
      <span style="background:var(--a-primary);color:var(--a-on-primary);border-radius:999px;padding:13px;text-align:center;font-weight:700;display:flex;gap:8px;justify-content:center;align-items:center">${g('check', 'width="18" height="18"')} Тяга прошла!</span>
    </div>`,
  },
  {
    title: 'Карта тяги: поводы', shot: 'l_12b_craving_map3', crop: [16 / 9, 3],
    why: [
      'Все полоски внутри карточки, длина от самой длинной.',
      '«Повод не указан» последним и приглушён: это не повод, а пропуск.',
      'Скруглённые полоски одной толщины, цифры ровно в столбик.',
    ],
    after: () => `<div class="mock"><div class="m-card"><b style="font-size:15px">Поводы</b><div class="m-bars">
      <div class="m-bar"><div class="t"><span>Стресс</span><b class="num">2</b></div><div class="b"><i class="no" style="width:33%"></i></div></div>
      <div class="m-bar"><div class="t"><span>Кофе</span><b class="num">1</b></div><div class="b"><i class="ok" style="width:16.6%"></i></div></div>
      <div class="m-bar"><div class="t"><span>После еды</span><b class="num">1</b></div><div class="b"><i class="ok" style="width:16.6%"></i></div></div>
      <div class="m-bar muted-row"><div class="t"><span>Повод не указан</span><b class="num">6</b></div><div class="b"><i class="ok" style="width:83%;opacity:.45"></i><i class="no" style="width:17%;opacity:.45"></i></div></div>
    </div></div></div>`,
  },
  {
    title: 'История попыток', shot: 'l_25_history', crop: [1, 12],
    why: [
      'Метки плоские: видно, что это информация, а не кнопки.',
      'Текущая попытка выделена обводкой и надписью «Сейчас», а не мутной заливкой.',
      '«Всего» помещается в одну строку.',
    ],
    after: () => `<div class="mock">
      <div class="m-hero" style="grid-template-columns:repeat(3,1fr);text-align:center">
        <div><b class="num" style="font:800 20px var(--app-num,'Manrope')">175</b><div style="font-size:11px">дней — рекорд</div></div>
        <div><b class="num" style="font:800 20px var(--app-num,'Manrope')">193</b><div style="font-size:11px">дня всего</div></div>
        <div><b class="num" style="font:800 20px var(--app-num,'Manrope')">5</b><div style="font-size:11px">попыток</div></div>
      </div>
      <div class="m-card" style="outline:2px solid var(--a-primary)"><span class="m-label" style="color:var(--a-primary);font-weight:700">СЕЙЧАС · ПОПЫТКА 5</span><span class="m-value num">18 дней</span><span class="m-label">с 24 сентября 2026</span>
        <div style="display:flex;gap:6px"><span style="background:var(--a-high);border-radius:8px;padding:3px 8px;font-size:11.5px;display:inline-flex;gap:4px;align-items:center">${g("trophy", "width=\"13\" height=\"13\"")} 17 наград</span></div></div>
      <div class="m-card"><span class="m-label">ПОПЫТКА 3</span><span class="m-value num" style="font-size:18px">2 минуты</span>
        <div style="display:flex;gap:6px"><span style="background:var(--a-high);border-radius:8px;padding:3px 8px;font-size:11.5px">1 награда</span><span style="background:var(--a-high);border-radius:8px;padding:3px 8px;font-size:11.5px">Стресс</span></div></div>
    </div>`,
  },
  {
    title: 'Настройки', shot: 'l_23_settings', crop: [1, 40],
    why: [
      'Пункты собраны в группы-карточки, как во всём приложении.',
      'Везде переключатели, отступы по одной линии.',
      '«Тема оформления» внизу, в разделе «Оформление».',
    ],
    after: () => `<div class="mock">
      <span class="m-h">Уведомления</span>
      <div class="m-list">
        <div class="m-li">${g('bell')}<span>Этапы восстановления<small>Редко и только по делу. Ночью не беспокоим</small></span><span class="sw"></span></div>
        <div class="m-li">${g('pen')}<span>Напоминать о Дневнике<small>Каждый день в 20:00</small></span><span class="sw"></span></div>
      </div>
      <span class="m-h">Моя попытка</span>
      <div class="m-list">
        <div class="m-li">${g('history')}<span>История попыток<small>Рекорд: 175 дней</small></span><span>›</span></div>
        <div class="m-li">${g('sliders')}<span>Мои привычки<small>По ним считается экономия</small></span><span>›</span></div>
      </div>
      <span class="m-h">Оформление</span>
      <div class="m-list"><div class="m-li">${g('palette')}<span>Тема оформления<small>Как в системе</small></span><span>›</span></div></div>
    </div>`,
  },
  {
    title: 'Рейтинг', shot: 'l_22_leaderboard', crop: [1, 40],
    why: [
      'Вместо одной строки — понятное объяснение, что здесь будет.',
      'Честно и спокойно: без «скоро-скоро», без давления.',
    ],
    after: () => `<div class="mock" style="min-height:300px;align-content:center"><div class="empty">
      <svg viewBox="0 0 120 96" aria-hidden="true"><rect x="10" y="50" width="30" height="40" rx="6" fill="var(--a-sc)"/><rect x="45" y="30" width="30" height="60" rx="6" fill="var(--a-pc)"/><rect x="80" y="58" width="30" height="32" rx="6" fill="var(--a-sc)"/>
        <path d="M60 8c-8 6-9 14-4 18 6-2 9-10 4-18z" fill="var(--a-primary)"/><path d="M60 26v4" stroke="var(--a-primary)" stroke-width="3" stroke-linecap="round"/></svg>
      <b style="font-size:16px">Здесь будет рейтинг с друзьями</b>
      <span style="color:var(--a-on-var)">Добавляйте друзей по коду и поддерживайте друг друга. Всё анонимно и только по желанию.</span>
      <span class="m-label">Появится в одном из следующих обновлений</span>
    </div></div>`,
  },
];

// ── Fonts ─────────────────────────────────────────────────────────────────
const FONTS = [
  { name: 'Roboto', note: 'Сейчас, стандартный', fam: '"Roboto", sans-serif' },
  { name: 'Manrope', note: 'Рекомендую: спокойный, ровные цифры', fam: '"Manrope", sans-serif' },
  { name: 'Nunito', note: 'Мягкий и округлый, самый дружелюбный', fam: '"Nunito", sans-serif' },
  { name: 'Onest', note: 'Современный, делали для кириллицы', fam: '"Onest", sans-serif' },
];

// ── Animations ────────────────────────────────────────────────────────────
// p: priority 1–3, e: effort.
const ANIMS = [
  { p: 1, e: 'Быстро', what: 'Цифры «набегают», полоски заполняются', where: 'Главная, Достижения, Знания, сводка «Тропы», окно «Подробнее»', why: 'Прогресс ощущается как движение вперёд, а не как сухая цифра.' },
  { p: 1, e: 'Быстро', what: 'Лёгкая вибрация', where: 'Смена вдоха и выдоха, «Тяга прошла!», новый значок, выбор повода', why: 'Можно дышать с закрытыми глазами. Важные моменты чувствуются рукой.' },
  { p: 1, e: 'Быстро', what: 'SOS сворачивается при прокрутке', where: 'Все вкладки', why: 'Кнопка всегда под рукой, но не закрывает текст.' },
  { p: 1, e: 'Быстро', what: 'Отсчёт без наложения цифр', where: 'SOS → Отсчёт 10 → 0', why: 'Сейчас цифры 10 и 9 на миг накладываются. Сделать так, чтобы старая уходила вверх, а новая приходила снизу.' },
  { p: 1, e: 'Быстро', what: 'Учитывать «Убрать анимацию» в телефоне', where: 'Везде', why: 'Людям, которым движение мешает, всё показывается сразу.' },
  { p: 1, e: 'Средне', what: 'Кольцо-таймер и счёт в дыхании', where: 'SOS → Спокойное дыхание', why: 'Видно, сколько осталось до выдоха. Легче держать ритм 4/6.' },
  { p: 1, e: 'Средне', what: '«Тяга прошла!»: галочка и «+10 XP»', where: 'SOS', why: 'Главная маленькая победа должна чувствоваться победой.' },
  { p: 2, e: 'Средне', what: 'Новый значок: появление с блеском и «Забрать»', where: 'Окно нового значка', why: 'Медаль «вылетает» и поблёскивает цветом редкости. Кнопка «Забрать» даёт секунду порадоваться (так делает Flamy).' },
  { p: 2, e: 'Средне', what: 'Повышение уровня', where: 'Главная, при новом уровне', why: 'Кольцо заполняется до конца, номер сменяется на следующий.' },
  { p: 2, e: 'Быстро', what: 'Нажатие карточек', where: 'Все нажимаемые карточки', why: 'Карточка чуть «проседает» под пальцем. Сразу понятно, что её можно нажать.' },
  { p: 2, e: 'Быстро', what: 'Плавные переходы', where: 'Между вкладками и при открытии экранов', why: 'Экраны мягко сменяют друг друга, а не появляются рывком.' },
  { p: 2, e: 'Средне', what: '«Тропа» прорисовывается', where: 'Здоровье → Этапы, при открытии', why: 'Линия пройденного пути дорисовывается до «Вы здесь», и отметка появляется.' },
  { p: 2, e: 'Быстро', what: 'Графики растут', where: 'Карта тяги, Дневник', why: 'Столбцы вырастают, линии рисуются слева направо.' },
  { p: 3, e: 'Быстро', what: 'Карточки появляются по очереди', where: 'Первое открытие экрана', why: 'Небольшая волна сверху вниз, только при первом открытии.' },
  { p: 3, e: 'Быстро', what: 'Плавное раскрытие групп', where: 'Достижения, Знания', why: 'Группа раскрывается плавно, стрелка поворачивается.' },
  { p: 3, e: 'Долго', what: 'Живые картинки в пустых состояниях', where: 'Рейтинг, пустой Дневник, пустая Карта тяги', why: 'Приятно, но нужны отдельные анимированные рисунки. Лучше отложить.' },
];

// ── Competitors ───────────────────────────────────────────────────────────
const COMPETITORS = [
  { name: 'Smoke Free', points: [
      'Главная: время без курения коротко («1г 3м 24д»), проценты восстановления организма, задания на каждый день.',
      'Значки за этапы; в «Зале славы» — фейерверк.',
      'В обзорах: приложение «для любителей цифр»; одному пользователю показ дневника звёздочками показался скучным.',
    ] },
  { name: 'Kwit', points: [
      'Знакомство построено как переписка с персонажами-талисманами, есть свой аватар.',
      'Главная «плотная от информации». Разбор экранов отмечает, что она может перегружать.',
      'Цели — наглядная лента этапов; трофеи; дыхательные упражнения.',
      'Небольшое исследование (JMIR Serious Games, 2023): каждый открытый уровень связан с более высокими шансами не курить. Это поддерживает нашу идею уровней.',
    ] },
  { name: 'QuitNow!', points: [
      '80 этапов: по невыкуренным сигаретам, дням и деньгам.',
      'Хвалят за простоту и «чистый и яркий» вид.',
      'Жалобы: часть функций платная, общий чат плохо модерируется.',
    ] },
  { name: 'Flamy', points: [
      'Талисман-огонёк в роли личного тренера.',
      'Значки нужно «забрать» вручную. Разработчик пишет, что это даёт момент осознать достижение.',
      'Тёмную тему добавили по просьбам пользователей, потом исправляли читаемость кнопки в ней.',
    ] },
  { name: 'QuitSure', points: [
      'Бирюзовый основной цвет, оранжевый для главных кнопок и наград.',
      'Дыхательное упражнение с анимированным кругом в центре.',
      'Длинный опрос, затем экран оплаты с таймером «скидка сгорает» и значками доверия.',
      'Многие функции закрыты плашками «Unlock Pro».',
    ] },
];
const TAKE = [
  'Один тёплый акцентный цвет (мягкий абрикосовый) только для наград и праздников, как оранжевый у QuitSure. Бирюзовый остаётся основным.',
  'Значок «забрать» вручную, как у Flamy: секунда, чтобы порадоваться.',
  'Наглядный процент восстановления, как у Smoke Free. У нас это «Карта тела» с точками прогресса.',
  'Короткая подсказка при первом открытии сложных экранов (Карта тяги, Дневник). Дневник Smoke Free критиковали за непонятность.',
  'Уровни и этапы — у нас уже есть, и исследование Kwit говорит, что это помогает.',
];
const AVOID = [
  'Платные SOS-инструменты, таймеры «скидка сгорает», плашки «Купите Pro» поверх экрана.',
  'Перегруженная главная. У Kwit её называют «плотной».',
  'Общий чат без модерации, как у QuitNow!.',
  'Громкие эффекты на каждое действие. Наш стиль — спокойствие: праздновать ярко только редкие победы.',
  'Реклама поверх экранов и длинный опрос до первой пользы.',
];
const SOURCES = [
  ['Разбор экранов QuitSure (screensdesign.com)', 'https://screensdesign.com/apps/quitsure-quit-smoking-vaping/'],
  ['Разбор экранов Kwit (screensdesign.com)', 'https://screensdesign.com/showcase/quit-smoking-for-good-kwit'],
  ['Описание Smoke Free (mwm.ai)', 'https://mwm.ai/apps/smoke-free-quit-smoking-now/577767592'],
  ['Исследование уровней Kwit, JMIR Serious Games 2023', 'https://games.jmir.org/2023/1/e39975'],
  ['Flamy в App Store (история обновлений)', 'https://apps.apple.com/jm/app/quit-smoking-smoke-free-flamy/id1462887052'],
  ['Flamy в Google Play', 'https://play.google.com/store/apps/details?id=net.offlinefirst.flamy'],
  ['Сайт Flamy', 'https://flamy.co/'],
  ['Medical News Today: обзор приложений', 'https://www.medicalnewstoday.com/articles/317633'],
  ['Отзывы о QuitNow! (Trustpilot)', 'https://ca.trustpilot.com/review/quitnow.app'],
];
