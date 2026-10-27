import React from 'react';
import { Pressable, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { C } from '../theme';
import { Icon, IconName } from './Icon';
import { T } from './ui';

export type TabId = 'today' | 'tx' | 'budget' | 'stats' | 'settings';
const TABS: [TabId, string][] = [['today', 'Jour'], ['tx', 'Opérations'], ['budget', 'Budget'], ['stats', 'Analyse'], ['settings', 'Réglages']];

export function TabBar({ tab, onChange }: { tab: TabId; onChange: (t: TabId) => void }) {
  const { bottom } = useSafeAreaInsets();
  return (
    <View style={{ position: 'absolute', left: 16, right: 16, bottom: Math.max(bottom, 12) + 8, height: 64, borderRadius: 24, backgroundColor: C.tabBar, borderWidth: 1, borderColor: C.line, flexDirection: 'row' }}>
      {TABS.map(([id, label]) => {
        const color = tab === id ? C.accent : C.muted;
        return (
          <Pressable key={id} onPress={() => onChange(id)} style={{ flex: 1, alignItems: 'center', justifyContent: 'center', gap: 3 }}>
            <Icon name={id as IconName} color={color} />
            <T size={10} color={color}>{label}</T>
          </Pressable>
        );
      })}
    </View>
  );
}
