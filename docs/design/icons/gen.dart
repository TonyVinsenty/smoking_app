// Generates the Zero launcher-icon variants (7a, 7b, 9a, 9b) as SVG layers + a JS data block for the review page.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as m;

const repoOut = r'D:\Projects\Claude\SmokingAPP\docs\design\icons';
final scratch = File(Platform.script.toFilePath()).parent.path;

String f(num v) {
  var s = v.toStringAsFixed(1);
  if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
  if (s == '-0') s = '0';
  return s;
}

class P {
  final double x, y;
  const P(this.x, this.y);
  P operator +(P o) => P(x + o.x, y + o.y);
  P operator -(P o) => P(x - o.x, y - o.y);
  P operator *(double k) => P(x * k, y * k);
  double get len => m.sqrt(x * x + y * y);
  P get unit => this * (1 / len);
}

double rad(double d) => d * m.pi / 180;
P pol(P c, double r, double a) => P(c.x + r * m.cos(rad(a)), c.y + r * m.sin(rad(a)));
double ang(P c, P p) => m.atan2(p.y - c.y, p.x - c.x) * 180 / m.pi;
double g(double x, double c, double s) => m.exp(-m.pow((x - c) / s, 2).toDouble());
String poly(List<P> pts) => 'M${pts.map((p) => '${f(p.x)} ${f(p.y)}').join(' L')}Z';
P bez(List<P> c, double t) {
  final u = 1 - t;
  return c[0] * (u * u * u) + c[1] * (3 * u * u * t) + c[2] * (3 * u * t * t) + c[3] * (t * t * t);
}

const center = P(512, 512);

/// Safe-zone samples per variant/layer: (point, extra radius).
final checks = <String, List<(P, double)>>{};
void check(String key, Iterable<P> pts, [double pad = 0]) =>
    checks.putIfAbsent(key, () => []).addAll(pts.map((p) => (p, pad)));

/// A stroked path built from lines and circular arcs (angles in degrees, screen coordinates: 0 = right, 90 = down).
class Stroke {
  final sb = StringBuffer();
  final samples = <P>[];
  P cur = const P(0, 0);
  Stroke move(P p) {
    sb.write('M${f(p.x)} ${f(p.y)}');
    cur = p;
    samples.add(p);
    return this;
  }

  Stroke line(P p) {
    for (var i = 1; i <= 24; i++) samples.add(cur + (p - cur) * (i / 24));
    sb.write(' L${f(p.x)} ${f(p.y)}');
    cur = p;
    return this;
  }

  Stroke arc(P c, double r, double a0, double a1) {
    final e = pol(c, r, a1);
    sb.write(' A${f(r)} ${f(r)} 0 ${(a1 - a0).abs() > 180 ? 1 : 0} ${a1 > a0 ? 1 : 0} ${f(e.x)} ${f(e.y)}');
    for (var i = 1; i <= 72; i++) samples.add(pol(c, r, a0 + (a1 - a0) * i / 72));
    cur = e;
    return this;
  }

  String get d => sb.toString();
}

String strokeEl(Stroke s, String color, double w) =>
    '<path d="${s.d}" fill="none" stroke="$color" stroke-width="${f(w)}" stroke-linecap="round" stroke-linejoin="round"/>';

/// Moves a set of strokes so that their padded bounding box is centred on (512,512) + nudge.
P centreOffset(List<Stroke> ss, double pad, P nudge) {
  var minX = 1e9, minY = 1e9, maxX = -1e9, maxY = -1e9;
  for (final s in ss) {
    for (final p in s.samples) {
      minX = m.min(minX, p.x - pad);
      maxX = m.max(maxX, p.x + pad);
      minY = m.min(minY, p.y - pad);
      maxY = m.max(maxY, p.y + pad);
    }
  }
  return P(512 - (minX + maxX) / 2, 512 - (minY + maxY) / 2) + nudge;
}

class Variant {
  final String id;
  String defs = '', bg = '', fg = '', mono = '', darkDefs = '', dark = '';
  Variant(this.id);
}

// ───────────────────────── 7A: three air swirls, polished ─────────────────────────
List<Stroke> swirls7a(P o, double s) {
  P q(double x, double y) => P(x * s, y * s) + o;
  final r = 92 * s;
  return [
    Stroke().move(q(64, 0)).line(q(352, 0)).arc(q(352, -92), r, 90, -160),
    Stroke().move(q(0, 124)).line(q(496, 124)).arc(q(496, 216), r, -90, 160),
    Stroke().move(q(140, 248)).line(q(292, 248)),
  ];
}

Variant v7a() {
  final v = Variant('7a');
  const s = 0.91, w = 66 * s;
  final probe = swirls7a(const P(0, 0), s);
  final o = centreOffset(probe, w / 2, const P(-8, 0));
  final ss = swirls7a(o, s);
  for (final st in ss) check('7a', st.samples, w / 2);
  const cols = ['#F6FFFD', '#CDF7EE', '#9EF2E3'];
  const darkCols = ['#D2FAF2', '#9EF2E3', '#5FCDB9'];
  v.defs = '<linearGradient id="v7a-bg" x1="80" y1="0" x2="944" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#33AC9B"/><stop offset="1" stop-color="#0F5E56"/></linearGradient>';
  v.bg = '<rect x="-256" y="-256" width="1536" height="1536" fill="url(#v7a-bg)"/>';
  v.fg = [for (var i = 0; i < 3; i++) strokeEl(ss[i], cols[i], w)].join('');
  v.mono = [for (final st in ss) strokeEl(st, '#000', w)].join('');
  v.darkDefs = '<linearGradient id="v7a-dk" x1="80" y1="0" x2="944" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#13372F"/><stop offset="1" stop-color="#0A1514"/></linearGradient>';
  v.dark = '<rect width="1024" height="1024" fill="url(#v7a-dk)"/>${[
    for (var i = 0; i < 3; i++) strokeEl(ss[i], darkCols[i], w)
  ].join('')}';
  return v;
}

// ───────────────────────── 7B: one bold swirl that closes into a soft "0" ─────────────────────────
List<Stroke> swirls7b(P o) {
  P q(double x, double y) => P(x, y) + o;
  return [
    Stroke().move(q(-380, 158)).line(q(0, 158)).arc(q(0, 0), 158, 90, -198),
    Stroke().move(q(-290, 276)).line(q(-10, 276)),
  ];
}

Variant v7b() {
  final v = Variant('7b');
  const w = 80.0;
  final o = centreOffset(swirls7b(const P(0, 0)), w / 2, const P(0, 0));
  final ss = swirls7b(o);
  for (final st in ss) check('7b', st.samples, w / 2);
  v.defs = '<linearGradient id="v7b-bg" x1="80" y1="0" x2="944" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#2FA696"/><stop offset="1" stop-color="#11625A"/></linearGradient>';
  v.bg = '<rect x="-256" y="-256" width="1536" height="1536" fill="url(#v7b-bg)"/>';
  v.fg = strokeEl(ss[0], '#F6FFFD', w) + strokeEl(ss[1], '#9EF2E3', w);
  v.mono = strokeEl(ss[0], '#000', w) + strokeEl(ss[1], '#000', w);
  v.darkDefs = '<linearGradient id="v7b-dk" x1="80" y1="0" x2="944" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#13372F"/><stop offset="1" stop-color="#0A1514"/></linearGradient>';
  v.dark = '<rect width="1024" height="1024" fill="url(#v7b-dk)"/>'
      '${strokeEl(ss[0], '#C6F8EE', w)}${strokeEl(ss[1], '#5FCDB9', w)}';
  return v;
}

// ───────────────────────── shared landscape helpers ─────────────────────────
/// Ribbon (tapering band) along a cubic centreline; returns left and right edges from t=0 (far) to t=1 (near).
(List<P>, List<P>) ribbon(List<P> c, double Function(double t) w, {int n = 140}) {
  final l = <P>[], r = <P>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final p = bez(c, t);
    final d = (bez(c, m.min(1, t + 1e-3)) - bez(c, m.max(0, t - 1e-3))).unit;
    final nrm = P(-d.y, d.x);
    l.add(p + nrm * (w(t) / 2));
    r.add(p - nrm * (w(t) / 2));
  }
  return (l, r);
}

List<P> hillPoly(double Function(double) crest, {double x0 = -256, double x1 = 1280, double bottom = 1280}) => [
      for (var x = x0; x <= x1 + 0.01; x += 8) P(x, crest(x)),
      P(x1, bottom),
      P(x0, bottom),
    ];

/// Cuts an edge polyline at the first point that leaves the circle; returns kept points and exit point.
List<P> cutAtCircle(List<P> edge, P c, double r) {
  final out = <P>[];
  for (var i = 0; i < edge.length; i++) {
    if ((edge[i] - c).len <= r) {
      out.add(edge[i]);
      continue;
    }
    if (i == 0) break;
    var a = edge[i - 1], b = edge[i];
    for (var k = 0; k < 40; k++) {
      final mid = (a + b) * 0.5;
      if ((mid - c).len <= r) {
        a = mid;
      } else {
        b = mid;
      }
    }
    out.add(a);
    break;
  }
  return out;
}

List<P> arcPts(P c, double r, double a0, double a1, {int n = 60}) =>
    [for (var i = 0; i <= n; i++) pol(c, r, a0 + (a1 - a0) * i / n)];

/// Crest/circle intersection searching outward from the circle centre in direction dir (+1 right / -1 left).
P crestHit(double Function(double) crest, P c, double r, int dir) {
  var a = c.x, b = c.x + dir * r;
  double gf(double x) => m.pow(x - c.x, 2) + m.pow(crest(x) - c.y, 2) - r * r;
  for (var k = 0; k < 60; k++) {
    final mid = (a + b) / 2;
    if (gf(mid) < 0) {
      a = mid;
    } else {
      b = mid;
    }
  }
  return P(a, crest(a));
}

/// Ground "badge": region of circle (c, r) under the crest. With a ribbon, the ribbon is cut out as a notch.
List<P> mound(double Function(double) crest, P c, double r, {(List<P>, List<P>)? path}) {
  final pl = crestHit(crest, c, r, -1), pr = crestHit(crest, c, r, 1);
  final pts = <P>[for (var x = pl.x; x < pr.x; x += 6) P(x, crest(x)), pr];
  final aR = ang(c, pr), aL = ang(c, pl) < 0 ? ang(c, pl) + 360 : ang(c, pl);
  if (path == null) {
    pts.addAll(arcPts(c, r, aR, aL));
    return pts;
  }
  final le = cutAtCircle(path.$1, c, r), re = cutAtCircle(path.$2, c, r);
  // the edge exiting at the smaller angle is on the right-hand side of the screen
  var aLe = ang(c, le.last), aRe = ang(c, re.last);
  var right = re, left = le;
  if (aLe < aRe) {
    right = le;
    left = re;
    final t = aLe;
    aLe = aRe;
    aRe = t;
  }
  pts.addAll(arcPts(c, r, aR, aRe));
  pts.addAll(right.reversed);
  pts.addAll(left);
  pts.addAll(arcPts(c, r, aLe, aL));
  return pts;
}

/// Ribbon polygon clipped by a circle at its near end.
List<P> ribbonInCircle((List<P>, List<P>) path, P c, double r) {
  final le = cutAtCircle(path.$1, c, r), re = cutAtCircle(path.$2, c, r);
  final a1 = ang(c, le.last), a2 = ang(c, re.last);
  return [...le, ...arcPts(c, r, a1, a2, n: 20), ...re.reversed];
}

/// Sun disc trimmed so that it keeps a gap above the crest (for one-colour layers).
List<P> sunAbove(P c, double r, double Function(double) crest, double gap) => [
      for (var i = 0; i < 180; i++)
        () {
          final p = pol(c, r, i * 2.0);
          return P(p.x, m.min(p.y, crest(p.x) - gap));
        }()
    ];

/// Ribbon whose width follows perspective: proportional to the distance below the horizon line yH.
(List<P>, List<P>) persp(List<P> c, double k, double yH, double minW) =>
    ribbon(c, (t) => m.max(minW, k * (bez(c, t).y - yH)));

/// Ribbon polygon with its far end trimmed where it rises above a crest line (the path disappears over the brow).
List<P> ribbonBelow((List<P>, List<P>) r, double Function(double) crest) {
  List<P> cut(List<P> e) {
    final i = e.indexWhere((p) => p.y >= crest(p.x));
    if (i <= 0) return e;
    var a = e[i - 1], b = e[i];
    for (var k = 0; k < 40; k++) {
      final mid = (a + b) * 0.5;
      if (mid.y >= crest(mid.x)) {
        b = mid;
      } else {
        a = mid;
      }
    }
    return [b, ...e.sublist(i)];
  }

  return [...cut(r.$1), ...cut(r.$2).reversed];
}

// ───────────────────────── 9A: landscape with a perspective path ─────────────────────────
Variant v9a() {
  final v = Variant('9a');
  double far(double x) => 616 - 72 * g(x, 236, 200) - 60 * g(x, 806, 200);
  double mid(double x) => 744 - 70 * g(x, 40, 240) - 66 * g(x, 1000, 250);
  double near(double x) => 900 - 96 * g(x, 1010, 320) - 30 * g(x, -60, 260);
  final path = persp([const P(486, 712), const P(640, 792), const P(250, 904), const P(600, 1320)], 0.44, 604, 7);
  const sun = P(512, 462), sunR = 116.0;
  check('9a', arcPts(sun, sunR, 0, 360));
  String scene(List<String> c, String glowId, String skyId) =>
      '<rect x="-256" y="-256" width="1536" height="1536" fill="url(#$skyId)"/>'
      '<circle cx="512" cy="${f(sun.y)}" r="360" fill="url(#$glowId)"/>'
      '<path d="${poly(hillPoly(far))}" fill="${c[0]}"/>'
      '<path d="${poly(hillPoly(mid))}" fill="${c[1]}"/>'
      '<path d="${poly(hillPoly(near))}" fill="${c[2]}"/>'
      '<path d="${poly(ribbonBelow(path, mid))}" fill="${c[3]}"/>';
  v.defs = '<linearGradient id="v9a-sky" x1="0" y1="0" x2="0" y2="700" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#EEFCF8"/><stop offset="1" stop-color="#CBF2E8"/></linearGradient>'
      '<radialGradient id="v9a-glow" cx="512" cy="${f(sun.y)}" r="360" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#FCE4C6"/><stop offset=".45" stop-color="#FCE4C6" stop-opacity=".55"/>'
      '<stop offset="1" stop-color="#FCE4C6" stop-opacity="0"/></radialGradient>';
  v.bg = scene(['#93DACD', '#36A897', '#17695F', '#FFF5E6'], 'v9a-glow', 'v9a-sky');
  v.fg = '<circle cx="${f(sun.x)}" cy="${f(sun.y)}" r="${f(sunR)}" fill="#F4B77E"/>';
  // one-colour emblem: sun rising between two gentle hills; the path is cut in as a notch
  const mc = P(512, 406), mr = 330.0;
  double mcrest(double x) => 492 - 26 * g(x, 330, 130) - 20 * g(x, 700, 140);
  final mpath = persp([const P(512, 534), const P(566, 580), const P(392, 626), const P(560, 800)], 0.5, 482, 12);
  final ms = sunAbove(const P(512, 420), 112, mcrest, 30);
  final mm = mound(mcrest, mc, mr, path: mpath);
  check('9a-mono', ms);
  check('9a-mono', mm);
  v.mono = '<path d="${poly(ms)}" fill="#000"/><path d="${poly(mm)}" fill="#000"/>';
  v.darkDefs = '<linearGradient id="v9a-dsky" x1="0" y1="0" x2="0" y2="700" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#0A1413"/><stop offset="1" stop-color="#12342F"/></linearGradient>'
      '<radialGradient id="v9a-dglow" cx="512" cy="${f(sun.y)}" r="360" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#F4B77E" stop-opacity=".38"/><stop offset=".5" stop-color="#F4B77E" stop-opacity=".12"/>'
      '<stop offset="1" stop-color="#F4B77E" stop-opacity="0"/></radialGradient>';
  v.dark = scene(['#1D5A52', '#15463F', '#0E3430', '#A9E9DB'], 'v9a-dglow', 'v9a-dsky') + v.fg;
  return v;
}

// ───────────────────────── 9B: round window emblem — sun rising over a wide hill, path over the brow ─────────────────────────
class Emblem {
  final P c, sun;
  final double r, sunR;
  final double Function(double) crest;
  final (List<P>, List<P>) path;
  Emblem(double dy, [double drop = 0])
      : c = P(512, 512 + dy),
        r = 338,
        sun = P(512, 476 + dy),
        sunR = 150,
        crest = ((x) => 568 + dy + (x - 512) * (x - 512) / 2600),
        path = persp([P(522, 596 + dy + drop), P(608, 668 + dy + drop * .6), P(370, 738 + dy), P(556, 930 + dy)], 0.55, 572 + dy, 12);
}

Variant v9b() {
  final v = Variant('9b');
  final e = Emblem(0);
  final hill = mound(e.crest, e.c, e.r);
  final rib = ribbonInCircle(e.path, e.c, e.r);
  check('9b', arcPts(e.c, e.r, 0, 360));
  v.defs = '<linearGradient id="v9b-bg" x1="0" y1="0" x2="0" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#CFF3EA"/><stop offset="1" stop-color="#9FE2D3"/></linearGradient>';
  v.bg = '<rect x="-256" y="-256" width="1536" height="1536" fill="url(#v9b-bg)"/>';
  String emblem(String skyC, String sunC, String hillC, String pathC) =>
      '<circle cx="${f(e.c.x)}" cy="${f(e.c.y)}" r="${f(e.r)}" fill="$skyC"/>'
      '<circle cx="${f(e.sun.x)}" cy="${f(e.sun.y)}" r="${f(e.sunR)}" fill="$sunC"/>'
      '<path d="${poly(hill)}" fill="$hillC"/><path d="${poly(rib)}" fill="$pathC"/>';
  v.fg = emblem('#F7FDFB', '#F4B77E', '#17695F', '#FFF4E2');
  // one-colour: no window; the scene is lifted so the shape is optically centred
  final mE = Emblem(-74, 34);
  final ms = sunAbove(mE.sun, mE.sunR, mE.crest, 30);
  final mm = mound(mE.crest, mE.c, mE.r, path: mE.path);
  check('9b-mono', ms);
  check('9b-mono', mm);
  v.mono = '<path d="${poly(ms)}" fill="#000"/><path d="${poly(mm)}" fill="#000"/>';
  v.darkDefs = '<linearGradient id="v9b-dk" x1="0" y1="0" x2="0" y2="1024" gradientUnits="userSpaceOnUse">'
      '<stop offset="0" stop-color="#0A1413"/><stop offset="1" stop-color="#11302C"/></linearGradient>';
  v.dark = '<rect width="1024" height="1024" fill="url(#v9b-dk)"/>${emblem('#1A3F3A', '#F4B77E', '#2E9E8F', '#E4FBF5')}';
  return v;
}

// ───────────────────────── output ─────────────────────────
String layer(String defs, String body) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-256 -256 1536 1536" width="1536" height="1536">\n'
    '${defs.isEmpty ? '' : '<defs>$defs</defs>\n'}$body\n</svg>\n';
String square(String defs, String body) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">\n'
    '${defs.isEmpty ? '' : '<defs>$defs</defs>\n'}$body\n</svg>\n';

void main() {
  final vs = [v7a(), v7b(), v9a(), v9b()];
  final data = <String, Map<String, String>>{};
  for (final v in vs) {
    File('$repoOut/${v.id}-bg.svg').writeAsStringSync(layer(v.defs, v.bg));
    File('$repoOut/${v.id}-fg.svg').writeAsStringSync(layer('', v.fg));
    File('$repoOut/${v.id}-mono.svg').writeAsStringSync(layer('', v.mono));
    File('$repoOut/${v.id}-ios.svg').writeAsStringSync(square(v.defs, '${v.bg}\n${v.fg}'));
    File('$repoOut/${v.id}-ios-dark.svg').writeAsStringSync(square(v.darkDefs, v.dark));
    data[v.id] = {
      'light': '<defs>${v.defs}</defs>${v.bg}${v.fg}',
      'dark': '<defs>${v.darkDefs}</defs>${v.dark}',
      'mono': v.mono,
      'bg': '<defs>${v.defs}</defs>${v.bg}',
      'fg': v.fg,
    };
  }
  File('$scratch/icons-data.js').writeAsStringSync('const ICONS = ${jsonEncode(data)};\n');
  for (final e in checks.entries) {
    var worst = 0.0;
    for (final (p, pad) in e.value) {
      worst = m.max(worst, (p - center).len + pad);
    }
    stdout.writeln('${e.key}: max radius ${worst.toStringAsFixed(1)} (motif target <= ~340, hard limit 469)');
  }
  // full-page assembly
  final tpl = File('$scratch/template.html');
  if (tpl.existsSync()) {
    File('$scratch/index.html')
        .writeAsStringSync(tpl.readAsStringSync().replaceFirst('/*ICON_DATA*/', 'const ICONS = ${jsonEncode(data)};'));
  }
}
