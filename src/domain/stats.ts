import { FIXED, SPEND } from './constants';
import { merchant } from './csv';
import { daysInMonth, ds, pad, pd } from './format';
import { Budgets, CatId, Transaction } from './types';

export type CatStat = { id: CatId; amount: number; count: number; budget: number; ratio: number; over: boolean; pace: number };
export type MerchantStat = { name: string; amount: number; count: number; cat: CatId };
export type MonthStat = { key: string; month: number; income: number; out: number };

export type Stats = {
  ref: string;
  y: number;
  m: number;
  d: number;
  dow: number;
  days: number;
  prevMonth: number;
  isToday: boolean;
  yesterday: string;
  spent: number;
  income: number;
  incomeTx: Transaction | undefined;
  daily: number[];
  dailyVar: number[];
  prevDaily: number[];
  prevTotal: number;
  vsPrev: number;
  budgetTotal: number;
  avgVar: number;
  projection: number;
  daysLeft: number;
  remaining: number;
  perDay: number;
  todayTx: Transaction[];
  todaySpent: number;
  yesterdaySpent: number;
  vsAvg: number;
  cats: CatStat[];
  merchants: MerchantStat[];
  weekdays: number[];
  months: MonthStat[];
};

export const isSpend = (t: Transaction) => t.amount < 0 && !t.excl && SPEND.includes(t.cat);
const isVarSpend = (t: Transaction) => isSpend(t) && !FIXED.includes(t.cat);
const sumAbs = (a: Transaction[]) => a.reduce((x, t) => x - t.amount, 0);
const sum = (a: number[]) => a.reduce((x, y) => x + y, 0);
const isIncome = (t: Transaction) => t.amount > 0 && !t.excl && t.cat === 'revenus';

export function computeStats(tx: Transaction[], budgets: Budgets, today: string): Stats | null {
  if (!tx.length) return null;
  const ref = tx.reduce((a, t) => (t.date > a ? t.date : a), '');
  const R = pd(ref);
  const days = daysInMonth(R.y, R.m);
  const ym = ref.slice(0, 7);
  const py = R.m === 1 ? R.y - 1 : R.y;
  const pm = R.m === 1 ? 12 : R.m - 1;
  const pym = `${py}-${pad(pm)}`;
  const prevDays = daysInMonth(py, pm);
  const yesterday = R.d > 1 ? ds(R.y, R.m, R.d - 1) : ds(py, pm, prevDays);

  const mTx = tx.filter((t) => t.date.slice(0, 7) === ym);
  const pTx = tx.filter((t) => t.date.slice(0, 7) === pym);
  const spent = sumAbs(mTx.filter(isSpend));
  const incomeTxs = mTx.filter(isIncome);
  const income = incomeTxs.reduce((x, t) => x + t.amount, 0);

  const daily = Array<number>(days).fill(0);
  const dailyVar = Array<number>(days).fill(0);
  const prevDaily = Array<number>(prevDays).fill(0);
  for (const t of mTx.filter(isSpend)) {
    const i = +t.date.slice(8) - 1;
    daily[i] -= t.amount;
    if (!FIXED.includes(t.cat)) dailyVar[i] -= t.amount;
  }
  for (const t of pTx.filter(isSpend)) prevDaily[+t.date.slice(8) - 1] -= t.amount;

  const prevToDate = sum(prevDaily.slice(0, Math.min(R.d, prevDays)));
  const vsPrev = prevToDate ? (spent - prevToDate) / prevToDate : 0;

  const budgetTotal = SPEND.reduce((a, k) => a + (budgets[k] ?? 0), 0);
  const varM = sum(dailyVar.slice(0, R.d));
  const avgVar = varM / R.d;
  const projection = spent - varM + avgVar * days;
  const daysLeft = days - R.d;
  const remaining = budgetTotal - spent;
  const perDay = daysLeft > 0 ? remaining / daysLeft : remaining;

  const todayTx = tx.filter((t) => t.date === ref);
  const todayVar = sumAbs(todayTx.filter(isVarSpend));
  const pace = R.d / days;

  const cats = SPEND.map((id) => {
    const list = mTx.filter((t) => isSpend(t) && t.cat === id);
    const amount = sumAbs(list);
    const budget = budgets[id] ?? 0;
    const ratio = budget ? amount / budget : amount > 0 ? 2 : 0;
    return { id, amount, count: list.length, budget, ratio, over: amount > budget, pace };
  })
    .filter((c) => c.amount > 0 || c.budget > 0)
    .sort((a, b) => b.amount - a.amount);

  const groups = new Map<string, MerchantStat>();
  for (const t of mTx.filter(isSpend)) {
    const name = merchant(t.raw);
    const g = groups.get(name) ?? { name, amount: 0, count: 0, cat: t.cat };
    g.amount -= t.amount;
    g.count++;
    groups.set(name, g);
  }
  const merchants = [...groups.values()].sort((a, b) => b.amount - a.amount).slice(0, 5);

  const minD = tx.reduce((a, t) => (t.date < a ? t.date : a), ref);
  const dowCount = [0, 0, 0, 0, 0, 0, 0];
  const dowSum = [0, 0, 0, 0, 0, 0, 0];
  const end = Date.UTC(R.y, R.m - 1, R.d);
  for (let t = Date.UTC(+minD.slice(0, 4), +minD.slice(5, 7) - 1, +minD.slice(8)); t <= end; t += 864e5) {
    dowCount[new Date(t).getUTCDay()]++;
  }
  for (const t of tx.filter(isVarSpend)) dowSum[pd(t.date).dow] -= t.amount;
  const weekdays = [1, 2, 3, 4, 5, 6, 0].map((i) => (dowCount[i] ? dowSum[i] / dowCount[i] : 0));

  const keys = [...new Set(tx.map((t) => t.date.slice(0, 7)))].sort().slice(-4);
  const months = keys.map((key) => {
    const list = tx.filter((t) => t.date.slice(0, 7) === key && !t.excl);
    return { key, month: +key.slice(5), income: list.filter(isIncome).reduce((a, t) => a + t.amount, 0), out: sumAbs(list.filter(isSpend)) };
  });

  return {
    ref, y: R.y, m: R.m, d: R.d, dow: R.dow, days, prevMonth: pm, isToday: ref === today, yesterday,
    spent, income, incomeTx: incomeTxs.sort((a, b) => b.amount - a.amount)[0], daily, dailyVar, prevDaily,
    prevTotal: sum(prevDaily), vsPrev, budgetTotal, avgVar, projection, daysLeft, remaining, perDay,
    todayTx, todaySpent: sumAbs(todayTx.filter(isSpend)), yesterdaySpent: sumAbs(tx.filter((t) => t.date === yesterday && isSpend(t))),
    vsAvg: avgVar ? (todayVar - avgVar) / avgVar : 0, cats, merchants, weekdays, months,
  };
}
