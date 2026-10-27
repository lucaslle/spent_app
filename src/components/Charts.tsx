import React from 'react';
import Svg, { Circle, Line, Path } from 'react-native-svg';
import { C } from '../theme';

export type Segment = { id: string; color: string; value: number };

type RingProps = { size: number; r: number; stroke: number; segments: Segment[]; denom: number; gap: number; selected?: string | null; selectedStroke?: number; onSelect?: (id: string) => void };

export function SegmentedRing({ size, r, stroke, segments, denom, gap, selected, selectedStroke, onSelect }: RingProps) {
  const circ = 2 * Math.PI * r;
  const total = denom || 1;
  let offset = 0;
  return (
    <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
      <Circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={C.track} strokeWidth={stroke} />
      {segments.map((s) => {
        const len = (s.value / total) * circ;
        const el = (
          <Circle
            key={s.id}
            cx={size / 2}
            cy={size / 2}
            r={r}
            fill="none"
            stroke={s.color}
            strokeWidth={selected === s.id ? selectedStroke ?? stroke : stroke}
            strokeDasharray={`${Math.max(len - gap, 0.5)} ${circ}`}
            strokeDashoffset={-offset}
            opacity={selected && selected !== s.id ? 0.3 : 1}
            transform={`rotate(-90 ${size / 2} ${size / 2})`}
            onPress={onSelect ? () => onSelect(s.id) : undefined}
          />
        );
        offset += len;
        return el;
      })}
    </Svg>
  );
}

export function AreaLine({ width, height, line, area, dot, color = C.accent }: { width: number; height: number; line: string; area?: string; dot?: { x: number; y: number }; color?: string }) {
  return (
    <Svg width="100%" height={height} viewBox={`0 0 ${width} ${height}`} preserveAspectRatio="none">
      {area ? <Path d={area} fill={color} opacity={0.14} /> : null}
      <Path d={line} fill="none" stroke={color} strokeWidth={2.5} strokeLinejoin="round" strokeLinecap="round" />
      {dot ? <Circle cx={Math.min(dot.x, width - 4)} cy={dot.y} r={5} fill={color} /> : null}
    </Svg>
  );
}

export function CumulChart({ s }: { s: import('../domain/stats').Stats }) {
  const W = 300;
  const H = 120;
  const top = Math.max(s.projection, s.prevTotal, s.budgetTotal, s.spent) * 1.08 || 1;
  const X = (d: number, n: number) => ((d / n) * W).toFixed(1);
  const Y = (x: number) => (H - (x / top) * H).toFixed(1);
  const path = (arr: number[], upTo: number, n: number) => {
    let acc = 0;
    let p = `M0 ${H}`;
    for (let i = 0; i < upTo; i++) {
      acc += arr[i];
      p += ` L${X(i + 1, n)} ${Y(acc)}`;
    }
    return p;
  };
  const cum = path(s.daily, s.d, s.days);
  return (
    <Svg width="100%" height={H} viewBox={`0 0 ${W} ${H}`} preserveAspectRatio="none">
      <Line x1={0} x2={W} y1={Y(s.budgetTotal)} y2={Y(s.budgetTotal)} stroke={C.neg} strokeWidth={1.2} strokeDasharray="4 4" />
      <Path d={path(s.prevDaily, s.prevDaily.length, s.prevDaily.length)} fill="none" stroke={C.prev} strokeWidth={2} />
      <Path d={`${cum} L${X(s.d, s.days)} ${H} Z`} fill={C.accent} opacity={0.14} />
      <Path d={`M${X(s.d, s.days)} ${Y(s.spent)} L${W} ${Y(s.projection)}`} fill="none" stroke={C.accent} strokeWidth={2} strokeDasharray="4 4" />
      <Path d={cum} fill="none" stroke={C.accent} strokeWidth={2.5} strokeLinejoin="round" />
      <Circle cx={Number(X(s.d, s.days))} cy={Number(Y(s.spent))} r={5} fill={C.accent} />
    </Svg>
  );
}
