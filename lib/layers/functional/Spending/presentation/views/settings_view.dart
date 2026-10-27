import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Security/app_lock_cubit.dart';
import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/app_toast.dart';
import '../../../../technical/Theme/app_toggle.dart';
import '../../../../technical/Theme/screen_scaffold.dart';
import '../../domain/entities/spend_category.dart';
import '../cubit/spending_cubit.dart';
import 'import_sheet.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _armed = false;

  Future<void> _clear() async {
    if (!_armed) {
      setState(() => _armed = true);
      return;
    }
    await context.read<SpendingCubit>().clearAll();
    if (!mounted) return;
    setState(() => _armed = false);
    showToast(context, 'Données effacées');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SpendingCubit>().state;
    final hide = context.watch<AmountPrivacyCubit>().state;
    final lock = context.watch<AppLockCubit>().state;
    final cubit = context.read<SpendingCubit>();
    return ScreenScaffold(
      eyebrow: 'Préférences',
      title: 'Réglages',
      children: [
        AppCard(
          radius: 20,
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const AppText('Dernier import', size: 12, weight: FontWeight.w600, color: AppColors.muted),
                AppText(state.lastImport, maxLines: 2),
              ])),
              const SizedBox(width: 12),
              SizedBox(width: 110, child: AppButton(label: 'Importer', height: 40, onPressed: () => showImportSheet(context))),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const AppText('Opérations', size: 13, weight: FontWeight.w600, color: AppColors.muted),
              AppText('${state.entries.length}'),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const AppText('Flouter les montants'),
              AppToggle(value: hide, onChanged: context.read<AmountPrivacyCubit>().toggle),
            ]),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const AppText('Verrouillage biométrique'),
                if (!lock.available) const AppText('Aucun verrouillage d’écran configuré sur cet appareil', size: 12, weight: FontWeight.w500, color: AppColors.muted),
              ])),
              Opacity(opacity: lock.available ? 1 : 0.4, child: AppToggle(value: lock.protectionActive, onChanged: () => context.read<AppLockCubit>().setEnabled(!lock.enabled))),
            ]),
          ]),
        ),
        AppCard(
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const AppText('Catégorisation automatique', size: 15),
            for (final c in SpendCategory.values)
              SizedBox(
                height: 40,
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: AppText(c.label, size: 13)),
                  AppText(c.keywords.isEmpty ? 'Manuel' : '${c.keywords.length} mots-clés', size: 12, weight: FontWeight.w500, color: AppColors.muted),
                  SizedBox(width: 56, child: AppText('${state.entries.where((t) => t.category == c).length} op.', size: 12, weight: FontWeight.w500, color: AppColors.muted, align: TextAlign.right)),
                ]),
              ),
          ]),
        ),
        AppButton(label: 'Réinitialiser les budgets', background: AppColors.card, foreground: AppColors.text, onPressed: () {
          cubit.resetBudgets();
          showToast(context, 'Budgets réinitialisés');
        }),
        AppButton(
          label: _armed ? 'Confirmer : tout effacer' : 'Effacer les données',
          background: _armed ? AppColors.neg : Colors.transparent,
          foreground: _armed ? AppColors.accentInk : AppColors.neg,
          borderColor: AppColors.neg,
          onPressed: _clear,
        ),
      ],
    );
  }
}
