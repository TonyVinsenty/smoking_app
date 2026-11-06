const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const arb = JSON.parse(fs.readFileSync(path.join(root, 'lib/l10n/app_ru.arb'), 'utf8'));
fs.writeFileSync(path.join(root, 'functions/strings.ru.json'), JSON.stringify({appTitle: arb.appTitle, chatPhoto: arb.chatPhoto}, null, 2) + '\n');
