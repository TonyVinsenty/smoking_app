# Zero launcher-icon candidates

Four refined candidates for the launcher icon. Concept 7, «Чистый вдох» (air swirls): **7a** (polished three swirls) and **7b** (bold swirl that closes into a "0", plus one line). Concept 9, «Тропа к солнцу» (path to the sun): **9a** (full landscape with a perspective path) and **9b** (round "window" emblem).

## Files (per variant `<v>` = 7a, 7b, 9a, 9b)

| File | What it is | viewBox |
|---|---|---|
| `<v>-bg.svg` | Android adaptive **background** layer: opaque and full-bleed. | `-256 -256 1536 1536` |
| `<v>-fg.svg` | Android adaptive **foreground** layer. Transparent outside the motif. | `-256 -256 1536 1536` |
| `<v>-mono.svg` | Android 13+ **monochrome** (themed icon) layer: one flat `#000` silhouette on transparent. | `-256 -256 1536 1536` |
| `<v>-ios.svg` | iOS icon: opaque square with bg and fg merged. iOS rounds the corners itself. | `0 0 1024 1024` |
| `<v>-ios-dark.svg` | iOS 18 dark-appearance icon: opaque, dark background with a brighter motif. | `0 0 1024 1024` |

## Coordinate convention

- The square `0..1024` is the visible icon: the Android 72 dp mask area, or the full iOS square. The centre is (512, 512).
- Android adaptive layers are 108 dp, so in these units the full layer runs from (-256, -256) to (1280, 1280). That is why bg/fg/mono use the `-256 -256 1536 1536` viewBox: each file already is a complete 108 dp layer. Export it at 432×432 px for 4× (xxxhdpi), or let Android Studio import it as a vector.
- Every bg shape (gradients, sky, hills, path) covers the whole 1536 square, so no edges show in any mask or during parallax.
- fg and mono stay inside the Android safe circle (centre 512,512, radius 469). The motif itself is kept within about radius 340 (measured maximum: 7a 339, 7b 327, 9a-mono 322, 9b 338, 9b-mono 325).
- In 9a the landscape (sky, hills and path) runs to the edges, so it lives in the bg layer. The fg layer holds only the sun.
- Only basic SVG is used (path, circle, rect, linear/radial gradients; strokes have round caps). There are no filters, masks, clip paths, text or external references.
