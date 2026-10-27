import { categorize, byDate } from './csv';
import { daysInMonth, ds, pad, pd } from './format';
import { Account, BalancePoint, Transaction } from './types';

export function sampleTransactions(): Transaction[] {
  let seed = 11;
  const r = () => (seed = (seed * 16807) % 2147483647) / 2147483647;
  const pick = <T,>(a: T[]) => a[Math.floor(r() * a.length)];
  const tx: Transaction[] = [];
  let id = 0;
  const add = (date: string, label: string, amount: number) =>
    tx.push({ id: `s${id++}`, date, raw: label, amount: Math.round(amount * 100) / 100, cat: 'autre' });

  const fixed: [number, string, number][] = [
    [2, 'PRLV SEPA NAVIGO ANNUEL', -86.4], [3, 'PRLV SEPA FONCIA LOYER', -720], [5, 'PRLV SEPA FREE MOBILE', -19.99],
    [8, 'CB NETFLIX.COM', -13.49], [10, 'PRLV SEPA EDF CLIENTS', -64.2], [12, 'CB SPOTIFY P', -10.99],
    [15, 'PRLV SEPA BASIC FIT', -29.99], [25, 'VIR SEPA SALAIRE ACME SAS', 2150],
  ];

  for (const [y, m] of [[2026, 8], [2026, 9], [2026, 10]]) {
    const last = m === 10 ? 27 : daysInMonth(y, m);
    for (const [d, l, a] of fixed) if (d <= last) add(ds(y, m, d), l, a);
    for (let d = 1; d <= last; d++) {
      const date = ds(y, m, d);
      const dd = ` ${pad(d)}/${pad(m)}`;
      const dow = pd(date).dow;
      const we = dow === 0 || dow === 6;
      if (r() < 0.55) add(date, `CB ${pick(['BOULANGERIE PAUL', 'BOULANGERIE LA FOURNEE', 'STARBUCKS', 'COLUMBUS CAFE'])}${dd}`, -(2.5 + r() * 6));
      if (r() < (we ? 0.5 : 0.28)) add(date, `CB ${pick(['MONOPRIX', 'CARREFOUR CITY', 'LIDL', 'FRANPRIX', 'PICARD'])}${dd}`, -(9 + r() * 58));
      if (r() < (dow >= 4 || dow === 0 ? 0.4 : 0.16)) add(date, `CB ${pick(['UBER EATS', 'DELIVEROO', 'LE PETIT BISTROT', 'SUSHI SHOP', 'BIG MAMMA'])}${dd}`, -(14 + r() * 32));
      if (r() < 0.12) add(date, `CB ${pick(['UBER TRIP', 'BOLT', 'TOTALENERGIES', 'SNCF INTERNET'])}${dd}`, -(8 + r() * 40));
      if (r() < 0.1) add(date, `CB ${pick(['AMAZON EU', 'ZARA', 'FNAC', 'DECATHLON', 'UNIQLO', 'VINTED'])}${dd}`, -(12 + r() * 70));
      if (r() < 0.06) add(date, `CB ${pick(['UGC CINE CITE', 'STEAM GAMES', 'FNAC SPECTACLES', 'BAR LE PERCHOIR'])}${dd}`, -(9 + r() * 30));
      if (r() < 0.04) add(date, `CB ${pick(['PHARMACIE CENTRALE', 'DOCTOLIB MEDECIN'])}${dd}`, -(6 + r() * 25));
      if (r() < 0.05) add(date, `VIR LYDIA ${pick(['THOMAS', 'CAMILLE', 'LEA'])}`, (r() < 0.5 ? -1 : 1) * (10 + r() * 30));
    }
  }
  add('2026-08-18', 'CB HELLOASSO 18/08', -25);
  add('2026-09-12', 'CB SQ *ATELIER VAUGIRARD 12/09', -42);
  add('2026-10-04', 'PAIEMENT CB SUMUP *KIOSQUE 04/10', -8.5);
  add('2026-10-21', 'CB SQ *ATELIER VAUGIRARD 21/10', -38);
  add('2026-10-27', 'CB BOULANGERIE PAUL 27/10', -3.2);
  add('2026-10-27', 'CB MONOPRIX 27/10', -23.45);
  add('2026-10-27', 'CB UBER TRIP 27/10', -12.8);
  tx.forEach((t) => (t.cat = categorize(t.raw, t.amount)));
  return tx.sort(byDate);
}

export function sampleCsv(): string {
  const lines = sampleTransactions().map((t) => {
    const p = pd(t.date);
    return `${pad(p.d)}/${pad(p.m)}/${p.y};${t.raw};${String(t.amount).replace('.', ',')}`;
  });
  return `Date;Libellé;Montant\n${lines.join('\n')}`;
}

const HISTORY_DATES = ['2026-05-01', '2026-06-01', '2026-07-01', '2026-08-01', '2026-09-01'];
const history = (vals: number[], last: number, lastDate: string): BalancePoint[] =>
  HISTORY_DATES.map((date, i) => ({ date, balance: vals[i] })).concat([{ date: lastDate, balance: last }]);

export const defaultAccounts = (): Account[] => [
  { id: 'a1', type: 'courant', name: 'Compte courant', balance: 1842.3, updated: '2026-10-27', history: history([1520, 1980, 1410, 2105, 1690], 1842.3, '2026-10-27') },
  { id: 'a2', type: 'livreta', name: 'Livret A', balance: 6450, updated: '2026-10-01', history: history([5400, 5600, 5800, 6000, 6200], 6450, '2026-10-01') },
  { id: 'a3', type: 'ldds', name: 'LDDS', balance: 2100, updated: '2026-10-01', history: history([2000, 2000, 2050, 2050, 2100], 2100, '2026-10-01') },
  { id: 'a4', type: 'pea', name: 'PEA', balance: 4380.55, updated: '2026-10-20', history: history([3500, 3640, 3580, 3890, 4020], 4380.55, '2026-10-20') },
];
