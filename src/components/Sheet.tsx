import React from 'react';
import { KeyboardAvoidingView, Modal, Platform, Pressable, ScrollView, View, useWindowDimensions } from 'react-native';
import { C } from '../theme';
import { Icon } from './Icon';
import { Row, T } from './ui';

export function Sheet({ visible, title, onClose, children, left }: { visible: boolean; title: string; onClose: () => void; children: React.ReactNode; left?: React.ReactNode }) {
  const { height } = useWindowDimensions();
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose} statusBarTranslucent>
      <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={{ flex: 1, justifyContent: 'flex-end' }}>
        <Pressable onPress={onClose} style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: C.veil }} />
        <View style={{ backgroundColor: C.card, borderTopLeftRadius: 28, borderTopRightRadius: 28, maxHeight: height * 0.92, paddingTop: 10, paddingHorizontal: 18, paddingBottom: 34 }}>
          <View style={{ alignSelf: 'center', width: 40, height: 5, borderRadius: 3, backgroundColor: C.line, marginBottom: 12 }} />
          <Row style={{ justifyContent: 'space-between', marginBottom: 14 }}>
            <Row style={{ gap: 10, flex: 1 }}>
              {left}
              <T size={22} weight="extra" numberOfLines={1} style={{ flexShrink: 1 }}>{title}</T>
            </Row>
            <Pressable onPress={onClose} hitSlop={8} style={{ width: 34, height: 34, borderRadius: 12, backgroundColor: C.cardInner, alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="close" size={18} color={C.soft} />
            </Pressable>
          </Row>
          <ScrollView showsVerticalScrollIndicator={false} keyboardShouldPersistTaps="handled">{children}</ScrollView>
        </View>
      </KeyboardAvoidingView>
    </Modal>
  );
}
