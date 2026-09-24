import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// First-run questionnaire: what the user smokes, how much, prices, quit date.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _ProductForm {
  _ProductForm(this.type)
      : unitsPerPack = TextEditingController(text: _hasPacks(type) ? '20' : '1');

  final ProductType type;
  final amount = TextEditingController();
  final price = TextEditingController();
  final TextEditingController unitsPerPack;
  ConsumptionPeriod period = ConsumptionPeriod.day;

  static bool _hasPacks(ProductType t) => t == ProductType.cigarettes || t == ProductType.sticks;
  bool get hasPacks => _hasPacks(type);

  static double? _parse(TextEditingController c) {
    final v = double.tryParse(c.text.replaceAll(',', '.').trim());
    return v != null && v > 0 ? v : null;
  }

  bool get isValid => _parse(amount) != null && _parse(price) != null && _parse(unitsPerPack) != null;

  SmokingProductsCompanion toCompanion() => SmokingProductsCompanion.insert(
        type: type,
        amount: _parse(amount)!,
        period: period,
        unitsPerPack: _parse(unitsPerPack)!.round(),
        packPrice: _parse(price)!,
      );

  void dispose() {
    amount.dispose();
    price.dispose();
    unitsPerPack.dispose();
  }
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0;
  final Map<ProductType, _ProductForm> _forms = {};
  DateTime? _quitAt; // null = right now
  bool _saving = false;

  @override
  void dispose() {
    for (final f in _forms.values) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _canContinue => switch (_step) {
        1 => _forms.isNotEmpty,
        2 => _forms.values.every((f) => f.isValid),
        _ => true,
      };

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(databaseProvider).completeOnboarding(
          [for (final f in _forms.values) f.toCompanion()],
          _quitAt ?? DateTime.now(),
        );
  }

  Future<void> _pickQuitDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _quitAt ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 10)),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_quitAt ?? now));
    if (!mounted) return;
    var picked = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    if (picked.isAfter(now)) picked = now;
    setState(() => _quitAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLast = _step == 3;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_step > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: LinearProgressIndicator(value: _step / 3, borderRadius: BorderRadius.circular(4)),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.all(24),
                  child: switch (_step) {
                    0 => _welcome(l),
                    1 => _products(l),
                    2 => _consumption(l),
                    _ => _quitDate(l),
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(onPressed: () => setState(() => _step--), child: Text(l.back)),
                  const Spacer(),
                  FilledButton(
                    onPressed: !_canContinue || _saving
                        ? null
                        : isLast
                            ? _finish
                            : () => setState(() => _step++),
                    child: Text(switch (_step) { 0 => l.onbStart, 3 => l.onbFinish, _ => l.next }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text, [String? hint]) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Theme.of(context).textTheme.headlineMedium),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(hint, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
        ],
      );

  Widget _welcome(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Icon(Icons.spa, size: 88, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          _title(l.onbWelcomeTitle, l.onbWelcomeText),
        ],
      );

  Widget _products(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(l.onbProductsTitle, l.onbProductsHint),
          for (final type in ProductType.values)
            CheckboxListTile(
              value: _forms.containsKey(type),
              title: Text(l.productName(type.name)),
              onChanged: (on) => setState(() {
                if (on!) {
                  _forms[type] = _ProductForm(type);
                } else {
                  _forms.remove(type)?.dispose();
                }
              }),
            ),
        ],
      );

  Widget _consumption(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(l.onbConsumptionTitle, l.onbConsumptionHint),
          for (final f in _forms.values) ...[
            Text(l.productName(f.type.name), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _numberField(f.amount, l.productUnits(f.type.name)),
            const SizedBox(height: 8),
            SegmentedButton<ConsumptionPeriod>(
              segments: [
                for (final p in ConsumptionPeriod.values)
                  ButtonSegment(value: p, label: Text(l.periodName(p.name))),
              ],
              selected: {f.period},
              onSelectionChanged: (s) => setState(() => f.period = s.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _numberField(f.price, l.productPackPrice(f.type.name))),
                if (f.hasPacks) ...[
                  const SizedBox(width: 12),
                  SizedBox(width: 120, child: _numberField(f.unitsPerPack, l.productUnitsPerPack, integer: true)),
                ],
              ],
            ),
            const SizedBox(height: 32),
          ],
        ],
      );

  Widget _numberField(TextEditingController c, String label, {bool integer = false}) => TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(integer ? r'[0-9]' : r'[0-9.,]'))],
        onChanged: (_) => setState(() {}),
      );

  Widget _quitDate(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(l.onbQuitTitle),
          RadioGroup<bool>(
            groupValue: _quitAt == null,
            onChanged: (now) => now! ? setState(() => _quitAt = null) : _pickQuitDate(),
            child: Column(
              children: [
                RadioListTile(value: true, title: Text(l.onbQuitNow)),
                RadioListTile(
                  value: false,
                  title: Text(l.onbQuitEarlier),
                  subtitle: _quitAt == null
                      ? null
                      : Text(l.onbQuitChosen(DateFormat('d MMMM yyyy, HH:mm', 'ru').format(_quitAt!))),
                  secondary: _quitAt == null ? null : IconButton(icon: const Icon(Icons.edit_calendar), onPressed: _pickQuitDate),
                ),
              ],
            ),
          ),
        ],
      );
}
