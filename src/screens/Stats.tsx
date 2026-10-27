import React from 'react';
import { Pressable, View } from 'react-native';
import { CumulChart, SegmentedRing } from '../components/Charts';
import { Avatar, Bar, Button, Card, Row, T } from '../components/ui';
import { CAT, MC, MOIS } from '../domain/constants';
import { initials } from '../domain/csv';
import { cap, pctS } from '../domain/format';
import { Stats as StatsData } from '../domain/stats';
import { useStore } from '../store';
import { C } from '../theme';
import { useUi } from '../ui-state';
import { Screen } from './Screen';

function Breakdown({ s }: { s: StatsData }) {
  const { money } = useStore();
  const { donutSel, setDonutSel, showTx } = useUi();
  const cats = s.cats.filter((c) => c.amount > 0);
  const sel = cats.find((c) => c.id === donutSel);
  return (
    <Card>
      <T size={15}>Répartition</T>
      <Row style={{ gap: 16, marginTop: 12, alignItems: 'flex-start' }}>
        <View style={{ width: 120, height: 120 }}>
          <SegmentedRing size={120} r={42} stroke={16} gap={2} denom={s.spent} segments={cats.map((c) => ({ id: c.id, color: CAT[c.id].color, value: c.amount }))} selected={sel?.id} selectedStroke={20} onSelect={(id) => setDonutSel(donutSel === id ? null : id)} />
          <View pointerEvents="none" style={{ position: 'absolute', top: 30, left: 30, right: 30, bottom: 30, alignItems: 'center', justifyContent: 'center' }}>
            <T size={15} weight="extra">{money(sel ? sel.amount : s.spent, { dec: 0 })}</T>
            <T size={9} weight="semi" color={C.muted} numberOfLines={1}>{sel ? CAT[sel.id].label : 'ce mois'}</T>
          </View>
        </View>
        <View style={{ flex: 1, gap: 2 }}>
          {cats.map((c) => (
            <Pressable key={c.id} onPress={() => setDonutSel(donutSel === c.id ? null : c.id)} style={{ opacity: sel && sel.id !== c.id ? 0.3 : 1, minHeight: 26, justifyContent: 'center' }}>
              <Row style={{ gap: 6 }}>
                <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: CAT[c.id].color }} />
                <T size={12} weight="semi" style={{ flex: 1 }} numberOfLines={1}>{CAT[c.id].label}</T>
                <T size={12} color={C.muted}>{Math.round((c.amount / s.spent) * 100)}{' '}%</T>
              </Row>
            </Pressable>
          ))}
        </View>
      </Row>
      {sel ? <Button label="Voir les opérations ›" bg="transparent" fg={CAT[sel.id].color} border={CAT[sel.id].color} style={{ marginTop: 12 }} onPress={() => { const id = sel.id; setDonutSel(null); showTx(id); }} /> : null}
    </Card>
  );
}

function Cumul({ s }: { s: StatsData }) {
  const { money } = useStore();
  return (
    <Card>
      <Row style={{ justifyContent: 'space-between' }}>
        <T size={15}>Cumul vs {MC[s.prevMonth - 1]}</T>
        <T size={12} color={s.vsPrev > 0.05 ? C.neg : C.pos}>{pctS(s.vsPrev)} à date</T>
      </Row>
      <View style={{ marginTop: 12 }}><CumulChart s={s} /></View>
      <Row style={{ gap: 14, marginTop: 8, flexWrap: 'wrap' }}>
        <T size={11} weight="semi" color={C.accent}>— {money(s.spent, { dec: 0 })}</T>
        <T size={11} weight="semi" color={C.prev}>— {MC[s.prevMonth - 1]} {money(s.prevTotal, { dec: 0 })}</T>
        <T size={11} weight="semi" color={C.neg}>- - budget</T>
      </Row>
    </Card>
  );
}

export function StatsScreen() {
  const { stats: s, money } = useStore();
  if (!s) return <Screen title="Analyse"><T color={C.muted} weight="medium">Importez un relevé pour voir vos analyses.</T></Screen>;
  const net = s.income - s.spent;
  const tiles: [string, string, string][] = [['Revenus', money(s.income, { sign: true, dec: 0 }), C.pos], ['Dépenses', money(-s.spent, { dec: 0 }), C.text], ['Solde', money(net, { sign: true, dec: 0 }), net >= 0 ? C.pos : C.neg]];
  const wmax = Math.max(1, ...s.weekdays);
  const mmax = Math.max(1, ...s.months.flatMap((m) => [m.income, m.out]));
  return (
    <Screen eyebrow={`${cap(MOIS[s.m - 1])} ${s.y}`} title="Analyse">
      <Breakdown s={s} />
      <Cumul s={s} />
      <Row style={{ gap: 12 }}>
        {tiles.map(([l, v, color]) => (
          <Card key={l} radius={20} style={{ flex: 1, padding: 14 }}>
            <T size={11} weight="semi" color={C.muted}>{l}</T>
            <T size={15} weight="extra" color={color} numberOfLines={1} adjustsFontSizeToFit>{v}</T>
          </Card>
        ))}
      </Row>
      <Card radius={20} style={{ padding: 16, gap: 12 }}>
        <T size={15}>Où va votre argent</T>
        {s.merchants.map((m, i) => (
          <Row key={m.name} style={{ gap: 12 }}>
            <Avatar initials={initials(m.name) || String(i + 1)} color={CAT[m.cat].color} />
            <View style={{ flex: 1, gap: 6 }}>
              <Row style={{ justifyContent: 'space-between' }}>
                <T numberOfLines={1} style={{ flexShrink: 1 }}>{m.name}</T>
                <T>{money(m.amount)}</T>
              </Row>
              <Bar pct={(m.amount / s.merchants[0].amount) * 100} color={CAT[m.cat].color} height={5} />
            </View>
          </Row>
        ))}
      </Card>
      <Card radius={20} style={{ padding: 16 }}>
        <T size={15}>Jour type</T>
        <Row style={{ height: 110, gap: 8, alignItems: 'flex-end', marginTop: 12 }}>
          {s.weekdays.map((x, i) => (
            <View key={i} style={{ flex: 1, height: '100%', justifyContent: 'flex-end', alignItems: 'center', gap: 4 }}>
              <T size={9} weight="semi" color={C.muted} numberOfLines={1}>{money(x, { dec: 0 })}</T>
              <View style={{ width: '100%', height: `${(x / wmax) * 70}%`, minHeight: 3, borderRadius: 4, backgroundColor: x === wmax ? C.accent : C.bar }} />
              <T size={11} weight="semi" color={C.muted}>{'LMMJVSD'[i]}</T>
            </View>
          ))}
        </Row>
      </Card>
      <Card radius={20} style={{ padding: 16, gap: 12 }}>
        <T size={15}>Entrées et sorties</T>
        {s.months.map((m) => (
          <View key={m.key} style={{ gap: 4 }}>
            <Row style={{ justifyContent: 'space-between' }}>
              <T size={12} color={C.muted}>{cap(MC[m.month - 1])}</T>
              <T size={12} color={m.income - m.out >= 0 ? C.pos : C.neg}>{money(m.income - m.out, { sign: true, dec: 0 })}</T>
            </Row>
            <Bar pct={(m.income / mmax) * 100} color={C.pos} height={6} />
            <Bar pct={(m.out / mmax) * 100} color={C.prev} height={6} />
          </View>
        ))}
      </Card>
    </Screen>
  );
}
