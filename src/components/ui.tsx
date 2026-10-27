import React from 'react';
import { Pressable, Text, TextProps, View, ViewStyle } from 'react-native';
import { C, FONT, tabular } from '../theme';

export function T({ size = 14, weight = 'bold', color = C.text, style, ...p }: TextProps & { size?: number; weight?: keyof typeof FONT; color?: string }) {
  const big = size >= 22;
  return <Text {...p} style={[{ fontFamily: FONT[weight], fontSize: size, color, letterSpacing: big ? -size * 0.025 : 0 }, tabular, style]} />;
}

export function Card({ style, children, onPress, radius = 24 }: { style?: ViewStyle; children: React.ReactNode; onPress?: () => void; radius?: number }) {
  const s = [{ backgroundColor: C.card, borderRadius: radius, padding: 18 }, style];
  return onPress ? (
    <Pressable onPress={onPress} style={s}>{children}</Pressable>
  ) : (
    <View style={s}>{children}</View>
  );
}

export function Avatar({ initials, color, size = 38 }: { initials: string; color: string; size?: number }) {
  return (
    <View style={{ width: size, height: size, borderRadius: size * 0.32, backgroundColor: `${color}24`, alignItems: 'center', justifyContent: 'center' }}>
      <T weight="extra" size={size > 50 ? 20 : 12} color={color}>{initials}</T>
    </View>
  );
}

export function Chip({ label, on, dot, onPress, color }: { label: string; on: boolean; dot?: string; onPress: () => void; color?: string }) {
  const bg = on ? (color ? `${color}2E` : C.accent) : C.card;
  const fg = on && !color ? C.accentInk : C.text;
  return (
    <Pressable
      onPress={onPress}
      style={{ height: 34, borderRadius: 17, paddingHorizontal: 14, backgroundColor: bg, borderWidth: 1.5, borderColor: on && color ? color : 'transparent', flexDirection: 'row', alignItems: 'center', gap: 6 }}
    >
      {dot ? <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: dot }} /> : null}
      <T size={12} color={fg}>{label}</T>
    </Pressable>
  );
}

export function Toggle({ on, onPress }: { on: boolean; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} style={{ width: 46, height: 28, borderRadius: 14, backgroundColor: on ? C.accent : C.line, justifyContent: 'center' }}>
      <View style={{ width: 24, height: 24, borderRadius: 12, backgroundColor: C.text, marginLeft: on ? 20 : 2 }} />
    </Pressable>
  );
}

export function Button({ label, onPress, bg = C.accent, fg = C.accentInk, border, disabled, style }: { label: string; onPress: () => void; bg?: string; fg?: string; border?: string; disabled?: boolean; style?: ViewStyle }) {
  return (
    <Pressable
      onPress={disabled ? undefined : onPress}
      style={[{ minHeight: 48, borderRadius: 16, backgroundColor: bg, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 16, borderWidth: border ? 1.5 : 0, borderColor: border }, style]}
    >
      <T size={14} color={fg}>{label}</T>
    </Pressable>
  );
}

export function Bar({ pct, color, height = 8, track = C.track, mark }: { pct: number; color: string; height?: number; track?: string; mark?: { at: number; color: string; width?: number } }) {
  return (
    <View style={{ height, borderRadius: height / 2, backgroundColor: track, overflow: 'hidden' }}>
      <View style={{ width: `${Math.min(Math.max(pct, 0), 100)}%`, height, backgroundColor: color, borderRadius: height / 2 }} />
      {mark ? <View style={{ position: 'absolute', left: `${mark.at}%`, width: mark.width ?? 2, height, backgroundColor: mark.color }} /> : null}
    </View>
  );
}

export function Row({ style, children }: { style?: ViewStyle; children: React.ReactNode }) {
  return <View style={[{ flexDirection: 'row', alignItems: 'center' }, style]}>{children}</View>;
}

