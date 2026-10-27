import { ACCOUNT_TYPE } from './constants';
import { todayIso } from './format';
import { Account, AccountGroup, AccountTypeId, BalancePoint } from './types';

export const accountHistory = (a: Account): BalancePoint[] => (a.history.length ? a.history : [{ date: a.updated, balance: a.balance }]);

export const accountTotal = (accounts: Account[]) => accounts.reduce((s, a) => s + a.balance, 0);

export const groupTotal = (accounts: Account[], g: AccountGroup) =>
  accounts.filter((a) => ACCOUNT_TYPE[a.type].g === g).reduce((s, a) => s + a.balance, 0);

export type SeriesPoint = { d: string; v: number };

export function totalSeries(accounts: Account[]): SeriesPoint[] {
  const dates = [...new Set(accounts.flatMap((a) => accountHistory(a).map((h) => h.date)))].sort();
  const at = (a: Account, d: string) => accountHistory(a).reduce((b, h) => (h.date <= d ? h.balance : b), 0);
  return dates.map((d) => ({ d, v: accounts.reduce((s, a) => s + at(a, d), 0) }));
}

const ms = (d: string) => Date.UTC(+d.slice(0, 4), +d.slice(5, 7) - 1, +d.slice(8));

export function sparkline(pts: SeriesPoint[], W: number, H: number) {
  if (!pts.length) return { line: '', area: '', x: 0, y: 0 };
  const t0 = ms(pts[0].d);
  const t1 = ms(pts[pts.length - 1].d) || t0;
  const mn = Math.min(...pts.map((p) => p.v));
  const mx = Math.max(...pts.map((p) => p.v));
  const rg = mx - mn || Math.max(mx, 1);
  const lo = mn - rg * 0.15;
  const hi = mx + rg * 0.15;
  const X = (d: string) => (t1 > t0 ? ((ms(d) - t0) / (t1 - t0)) * W : pts.length === 1 ? W : 0);
  const Y = (v: number) => H - ((v - lo) / (hi - lo)) * H;
  const coords = pts.length === 1 ? [{ x: 0, y: Y(pts[0].v) }, { x: X(pts[0].d), y: Y(pts[0].v) }] : pts.map((p) => ({ x: X(p.d), y: Y(p.v) }));
  const line = coords.map((c, i) => `${i ? 'L' : 'M'}${c.x.toFixed(1)} ${c.y.toFixed(1)}`).join(' ');
  const last = coords[coords.length - 1];
  return { line, area: `${line} L${W} ${H} L0 ${H} Z`, x: last.x, y: last.y };
}

export function saveAccount(accounts: Account[], form: { id: string | null; type: AccountTypeId; name: string }, balance: number): Account[] {
  const today = todayIso();
  const name = form.name.trim() || ACCOUNT_TYPE[form.type].label;
  if (!form.id) {
    return [...accounts, { id: `a${Date.now()}`, type: form.type, name, balance, updated: today, history: [{ date: today, balance }] }];
  }
  return accounts.map((a) => {
    if (a.id !== form.id) return a;
    const h = accountHistory(a).slice();
    const last = h[h.length - 1];
    if (last && last.date === today) h[h.length - 1] = { date: today, balance };
    else if (!last || last.balance !== balance) h.push({ date: today, balance });
    return { ...a, type: form.type, name, balance, updated: today, history: h };
  });
}
