import React, { useState } from 'react';
import { TextInput, View, Pressable } from 'react-native';
import { AreaLine } from '../components/Charts';
import { Sheet } from '../components/Sheet';
import { Avatar, Button, Card, Chip, Row, T } from '../components/ui';
import { accountHistory, accountTotal, groupTotal, saveAccount, sparkline, totalSeries } from '../domain/accounts';
import { ACCOUNT_TYPE, ACCOUNT_TYPES } from '../domain/constants';
import { initials } from '../domain/csv';
import { pctS, shortDate } from '../domain/format';
import { parseNum } from '../domain/format';
import { AccountTypeId } from '../domain/types';
import { useStore } from '../store';
import { C, FONT } from '../theme';
import { useUi } from '../ui-state';

type Form = { id: string | null; type: AccountTypeId; name: string; balance: string };
const input = { height: 48, borderRadius: 14, backgroundColor: C.cardInner, paddingHorizontal: 14, color: C.text, fontFamily: FONT.bold, fontSize: 15 } as const;

export function AccountsSheet() {
  const { accounts, commit, money, showToast } = useStore();
  const { accOpen, setAccOpen } = useUi();
  const [form, setForm] = useState<Form | null>(null);
  const [armed, setArmed] = useState(false);

  const close = () => { setAccOpen(false); setForm(null); setArmed(false); };
  const total = accountTotal(accounts);
  const series = totalSeries(accounts);
  const spark = sparkline(series, 300, 90);
  const delta = series.length ? total - series[0].v : 0;

  const bal = form ? parseNum(form.balance) : NaN;
  const save = () => {
    if (!form || isNaN(bal)) return;
    commit({ accounts: saveAccount(accounts, form, bal) });
    showToast(form.id ? 'Compte mis à jour' : 'Compte ajouté');
    setForm(null);
  };
  const remove = () => {
    if (!form?.id) return;
    if (!armed) return setArmed(true);
    commit({ accounts: accounts.filter((a) => a.id !== form.id) });
    showToast('Compte supprimé');
    setForm(null);
    setArmed(false);
  };

  if (form) {
    const acc = form.id ? accounts.find((a) => a.id === form.id) : undefined;
    const hist = acc ? accountHistory(acc) : [];
    const sp = sparkline(hist.map((h) => ({ d: h.date, v: h.balance })), 300, 60);
    return (
      <Sheet visible={accOpen} title={form.id ? 'Modifier le compte' : 'Nouveau compte'} onClose={close}>
        <View style={{ gap: 14 }}>
          <Row style={{ flexWrap: 'wrap', gap: 8 }}>
            {ACCOUNT_TYPES.map((t) => <Chip key={t.id} label={t.label} on={form.type === t.id} color={t.color} onPress={() => setForm({ ...form, type: t.id })} />)}
          </Row>
          <TextInput value={form.name} onChangeText={(name) => setForm({ ...form, name })} placeholder={ACCOUNT_TYPE[form.type].label} placeholderTextColor={C.faint} style={input} />
          <TextInput value={form.balance} onChangeText={(balance) => setForm({ ...form, balance })} placeholder="Solde (€)" placeholderTextColor={C.faint} keyboardType="decimal-pad" style={input} />
          {hist.length > 1 ? (
            <Card radius={16} style={{ padding: 14, backgroundColor: C.cardInner, gap: 8 }}>
              <AreaLine width={300} height={60} line={sp.line} area={sp.area} dot={sp} />
              {hist.slice().reverse().slice(0, 6).map((h, i, arr) => {
                const prev = arr[i + 1];
                const d = prev ? h.balance - prev.balance : 0;
                return (
                  <Row key={h.date} style={{ justifyContent: 'space-between' }}>
                    <T size={12} weight="medium" color={C.muted}>{shortDate(h.date)} {h.date.slice(0, 4)}</T>
                    <T size={12}>{money(h.balance)}</T>
                    <T size={12} color={d > 0 ? C.pos : d < 0 ? C.neg : C.muted}>{prev ? money(d, { sign: true, dec: 0 }) : '—'}</T>
                  </Row>
                );
              })}
            </Card>
          ) : null}
          <Button label={form.id ? 'Mettre à jour le solde' : 'Ajouter le compte'} onPress={save} disabled={isNaN(bal)} bg={isNaN(bal) ? C.line : C.accent} fg={isNaN(bal) ? C.muted : C.accentInk} style={{ minHeight: 54, borderRadius: 18 }} />
          {form.id ? <Button label={armed ? 'Confirmer la suppression' : 'Supprimer ce compte'} bg={armed ? C.neg : 'transparent'} fg={armed ? C.accentInk : C.neg} border={C.neg} onPress={remove} /> : null}
          <Button label="Annuler" bg="transparent" fg={C.muted} onPress={() => { setForm(null); setArmed(false); }} />
        </View>
      </Sheet>
    );
  }

  const groups: [string, number][] = [['Courant', groupTotal(accounts, 'cash')], ['Épargne', groupTotal(accounts, 'save')], ['Investi', groupTotal(accounts, 'inv')]];
  return (
    <Sheet visible={accOpen} title="Mes comptes" onClose={close}>
      <View style={{ gap: 14 }}>
        <T size={32} weight="extra">{money(total)}</T>
        <Row style={{ gap: 3, height: 8 }}>
          {accounts.filter((a) => a.balance > 0).map((a) => <View key={a.id} style={{ flex: a.balance, height: 8, borderRadius: 4, backgroundColor: ACCOUNT_TYPE[a.type].color }} />)}
        </Row>
        <Row>{groups.map(([l, v]) => <View key={l} style={{ flex: 1 }}><T size={11} weight="semi" color={C.muted}>{l}</T><T>{money(v, { dec: 0 })}</T></View>)}</Row>
        {series.length > 1 ? (
          <Card radius={16} style={{ padding: 14, backgroundColor: C.cardInner, gap: 8 }}>
            <Row style={{ justifyContent: 'space-between' }}>
              <T size={13}>Évolution</T>
              <T size={12} color={delta >= 0 ? C.pos : C.neg}>{money(delta, { sign: true, dec: 0 })} · {series[0].v ? pctS(delta / series[0].v) : ''}</T>
            </Row>
            <AreaLine width={300} height={90} line={spark.line} area={spark.area} dot={spark} />
            <Row style={{ justifyContent: 'space-between' }}>
              <T size={10} weight="semi" color={C.muted}>{shortDate(series[0].d)}</T>
              <T size={10} weight="semi" color={C.muted}>{shortDate(series[series.length - 1].d)}</T>
            </Row>
          </Card>
        ) : null}
        {accounts.slice().sort((a, b) => b.balance - a.balance).map((a) => {
          const t = ACCOUNT_TYPE[a.type];
          const h = accountHistory(a);
          const d = h.length > 1 ? a.balance - h[h.length - 2].balance : null;
          return (
            <Pressable key={a.id} onPress={() => setForm({ id: a.id, type: a.type, name: a.name, balance: String(a.balance).replace('.', ',') })} style={{ minHeight: 56, justifyContent: 'center' }}>
              <Row style={{ gap: 12 }}>
                <Avatar initials={initials(a.name) || t.label[0]} color={t.color} />
                <View style={{ flex: 1 }}>
                  <T numberOfLines={1}>{a.name}</T>
                  <T size={12} weight="medium" color={C.muted}>{t.label} · Màj {shortDate(a.updated)}</T>
                </View>
                <View style={{ alignItems: 'flex-end' }}>
                  <T>{money(a.balance)}</T>
                  <T size={11} weight="semi" color={d == null ? C.muted : d > 0 ? C.pos : d < 0 ? C.neg : C.muted}>{d == null ? '1er relevé' : `${money(d, { sign: true, dec: 0 })} depuis ${shortDate(h[h.length - 2].date)}`}</T>
                </View>
              </Row>
            </Pressable>
          );
        })}
        <Button label="+ Ajouter un compte" onPress={() => setForm({ id: null, type: 'livreta', name: '', balance: '' })} style={{ minHeight: 54, borderRadius: 18 }} />
      </View>
    </Sheet>
  );
}
