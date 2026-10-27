import React from 'react';
import { Pressable, View } from 'react-native';
import { CAT } from '../domain/constants';
import { initials, merchant } from '../domain/csv';
import { Transaction } from '../domain/types';
import { useStore } from '../store';
import { C } from '../theme';
import { Avatar, Row, T } from './ui';

export function TransactionRow({ t, onPress }: { t: Transaction; onPress: () => void }) {
  const { money } = useStore();
  const name = merchant(t.raw);
  const cat = CAT[t.cat];
  return (
    <Pressable onPress={onPress} style={{ opacity: t.excl ? 0.4 : 1, minHeight: 56, justifyContent: 'center' }}>
      <Row style={{ gap: 12 }}>
        <Avatar initials={initials(name) || '?'} color={cat.color} />
        <View style={{ flex: 1 }}>
          <T numberOfLines={1}>{name}</T>
          <T size={12} weight="medium" color={t.cat === 'autre' ? C.warn : C.muted}>{cat.label}</T>
        </View>
        <T color={t.amount > 0 ? C.pos : C.text}>{money(t.amount, { sign: true })}</T>
      </Row>
    </Pressable>
  );
}
