import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_sheet.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/app_toast.dart';
import '../../../../technical/Theme/row_gap.dart';
import '../../data/csv_file_reader.dart';
import '../../domain/csv_parser.dart';
import '../../domain/entities/spend_category.dart';
import '../cubit/spending_cubit.dart';
import '../cubit/spending_view_cubit.dart';
import '../widgets/transaction_row.dart';

Future<void> showImportSheet(BuildContext context) => showAppSheet(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SpendingCubit>()),
          BlocProvider.value(value: context.read<SpendingViewCubit>()),
          BlocProvider.value(value: context.read<AmountPrivacyCubit>()),
        ],
        child: const _ImportSheet(),
      ),
    );

class _ImportSheet extends StatefulWidget {
  const _ImportSheet();

  @override
  State<_ImportSheet> createState() => _ImportSheetState();
}

class _ImportSheetState extends State<_ImportSheet> {
  CsvParsed? _parsed;
  String _fileName = '';
  String? _error;
  ImportMode _mode = ImportMode.replace;

  void _handle(String name, String text) {
    final result = parseCsv(text);
    setState(() {
      switch (result) {
        case CsvFailure(:final message):
          _error = message;
        case CsvParsed():
          _error = null;
          _parsed = result;
          _fileName = name;
      }
    });
  }

  Future<void> _pick() async {
    try {
      final file = await pickCsvFile();
      if (file != null) _handle(file.name, file.text);
    } on Object {
      setState(() => _error = 'Impossible de lire ce fichier.');
    }
  }

  Future<void> _confirm(CsvParsed p) async {
    final navigator = Navigator.of(context);
    final messenger = Navigator.of(context, rootNavigator: true).context;
    await context.read<SpendingCubit>().importEntries(p.entries, _fileName, _mode);
    if (!mounted) return;
    context.read<SpendingViewCubit>().setFilter('all');
    navigator.pop();
    if (messenger.mounted) showToast(messenger, '${p.entries.length} opérations importées');
  }

  @override
  Widget build(BuildContext context) {
    final p = _parsed;
    return AppSheet(title: p == null ? 'Importer un relevé' : 'Aperçu de l’import', child: p == null ? _choose() : _preview(p));
  }

  Widget _choose() {
    const steps = ['Exportez votre relevé au format CSV depuis votre banque.', 'Vérifiez qu’il contient une date, un libellé et un montant.', 'Choisissez le fichier ici : tout reste sur cet appareil.'];
    return Column(children: [
      GestureDetector(
        onTap: _pick,
        child: Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.line, width: 2)),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            AppText('Choisir un fichier CSV', size: 15),
            SizedBox(height: 6),
            AppText('date ; libellé ; montant', size: 12, weight: FontWeight.w500, color: AppColors.muted),
          ]),
        ),
      ),
      if (_error != null)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.neg.withAlpha(30), borderRadius: BorderRadius.circular(14)),
          child: AppText(_error!, size: 13, color: AppColors.neg),
        ),
      const SizedBox(height: 14),
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(children: [
            Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: AppColors.cardInner, shape: BoxShape.circle), child: AppText('${i + 1}', size: 12, color: AppColors.accent)),
            const SizedBox(width: 12),
            Expanded(child: AppText(steps[i], size: 13, weight: FontWeight.w500, color: AppColors.soft)),
          ]),
        ),
    ]);
  }

  Widget _preview(CsvParsed p) {
    final dates = p.entries.map((t) => t.date).toList()..sort();
    final out = p.entries.where((t) => t.amount < 0).fold<double>(0, (a, t) => a + t.amount);
    final inn = p.entries.where((t) => t.amount > 0).fold<double>(0, (a, t) => a + t.amount);
    final toReview = p.entries.where((t) => t.category == SpendCategory.autre).length;
    final auto = 1 - toReview / p.entries.length;
    const sepNames = {';': 'Point-virgule', ',': 'Virgule', '\t': 'Tabulation'};
    final plural = p.skipped > 1 ? 's' : '';
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppText(_fileName, maxLines: 1),
          AppText('${p.entries.length} opérations · ${shortDate(dates.first)} → ${shortDate(dates.last)} ${dates.last.substring(0, 4)}', size: 12, weight: FontWeight.w500, color: AppColors.muted),
        ])),
        GestureDetector(onTap: () => setState(() => _parsed = null), child: const AppText('Changer', size: 13, color: AppColors.accent)),
      ]),
      Row(children: [
        Expanded(child: _tile('Sorties', formatEuro(out), AppColors.text)),
        const SizedBox(width: 12),
        Expanded(child: _tile('Entrées', formatEuro(inn, sign: true), AppColors.pos)),
      ]),
      AppCard(radius: 16, padding: const EdgeInsets.all(14), color: AppColors.cardInner, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const AppText('Catégorisées automatiquement', size: 13),
          AppText(formatPercent(auto), size: 13, color: AppColors.accent),
        ]),
        ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: auto, minHeight: 6, backgroundColor: AppColors.track, color: AppColors.accent)),
        AppText('$toReview à classer · ${p.skipped} ligne$plural ignorée$plural · ${sepNames[p.separator]}', size: 12, weight: FontWeight.w500, color: AppColors.muted),
        AppText('Date ← ${p.dateColumn} · Libellé ← ${p.labelColumn} · Montant ← ${p.amountColumn}', size: 12, weight: FontWeight.w500, color: AppColors.soft),
      ].withGap(8))),
      AppCard(radius: 16, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4), color: AppColors.cardInner, child: Column(children: [for (final t in p.entries.take(5)) TransactionRow(entry: t, onTap: () {})])),
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.cardInner, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (final (mode, label) in [(ImportMode.replace, 'Remplacer'), (ImportMode.append, 'Ajouter')])
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mode = mode),
                child: Container(height: 38, alignment: Alignment.center, decoration: BoxDecoration(color: _mode == mode ? AppColors.line : Colors.transparent, borderRadius: BorderRadius.circular(11)), child: AppText(label, size: 13, color: _mode == mode ? AppColors.text : AppColors.muted)),
              ),
            ),
        ]),
      ),
      AppButton(label: '${_mode == ImportMode.replace ? 'Remplacer par' : 'Ajouter'} ${p.entries.length} opérations', height: 54, radius: 18, onPressed: () => _confirm(p)),
    ].withGap(12));
  }

  Widget _tile(String label, String value, Color color) => AppCard(radius: 16, padding: const EdgeInsets.all(12), color: AppColors.cardInner, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppText(label, size: 11, weight: FontWeight.w600, color: AppColors.muted),
        FittedBox(fit: BoxFit.scaleDown, child: AppText(value, size: 15, weight: FontWeight.w800, color: color)),
      ]));
}
