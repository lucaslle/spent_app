import React from 'react';
import { Pressable, View } from 'react-native';
import { Avatar, Bar, Card, Row, T } from '../components/ui';
import { CAT, FIXED } from '../domain/constants';
import { cap } from '../domain/format';
import { MOIS } from '../domain/constants';
import { CatStat } from '../domain/stats';
import { useStore } from '../store';
import { C } from '../theme';
import { Screen } from './Screen';

function Stepper({ value, onChange }: { value: number; onChange: (v: number) => void }) {
  const { money } = useStore();
  const btn = (label: string, next: number) => (
    <Pressable onPress={() => onChange(Math.max(0, next))} hitSlop={8} style={{ width: 30, height: 28, alignItems: 'center', justifyContent: 'center' }}>
      <T size={18} color={C.accent}>{label}</T>
    </Pressable>
  );
  return (
    <Row style={{ backgroundColor: C.stepper, borderRadius: 10, gap: 4 }}>
      {btn('−', value - 10)}
      <T size={13} style={{ minWidth: 64, textAlign: 'center' }}>{money(value, { dec: 0 })}</T>
      {btn('+', value + 10)}
    </Row>
  );
}

function CategoryCard({ c, pace }: { c: CatStat; pace: number }) {
  const { money, budgets, commit } = useStore();
  const cat = CAT[c.id];
  const color = c.over ? C.neg : c.ratio > pace * 1.15 && !FIXED.includes(c.id) ? C.warn : cat.color;
  return (
    <Card radius={20} style={{ padding: 16, gap: 10 }}>
      <Row style={{ gap: 12 }}>
        <Avatar initials={cat.label.slice(0, 2)} color={cat.color} size={36} />
        <View style={{ flex: 1 }}>
          <T>{cat.label}</T>
          <T size={12} weight="medium" color={c.over ? C.neg : C.muted}>{c.over ? `Dépassé de ${money(c.amount - c.budget, { dec: 0 })}` : `Reste ${money(c.budget - c.amount, { dec: 0 })}`}</T>
        </View>
        <View style={{ alignItems: 'flex-end' }}>
          <T>{money(c.amount)}</T>
          <T size={12} weight="medium" color={C.muted}>{c.budget ? `${Math.round(c.ratio * 100)} %` : '—'}</T>
        </View>
      </Row>
      <Bar pct={c.ratio * 100} color={color} mark={{ at: pace * 100, color: C.faint }} />
      <Row style={{ justifyContent: 'space-between' }}>
        <T size={12} weight="semi" color={C.muted}>Budget mensuel</T>
        <Stepper value={c.budget} onChange={(v) => commit({ budgets: { ...budgets, [c.id]: v } })} />
      </Row>
    </Card>
  );
}

export function Budget() {
  const { stats: s, money } = useStore();
  if (!s) return <Screen title="Budget"><T color={C.muted} weight="medium">Importez un relevé pour suivre votre budget.</T></Screen>;
  const pace = s.d / s.days;
  const over = s.projection > s.budgetTotal;
  return (
    <Screen eyebrow={`${cap(MOIS[s.m - 1])} ${s.y}`} title="Budget">
      <Card>
        <Row style={{ justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <View>
            <T size={13} weight="semi" color={C.soft}>Dépensé sur {money(s.budgetTotal, { dec: 0 })}</T>
            <T size={30} weight="extra">{money(s.spent)}</T>
          </View>
          <View style={{ alignItems: 'flex-end' }}>
            <T size={11} weight="semi" color={C.muted}>Fin estimée</T>
            <T size={15} color={over ? C.neg : C.pos}>{money(s.projection, { dec: 0 })}</T>
          </View>
        </Row>
        <View style={{ marginTop: 14 }}>
          <Bar pct={(s.spent / s.budgetTotal) * 100} color={s.spent > s.budgetTotal ? C.neg : C.accent} height={12} mark={{ at: pace * 100, color: '#fff', width: 3 }} />
        </View>
      </Card>
      {s.cats.map((c) => <CategoryCard key={c.id} c={c} pace={pace} />)}
    </Screen>
  );
}
