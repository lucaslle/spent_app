import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_chip.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_sheet.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/app_toast.dart';
import '../../../../technical/Theme/app_toggle.dart';
import '../../../../technical/Theme/avatar_badge.dart';
import '../../../../technical/Theme/row_gap.dart';
import '../../domain/categorizer.dart';
import '../../domain/entities/spend_category.dart';
import '../cubit/spending_cubit.dart';

Future<void> showTransactionDetail(BuildContext context, String id) => showAppSheet(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [BlocProvider.value(value: context.read<SpendingCubit>()), BlocProvider.value(value: context.read<AmountPrivacyCubit>())],
        child: _DetailSheet(id: id, toastContext: context),
      ),
    );

class _DetailSheet extends StatefulWidget {
  const _DetailSheet({required this.id, required this.toastContext});

  final String id;
  final BuildContext toastContext;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  bool _similar = true;

  @override
  Widget build(BuildContext context) {
    final entries = context.watch<SpendingCubit>().state.entries;
    final t = entries.where((e) => e.id == widget.id).firstOrNull;
    if (t == null) return const SizedBox.shrink();
    final name = merchantName(t.raw);
    final same = entries.where((e) => merchantName(e.raw) == name).toList();
    final others = same.length - 1;
    final total = same.fold<double>(0, (a, e) => a + e.amount);
    final cubit = context.read<SpendingCubit>();
    final initials = initialsOf(name);

    return AppSheet(
      title: name,
      leading: AvatarBadge(initials: initials.isEmpty ? '?' : initials, color: t.category.color, size: 44),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppText(longDate(t.date), size: 12, weight: FontWeight.w500, color: AppColors.muted),
          AppText(context.money(t.amount, sign: true), size: 36, weight: FontWeight.w800, color: t.amount > 0 ? AppColors.pos : AppColors.text),
        ]),
        AppCard(radius: 16, padding: const EdgeInsets.all(14), color: AppColors.cardInner, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppText(t.raw, size: 12, weight: FontWeight.w500, color: AppColors.soft),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const AppText('Type', size: 12, color: AppColors.muted), AppText(t.amount < 0 ? 'Débit' : 'Crédit', size: 13)]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [AppText('${same.length} opérations', size: 12, color: AppColors.muted), AppText('moy. ${context.money(total / same.length)}', size: 13)]),
        ].withGap(8))),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in SpendCategory.values)
            AppChip(
              label: c.label,
              selected: c == t.category,
              tint: c.color,
              dot: c.color,
              onTap: () async {
                final n = await cubit.classify(t.id, c, applyToSimilar: _similar);
                if (widget.toastContext.mounted) showToast(widget.toastContext, n > 1 ? '$n opérations → ${c.label}' : 'Classée en ${c.label}');
              },
            ),
        ]),
        AppButton(
          label: 'Retenir pour les prochains imports',
          background: AppColors.cardInner,
          foreground: AppColors.accent,
          height: 44,
          onPressed: () async {
            final keyword = _ruleKeyword(t.raw, name);
            await cubit.addRule(keyword, t.category);
            if (widget.toastContext.mounted) showToast(widget.toastContext, 'Règle ajoutée : « $keyword » → ${t.category.label}');
          },
        ),
        if (others > 0)
          Row(children: [
            Expanded(child: AppText('Appliquer aux $others autres « $name »', size: 13)),
            AppToggle(value: _similar, onChanged: () => setState(() => _similar = !_similar)),
          ]),
        Row(children: [
          const Expanded(child: AppText('Exclure des statistiques', size: 13)),
          AppToggle(value: t.excluded, onChanged: () => cubit.toggleExcluded(t.id)),
        ]),
        if (others > 0)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const AppText('Historique chez ce marchand', size: 13, color: AppColors.soft),
            for (final e in same.where((e) => e.id != t.id).take(4))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  AppText(shortDate(e.date), size: 13, weight: FontWeight.w500, color: AppColors.muted),
                  AppText(context.money(e.amount, sign: true), size: 13),
                ]),
              ),
          ]),
      ].withGap(14)),
    );
  }
}

String _ruleKeyword(String raw, String merchant) {
  final lower = raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  final full = merchant.toLowerCase();
  return lower.contains(full) ? full : full.split(' ').first;
}
