import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_chip.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_sheet.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/app_toast.dart';
import '../../../../technical/Theme/row_gap.dart';
import '../../domain/entities/spend_category.dart';
import '../cubit/spending_cubit.dart';

Future<void> showRuleSheet(BuildContext context) => showAppSheet(
      context,
      builder: (_) => BlocProvider.value(value: context.read<SpendingCubit>(), child: _RuleSheet(toastContext: context)),
    );

class _RuleSheet extends StatefulWidget {
  const _RuleSheet({required this.toastContext});

  final BuildContext toastContext;

  @override
  State<_RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends State<_RuleSheet> {
  final _keyword = TextEditingController();
  SpendCategory? _category = SpendCategory.alim;
  bool _ignore = false;

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final changed = await context.read<SpendingCubit>().addRule(_keyword.text, _ignore ? null : _category);
    if (widget.toastContext.mounted) showToast(widget.toastContext, changed > 0 ? 'Règle ajoutée · $changed opérations mises à jour' : 'Règle ajoutée');
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _keyword.text.trim().isNotEmpty;
    return AppSheet(
      title: 'Nouvelle règle',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const AppText('Si le libellé contient…', size: 13, color: AppColors.soft),
        TextField(
          controller: _keyword,
          onChanged: (_) => setState(() {}),
          autofocus: true,
          style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardInner,
            hintText: 'ex. envoi wero',
            hintStyle: const TextStyle(color: AppColors.faint),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
        const AppText('…alors', size: 13, color: AppColors.soft),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in SpendCategory.values)
            AppChip(label: c.label, selected: !_ignore && _category == c, tint: c.color, dot: c.color, onTap: () => setState(() {
                  _ignore = false;
                  _category = c;
                })),
          AppChip(label: 'Ignorer (exclure des stats)', selected: _ignore, tint: AppColors.muted, onTap: () => setState(() => _ignore = true)),
        ]),
        AppButton(
          label: 'Ajouter la règle',
          height: 54,
          radius: 18,
          background: valid ? AppColors.accent : AppColors.line,
          foreground: valid ? AppColors.accentInk : AppColors.muted,
          onPressed: valid ? _save : null,
        ),
      ].withGap(14)),
    );
  }
}
