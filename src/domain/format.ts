import { JC, JOURS, MC, MOIS } from './constants';

const NBSP = ' ';

export const pad = (n: number) => String(n).padStart(2, '0');
export const ds = (y: number, m: number, d: number) => `${y}-${pad(m)}-${pad(d)}`;
export const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

export const pd = (s: string) => {
  const [y, m, d] = s.split('-').map(Number);
  return { y, m, d, dow: new Date(Date.UTC(y, m - 1, d)).getUTCDay() };
};

export const daysInMonth = (y: number, m: number) => new Date(Date.UTC(y, m, 0)).getUTCDate();

export const todayIso = () => {
  const n = new Date();
  return ds(n.getFullYear(), n.getMonth() + 1, n.getDate());
};

export type EurOptions = { dec?: number; sign?: boolean };

export function eur(n: number, o: EurOptions = {}): string {
  const dec = o.dec ?? 2;
  const s = Math.abs(n)
    .toLocaleString('fr-FR', { minimumFractionDigits: dec, maximumFractionDigits: dec })
    .replace(/[  ]/g, NBSP);
  const sign = n < 0 && Math.abs(n) >= 0.005 ? '−' : o.sign && n > 0 ? '+' : '';
  return `${sign}${s}${NBSP}€`;
}

export const pctS = (v: number) => `${v > 0 ? '+' : v < 0 ? '−' : ''}${Math.abs(Math.round(v * 100))}${NBSP}%`;

export const shortDate = (s: string) => {
  const p = pd(s);
  return `${p.d} ${MC[p.m - 1]}`;
};

export const longDate = (s: string) => {
  const p = pd(s);
  return `${cap(JOURS[p.dow])} ${p.d} ${MOIS[p.m - 1]} ${p.y}`;
};

export const dayLabel = (s: string) => {
  const p = pd(s);
  return `${cap(JC[p.dow])} ${p.d} ${MC[p.m - 1]}`;
};

export function parseNum(x: unknown): number {
  if (x == null) return NaN;
  let s = String(x).replace(/[\s  €"]/g, '').replace('−', '-');
  if (!s) return NaN;
  if (s.includes(',') && s.includes('.')) {
    s = s.lastIndexOf(',') > s.lastIndexOf('.') ? s.replace(/\./g, '').replace(',', '.') : s.replace(/,/g, '');
  } else {
    s = s.replace(',', '.');
  }
  return /^[-+]?\d*\.?\d+$/.test(s) ? parseFloat(s) : NaN;
}

export function parseDate(x: unknown): string | null {
  if (!x) return null;
  const s = String(x).trim();
  let m = s.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (m) return `${m[1]}-${m[2]}-${m[3]}`;
  m = s.match(/^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})(\s.*)?$/);
  if (m) {
    let y = +m[3];
    if (y < 100) y += 2000;
    return `${y}-${pad(+m[2])}-${pad(+m[1])}`;
  }
  return null;
}
