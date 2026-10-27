import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Charts/area_sparkline.dart';
import '../../../../technical/Formatting/amount_privacy_cubit.dart';
import '../../../../technical/Formatting/formatters.dart';
import '../../../../technical/Theme/app_button.dart';
import '../../../../technical/Theme/app_card.dart';
import '../../../../technical/Theme/app_chip.dart';
import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/app_sheet.dart';
import '../../../../technical/Theme/app_text.dart';
import '../../../../technical/Theme/app_toast.dart';
import '../../../../technical/Theme/avatar_badge.dart';
import '../../../../technical/Theme/row_gap.dart';
import '../../domain/account_math.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../cubit/accounts_cubit.dart';
import '../widgets/account_series.dart';
import '../widgets/wealth_card.dart';

Future<void> showAccountsSheet(BuildContext context) => showAppSheet(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [BlocProvider.value(value: context.read<AccountsCubit>()), BlocProvider.value(value: context.read<AmountPrivacyCubit>())],
        child: _AccountsSheet(toastContext: context),
      ),
    );

class _AccountsSheet extends StatefulWidget {
  const _AccountsSheet({required this.toastContext});

  final BuildContext toastContext;

  @override
  State<_AccountsSheet> createState() => _AccountsSheetState();
}

class _AccountsSheetState extends State<_AccountsSheet> {
  bool _editing = false;
  String? _id;
  AccountType _type = AccountType.livreta;
  bool _armed = false;
  final _name = TextEditingController();
  final _balance = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  void _open(Account? a) => setState(() {
        _editing = true;
        _armed = false;
        _id = a?.id;
        _type = a?.type ?? AccountType.livreta;
        _name.text = a?.name ?? '';
        _balance.text = a == null ? '' : a.balance.toString().replaceFirst('.', ',');
      });

  void _toast(String m) {
    if (widget.toastContext.mounted) showToast(widget.toastContext, m);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountsCubit>().state;
    return _editing ? _form(accounts) : _list(accounts);
  }

  Widget _list(List<Account> accounts) {
    final total = accountTotal(accounts);
    final series = totalSeries(accounts);
    final delta = series.isEmpty ? 0.0 : total - series.first.value;
    final sorted = [...accounts]..sort((a, b) => b.balance.compareTo(a.balance));
    return AppSheet(
      title: 'Mes comptes',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppText(context.money(total), size: 32, weight: FontWeight.w800),
        AccountBreakdownBar(accounts: accounts),
        Row(children: [
          for (final (label, g) in [('Courant', AccountGroup.cash), ('Épargne', AccountGroup.save), ('Investi', AccountGroup.invest)])
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [AppText(label, size: 11, weight: FontWeight.w600, color: AppColors.muted), AppText(context.money(groupTotal(accounts, g), decimals: 0))])),
        ]),
        if (series.length > 1)
          AppCard(radius: 16, padding: const EdgeInsets.all(14), color: AppColors.cardInner, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const AppText('Évolution', size: 13),
              AppText('${context.money(delta, sign: true, decimals: 0)} · ${series.first.value > 0 ? formatPercentSigned(delta / series.first.value) : ''}', size: 12, color: delta >= 0 ? AppColors.pos : AppColors.neg),
            ]),
            AreaSparkline(points: sparkPointsOfSeries(series), height: 90),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              AppText(shortDate(series.first.date), size: 10, weight: FontWeight.w600, color: AppColors.muted),
              AppText(shortDate(series.last.date), size: 10, weight: FontWeight.w600, color: AppColors.muted),
            ]),
          ].withGap(8))),
        for (final a in sorted) _row(a),
        AppButton(label: '+ Ajouter un compte', height: 54, radius: 18, onPressed: () => _open(null)),
      ].withGap(14)),
    );
  }

  Widget _row(Account a) {
    final h = a.effectiveHistory;
    final d = h.length > 1 ? a.balance - h[h.length - 2].balance : null;
    final initials = a.name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(a),
      child: SizedBox(
        height: 56,
        child: Row(children: [
          AvatarBadge(initials: initials.isEmpty ? a.type.label[0] : initials, color: a.type.color),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            AppText(a.name, maxLines: 1),
            AppText('${a.type.label} · Màj ${shortDate(a.updated)}', size: 12, weight: FontWeight.w500, color: AppColors.muted, maxLines: 1),
          ])),
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            AppText(context.money(a.balance)),
            AppText(d == null ? '1er relevé' : '${context.money(d, sign: true, decimals: 0)} depuis ${shortDate(h[h.length - 2].date)}', size: 11, weight: FontWeight.w600, color: d == null || d == 0 ? AppColors.muted : (d > 0 ? AppColors.pos : AppColors.neg)),
          ]),
        ]),
      ),
    );
  }

  Widget _form(List<Account> accounts) {
    final acc = _id == null ? null : accounts.where((a) => a.id == _id).firstOrNull;
    final hist = acc?.effectiveHistory ?? const <BalancePoint>[];
    final bal = parseAmount(_balance.text);
    final valid = bal != null;
    return AppSheet(
      title: _id == null ? 'Nouveau compte' : 'Modifier le compte',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in AccountType.values) AppChip(label: t.label, selected: _type == t, tint: t.color, onTap: () => setState(() => _type = t)),
        ]),
        _field(_name, _type.label, TextInputType.text),
        _field(_balance, 'Solde (€)', const TextInputType.numberWithOptions(decimal: true)),
        if (hist.length > 1)
          AppCard(radius: 16, padding: const EdgeInsets.all(14), color: AppColors.cardInner, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            AreaSparkline(points: sparkPointsOfHistory(hist), height: 60),
            for (var i = hist.length - 1; i >= 0 && i >= hist.length - 6; i--)
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                AppText('${shortDate(hist[i].date)} ${hist[i].date.substring(0, 4)}', size: 12, weight: FontWeight.w500, color: AppColors.muted),
                AppText(context.money(hist[i].balance), size: 12),
                AppText(i == 0 ? '—' : context.money(hist[i].balance - hist[i - 1].balance, sign: true, decimals: 0), size: 12, color: i == 0 || hist[i].balance == hist[i - 1].balance ? AppColors.muted : (hist[i].balance > hist[i - 1].balance ? AppColors.pos : AppColors.neg)),
              ]),
          ].withGap(8))),
        AppButton(
          label: _id == null ? 'Ajouter le compte' : 'Mettre à jour le solde',
          height: 54,
          radius: 18,
          background: valid ? AppColors.accent : AppColors.line,
          foreground: valid ? AppColors.accentInk : AppColors.muted,
          onPressed: !valid
              ? null
              : () async {
                  await context.read<AccountsCubit>().save(id: _id, type: _type, name: _name.text, balance: bal);
                  _toast(_id == null ? 'Compte ajouté' : 'Compte mis à jour');
                  if (mounted) setState(() => _editing = false);
                },
        ),
        if (_id != null)
          AppButton(
            label: _armed ? 'Confirmer la suppression' : 'Supprimer ce compte',
            background: _armed ? AppColors.neg : Colors.transparent,
            foreground: _armed ? AppColors.accentInk : AppColors.neg,
            borderColor: AppColors.neg,
            onPressed: () async {
              if (!_armed) return setState(() => _armed = true);
              await context.read<AccountsCubit>().remove(_id!);
              _toast('Compte supprimé');
              if (mounted) setState(() => _editing = false);
            },
          ),
        AppButton(label: 'Annuler', background: Colors.transparent, foreground: AppColors.muted, onPressed: () => setState(() => _editing = false)),
      ].withGap(14)),
    );
  }

  Widget _field(TextEditingController c, String hint, TextInputType type) => TextField(
        controller: c,
        keyboardType: type,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.text),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cardInner,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.faint),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      );
}
