import React, { useMemo } from 'react';
import { ScrollView, TextInput, View } from 'react-native';
import { Icon } from '../components/Icon';
import { TransactionRow } from '../components/TransactionRow';
import { Card, Chip, Row, T } from '../components/ui';
import { CAT, SPEND } from '../domain/constants';
import { merchant } from '../domain/csv';
import { dayLabel } from '../domain/format';
import { Transaction } from '../domain/types';
import { useStore } from '../store';
import { C, FONT } from '../theme';
import { useUi } from '../ui-state';
import { Screen } from './Screen';

const matches = (t: Transaction, f: string) => f === 'all' || (f === 'out' && t.amount < 0) || (f === 'in' && t.amount > 0) || t.cat === f;

export function Transactions() {
  const { tx, stats, money } = useStore();
  const { filter, setFilter, search, setSearch, setSelId } = useUi();
  const review = tx.filter((t) => t.cat === 'autre').length;
  const filters: [string, string][] = [['all', 'Tout'], ['out', 'Dépenses'], ['in', 'Revenus'], ['autre', `À classer · ${review}`], ...SPEND.filter((k) => k !== 'autre').map((k): [string, string] => [k, CAT[k].label])];

  const list = useMemo(() => {
    const q = search.trim().toLowerCase();
    return tx.filter((t) => matches(t, filter) && (!q || `${t.raw} ${merchant(t.raw)} ${CAT[t.cat].label}`.toLowerCase().includes(q)));
  }, [tx, filter, search]);

  const groups = useMemo(() => {
    const out: { date: string; sum: number; items: Transaction[] }[] = [];
    for (const t of list) {
      let g = out[out.length - 1];
      if (!g || g.date !== t.date) out.push((g = { date: t.date, sum: 0, items: [] }));
      g.sum += t.amount;
      g.items.push(t);
    }
    return out;
  }, [list]);

  const label = (date: string) => (stats?.isToday && date === stats.ref ? 'Aujourd’hui' : stats?.isToday && date === stats.yesterday ? 'Hier' : dayLabel(date));
  const out = list.filter((t) => t.amount < 0).reduce((a, t) => a + t.amount, 0);

  const sticky = (
    <View style={{ gap: 10, marginTop: 8 }}>
      <Row style={{ height: 44, borderRadius: 14, backgroundColor: C.card, paddingHorizontal: 12, gap: 8 }}>
        <Icon name="search" size={18} color={C.muted} />
        <TextInput value={search} onChangeText={setSearch} placeholder="Rechercher" placeholderTextColor={C.faint} style={{ flex: 1, color: C.text, fontFamily: FONT.medium, fontSize: 14 }} />
      </Row>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={{ gap: 8 }}>
        {filters.map(([id, text]) => (
          <Chip key={id} label={text} on={filter === id} dot={id !== 'autre' && CAT[id as keyof typeof CAT] ? CAT[id as keyof typeof CAT].color : undefined} onPress={() => setFilter(id)} />
        ))}
      </ScrollView>
    </View>
  );

  return (
    <Screen title="Opérations" sticky={sticky}>
      <T size={12} weight="semi" color={C.muted}>{list.length} opérations · {money(out)}</T>
      {groups.length ? (
        groups.map((g) => (
          <Card key={g.date} radius={20} style={{ paddingVertical: 6, paddingHorizontal: 14 }}>
            <Row style={{ justifyContent: 'space-between', paddingTop: 8 }}>
              <T size={12} color={C.muted}>{label(g.date)}</T>
              <T size={12} color={C.muted}>{money(g.sum, { sign: true })}</T>
            </Row>
            {g.items.map((t) => <TransactionRow key={t.id} t={t} onPress={() => setSelId(t.id)} />)}
          </Card>
        ))
      ) : (
        <T color={C.muted} weight="medium" style={{ textAlign: 'center', marginTop: 24 }}>Aucun résultat.</T>
      )}
    </Screen>
  );
}
