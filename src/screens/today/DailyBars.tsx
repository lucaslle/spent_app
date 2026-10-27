import React from 'react';
import { View } from 'react-native';
import { Card, Row, T } from '../../components/ui';
import { Stats } from '../../domain/stats';
import { C } from '../../theme';

export function DailyBars({ s }: { s: Stats }) {
  const max = Math.max(1, ...s.dailyVar);
  return (
    <Card radius={20} style={{ padding: 16 }}>
      <T size={15}>Dépenses variables</T>
      <Row style={{ height: 96, gap: 3, alignItems: 'flex-end', marginTop: 12 }}>
        {s.dailyVar.map((x, i) => {
          const past = i < s.d;
          const h = past ? Math.max((x / max) * 100, x > 0 ? 4 : 2) : 2;
          return <View key={i} style={{ flex: 1, height: `${h}%`, borderRadius: 3, backgroundColor: i === s.d - 1 ? C.accent : past ? C.bar : C.barFuture }} />;
        })}
      </Row>
      <Row style={{ gap: 3, marginTop: 6 }}>
        {s.dailyVar.map((_, i) => (
          <View key={i} style={{ flex: 1, alignItems: 'center', overflow: 'visible' }}>
            <T size={9} weight="semi" color={C.muted} numberOfLines={1} style={{ width: 20, textAlign: 'center' }}>{i === 0 || (i + 1) % 5 === 0 ? String(i + 1) : ''}</T>
          </View>
        ))}
      </Row>
    </Card>
  );
}
