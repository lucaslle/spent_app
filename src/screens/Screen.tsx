import React from 'react';
import { ScrollView, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { T } from '../components/ui';
import { C } from '../theme';

export function Screen({ eyebrow, title, children, header, sticky }: { eyebrow?: string; title: string; children: React.ReactNode; header?: React.ReactNode; sticky?: React.ReactNode }) {
  const { top } = useSafeAreaInsets();
  return (
    <ScrollView
      style={{ flex: 1, backgroundColor: C.bg }}
      contentContainerStyle={{ paddingTop: top + 8, paddingHorizontal: 16, paddingBottom: 130, gap: 12 }}
      stickyHeaderIndices={sticky ? [0] : undefined}
      showsVerticalScrollIndicator={false}
      keyboardShouldPersistTaps="handled"
    >
      <View style={{ backgroundColor: C.bg, paddingBottom: sticky ? 4 : 0 }}>
        {header}
        <View style={{ paddingTop: 8 }}>
          {eyebrow ? <T size={13} weight="medium" color={C.muted}>{eyebrow}</T> : null}
          <T size={26} weight="extra">{title}</T>
        </View>
        {sticky}
      </View>
      {children}
    </ScrollView>
  );
}
