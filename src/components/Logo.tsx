import React from 'react';
import Svg, { Circle, Defs, LinearGradient, Rect, Stop } from 'react-native-svg';

export function Logo({ size = 26 }: { size?: number }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100">
      <Defs>
        <LinearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
          <Stop offset="0" stopColor="#F9E596" />
          <Stop offset="1" stopColor="#C39228" />
        </LinearGradient>
      </Defs>
      <Rect width="100" height="100" rx="23" fill="url(#bg)" />
      <Circle cx="50" cy="50" r="30" fill="#1A1610" />
      <Rect x="35" y="45.5" width="30" height="9" rx="4.5" fill="#EBCB5C" />
    </Svg>
  );
}
