import React from 'react';
import { Pressable, View } from 'react-native';
import { SegmentedRing } from '../../components/Charts';
import { Card, Row, T } from '../../components/ui';
import { CAT } from '../../domain/constants';
import { Stats } from '../../domain/stats';
import { useStore } from '../../store';
import { C } from '../../theme';
import { useUi } from '../../ui-state';

export function BudgetCard({ s }: { s: Stats }) {
  const { money } = useStore();
  const { donutSel, setDonutSel, setTab } = useUi();
  const segs = s.cats.filter((c) => c.amount > 0).map((c) => ({ id: c.id, color: CAT[c.id].color, value: c.amount }));
  const sel = s.cats.find((c) => c.id === donutSel && c.amount > 0);
  const pick = (id: string) => setDonutSel(donutSel === id ? null : id);
  const pct = Math.round((s.spent / s.budgetTotal) * 100);
  return (
    <Card>
      <Row style={{ gap: 16 }}>
        <View style={{ width: 124, height: 124 }}>
          <SegmentedRing size={124} r={52} stroke={11} gap={3} denom={Math.max(s.budgetTotal, s.spent)} segments={segs} selected={sel?.id} selectedStroke={15} onSelect={pick} />
          <Pressable onPress={() => setTab('budget')} style={{ position: 'absolute', top: 24, left: 24, right: 24, bottom: 24, alignItems: 'center', justifyContent: 'center' }}>
            <T size={9} color={sel ? CAT[sel.id].color : C.muted} numberOfLines={1}>{sel ? CAT[sel.id].label.toUpperCase() : 'BUDGET'}</T>
            <T size={20} weight="extra">{sel ? money(sel.amount, { dec: 0 }) : `${pct} %`}</T>
            <T size={10} weight="semi" color={C.muted}>{sel ? `${Math.round(sel.ratio * 100)} % du budget` : `J${s.d}/${s.days}`}</T>
          </Pressable>
        </View>
        <View style={{ flex: 1, gap: 8 }}>
          <View>
            <T size={12} weight="semi" color={C.muted}>Reste ce mois</T>
            <T size={24} weight="extra" color={s.remaining < 0 ? C.neg : C.text}>{money(s.remaining, { dec: 0 })}</T>
          </View>
          <Row style={{ gap: 14 }}>
            <View>
              <T size={11} weight="semi" color={C.muted}>Par jour</T>
              <T>{money(Math.max(s.perDay, 0), { dec: 0 })}</T>
            </View>
            <View>
              <T size={11} weight="semi" color={C.muted}>Dépensé</T>
              <T>{money(s.spent, { dec: 0 })}</T>
            </View>
          </Row>
        </View>
      </Row>
    </Card>
  );
}
