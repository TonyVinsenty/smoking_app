// Zero app icon concepts. Canvas 1024×1024 = the visible icon (iOS full square, Android 72dp mask area).
// Each icon: bg (full-bleed, opaque) + fg (kept inside the Android safe zone: circle r≈470 around the centre,
// motif itself kept inside r≈340 so it breathes in every mask).
// Laurel wreath shaped like an open "0": two branches meet at the bottom, gap at the top.
function wreath() {
  const cx = 512, cy = 530, r = 232, leaf = 'M0 0 C 34 -42 108 -46 146 0 C 108 46 34 42 0 0 Z';
  const rad = (d) => (d * Math.PI) / 180;
  let out = `<path d="M${cx + r * Math.cos(rad(244))} ${cy + r * Math.sin(rad(244))} A ${r} ${r} 0 1 0 ${cx + r * Math.cos(rad(-64))} ${cy + r * Math.sin(rad(-64))}"
    fill="none" stroke="#BDF5EA" stroke-width="26" stroke-linecap="round"/>`;
  const branch = (from, to, dir, color) => {
    let i = 0;
    for (let a = from; dir > 0 ? a <= to : a >= to; a += 25 * dir, i++) {
      const x = cx + r * Math.cos(rad(a)), y = cy + r * Math.sin(rad(a));
      const tangent = a + 90 * dir;
      const side = i % 2 ? 1 : -1;
      out += `<path d="${leaf}" fill="${i % 2 ? color : '#E6FBF6'}" transform="translate(${x.toFixed(1)} ${y.toFixed(1)}) rotate(${tangent + side * 34 * dir})"/>`;
    }
  };
  branch(98, 240, 1, '#A6EBDD');
  branch(82, -60, -1, '#A6EBDD');
  return out;
}

window.ZERO_ICONS = [
  {
    id: 'ring', zero: true, name: 'Открытое кольцо',
    idea: '«0» как кольцо прогресса, которое почти замкнулось. В разрыве — росток: путь ещё идёт, и он живой.',
    defs: `<linearGradient id="ring-bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#1E8A7C"/><stop offset="1" stop-color="#0C4A44"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#ring-bg)"/>`,
    fg: `<circle cx="512" cy="530" r="250" fill="none" stroke="#BDF5EA" stroke-width="92" stroke-linecap="round"
           stroke-dasharray="1300 271" transform="rotate(-58 512 530)"/>
         <path d="M512 352 V250" stroke="#F3D7A6" stroke-width="22" stroke-linecap="round"/>
         <path d="M512 282 C 470 282 432 252 424 206 C 470 204 508 232 512 282 Z" fill="#F3D7A6"/>
         <path d="M512 262 C 548 254 584 222 590 178 C 548 180 514 212 512 262 Z" fill="#FFE6BC"/>`,
  },
  {
    id: 'dawn', zero: true, name: 'Ноль-рассвет',
    idea: 'Овал «0» как окно, в котором встаёт солнце. Новое начало, спокойная светлая иконка.',
    defs: `<linearGradient id="dawn-bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F1FCF8"/><stop offset="1" stop-color="#BFEDE2"/></linearGradient>
           <clipPath id="dawn-clip"><rect x="334" y="260" width="356" height="504" rx="178"/></clipPath>`,
    bg: `<rect width="1024" height="1024" fill="url(#dawn-bg)"/>`,
    fg: `<g clip-path="url(#dawn-clip)">
           <rect x="300" y="250" width="424" height="560" fill="#DDF6EF"/>
           <circle cx="512" cy="590" r="104" fill="#F4B77E"/>
           <rect x="300" y="590" width="424" height="230" fill="#2E9E8F"/>
           <path d="M420 640 H604" stroke="#BDF5EA" stroke-width="18" stroke-linecap="round" opacity=".9"/>
           <path d="M452 684 H572" stroke="#BDF5EA" stroke-width="16" stroke-linecap="round" opacity=".6"/>
           <path d="M482 724 H542" stroke="#BDF5EA" stroke-width="14" stroke-linecap="round" opacity=".4"/>
         </g>
         <rect x="298" y="224" width="428" height="576" rx="214" fill="none" stroke="#11625A" stroke-width="72"/>`,
  },
  {
    id: 'leaves', zero: true, name: 'Венок-ноль',
    idea: '«0» из лаврового венка с разрывом сверху. Цифра, символ победы и что-то живое одновременно.',
    defs: `<linearGradient id="leaves-bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#17806F"/><stop offset="1" stop-color="#0D4F48"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#leaves-bg)"/>`,
    fg: wreath(),
  },
  {
    id: 'breath', zero: true, name: 'Круги дыхания',
    idea: 'Расходящиеся круги — спокойный выдох и пульс. Центральное кольцо — тот самый «0».',
    defs: `<radialGradient id="breath-bg" cx=".5" cy=".45" r=".75"><stop offset="0" stop-color="#16736A"/><stop offset="1" stop-color="#0A3B37"/></radialGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#breath-bg)"/>`,
    fg: `<circle cx="512" cy="512" r="312" fill="none" stroke="#9EF2E3" stroke-width="18" opacity=".22"/>
         <circle cx="512" cy="512" r="232" fill="none" stroke="#9EF2E3" stroke-width="32" opacity=".5"/>
         <circle cx="512" cy="512" r="138" fill="none" stroke="#C9F8EF" stroke-width="64"/>`,
  },
  {
    id: 'progress', zero: true, name: 'Кольцо прогресса',
    idea: '«0» как кольцо активности: почти полный круг со светящейся точкой. Самая «технологичная» из спокойных.',
    defs: `<linearGradient id="progress-stroke" x1="200" y1="800" x2="820" y2="220" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#2E9E8F"/><stop offset="1" stop-color="#B8F6EA"/></linearGradient>
           <radialGradient id="progress-glow"><stop offset="0" stop-color="#E8FFF9" stop-opacity=".9"/><stop offset="1" stop-color="#E8FFF9" stop-opacity="0"/></radialGradient>`,
    bg: `<rect width="1024" height="1024" fill="#0B2F2C"/>`,
    fg: `<circle cx="512" cy="512" r="262" fill="none" stroke="#1B4843" stroke-width="84"/>
         <circle cx="512" cy="512" r="262" fill="none" stroke="url(#progress-stroke)" stroke-width="84" stroke-linecap="round"
           stroke-dasharray="1370 400" transform="rotate(-90 512 512)"/>
         <circle cx="376" cy="288" r="70" fill="url(#progress-glow)"/>
         <circle cx="376" cy="288" r="24" fill="#F2FFFC"/>`,
  },
  {
    id: 'sprout', zero: false, name: 'Росток',
    idea: 'Два листочка из земли. Рост, новая жизнь — без привязки к названию.',
    defs: `<linearGradient id="sprout-bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E4F9F3"/><stop offset="1" stop-color="#B4EADD"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#sprout-bg)"/>`,
    fg: `<ellipse cx="512" cy="742" rx="250" ry="56" fill="#2E9E8F" opacity=".22"/>
         <path d="M512 742 C 512 640 506 560 520 470" stroke="#17695F" stroke-width="34" fill="none" stroke-linecap="round"/>
         <path d="M516 520 C 420 532 312 476 290 352 C 410 330 506 400 516 520 Z" fill="#2E9E8F"/>
         <path d="M520 472 C 560 380 660 312 760 330 C 750 444 650 500 520 472 Z" fill="#17806F"/>
         <path d="M500 506 C 440 480 380 430 340 376" stroke="#BDF5EA" stroke-width="10" fill="none" stroke-linecap="round" opacity=".7"/>
         <path d="M534 462 C 600 420 660 378 720 352" stroke="#BDF5EA" stroke-width="10" fill="none" stroke-linecap="round" opacity=".6"/>`,
  },
  {
    id: 'wind', zero: false, name: 'Чистый вдох',
    idea: 'Лёгкие завитки воздуха — тот же образ, что у кнопки SOS. Иконка = «дышится легче».',
    defs: `<linearGradient id="wind-bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#2AA191"/><stop offset="1" stop-color="#0F5E56"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#wind-bg)"/>`,
    fg: `<g fill="none" stroke-linecap="round" stroke-linejoin="round">
           <path d="M262 420 H590 C 664 420 700 364 672 318 C 648 280 588 288 584 334" stroke="#F4FFFC" stroke-width="58"/>
           <path d="M222 530 H730 C 806 530 842 600 806 650 C 776 692 712 682 704 632" stroke="#BDF5EA" stroke-width="58"/>
           <path d="M322 640 H560" stroke="#8FE3D3" stroke-width="58"/>
         </g>`,
  },
  {
    id: 'lungs', zero: false, name: 'Лёгкие-листья',
    idea: 'Две доли лёгких — листья на одной веточке. Про здоровье, но мягко, без «медицинского» холода.',
    defs: `<linearGradient id="lungs-bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F3FCF9"/><stop offset="1" stop-color="#D3F3EB"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#lungs-bg)"/>`,
    fg: `<path d="M512 250 V 470 M512 470 C 500 500 482 516 456 528 M512 470 C 524 500 542 516 568 528" stroke="#11625A" stroke-width="30" fill="none" stroke-linecap="round"/>
         <path d="M470 420 C 400 360 300 380 270 520 C 244 650 300 760 410 752 C 470 748 486 700 486 640 L 486 470 Z" fill="#2E9E8F"/>
         <path d="M554 420 C 624 360 724 380 754 520 C 780 650 724 760 614 752 C 554 748 538 700 538 640 L 538 470 Z" fill="#1E8A7C"/>
         <path d="M466 560 C 420 580 370 620 336 680 M470 640 C 430 660 400 690 380 720" stroke="#BDF5EA" stroke-width="12" fill="none" stroke-linecap="round" opacity=".8"/>
         <path d="M558 560 C 604 580 654 620 688 680 M554 640 C 594 660 624 690 644 720" stroke="#BDF5EA" stroke-width="12" fill="none" stroke-linecap="round" opacity=".7"/>`,
  },
  {
    id: 'path', zero: false, name: 'Тропа к солнцу',
    idea: 'Дорожка уходит к восходу между холмами — как «Тропа» этапов во вкладке «Здоровье».',
    defs: `<linearGradient id="path-bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E9FAF5"/><stop offset=".6" stop-color="#C8F0E6"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#path-bg)"/>
         <circle cx="512" cy="430" r="118" fill="#F4B77E"/>
         <path d="M0 560 C 180 480 330 500 512 560 C 690 618 850 520 1024 520 V1024 H0 Z" fill="#2E9E8F"/>
         <path d="M0 700 C 210 620 380 650 560 700 C 740 750 880 680 1024 660 V1024 H0 Z" fill="#17695F"/>`,
    fg: `<path d="M512 560 C 560 600 580 640 520 690 C 450 750 420 800 470 880 L 600 880 C 560 810 580 760 640 700 C 700 640 640 590 540 560 Z" fill="#F6EFDF"/>`,
  },
  {
    id: 'feather', zero: false, name: 'Пёрышко',
    idea: 'Лёгкость: дышать легче, на душе легче. Необычный для этой категории образ.',
    defs: `<linearGradient id="feather-bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#D9F6EF"/><stop offset="1" stop-color="#A9E6D8"/></linearGradient>`,
    bg: `<rect width="1024" height="1024" fill="url(#feather-bg)"/>`,
    fg: `<g transform="rotate(38 512 512)">
           <path d="M512 196 C 420 256 380 372 388 492 C 396 600 444 668 512 712 Z" fill="#1E8A7C"/>
           <path d="M512 196 C 604 256 644 372 636 492 C 628 600 580 668 512 712 Z" fill="#11625A"/>
           <path d="M394 450 L 444 480 M404 560 L 450 588 M628 410 L 586 438" stroke="#C3EEE4" stroke-width="16" stroke-linecap="round"/>
           <path d="M512 214 V 830" stroke="#0B3F3A" stroke-width="18" stroke-linecap="round"/>
         </g>`,
  },
];

window.zeroIconSvg = (icon, { fg = true, bg = true } = {}) =>
  `<svg viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="${icon.name}"><defs>${icon.defs}</defs>${bg ? icon.bg : ''}${fg ? icon.fg : ''}</svg>`;
