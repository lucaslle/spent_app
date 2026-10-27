import assert from 'node:assert/strict';
import { categorize, merchant, parseCSV } from './csv';
import { eur, parseDate, parseNum } from './format';
import { sampleCsv, sampleTransactions } from './sample';
import { computeStats } from './stats';
import { DEFAULT_BUDGETS } from './constants';

assert.equal(categorize('CB UBER EATS 12/10', -20), 'resto');
assert.equal(categorize('CB UBER TRIP', -20), 'transport');
assert.equal(categorize('VIR SEPA SALAIRE ACME', 2000), 'revenus');
assert.equal(categorize('Inconnu', -5), 'autre');
assert.equal(merchant('PRLV SEPA FONCIA LOYER'), 'Foncia Loyer');
assert.equal(parseNum('−1 234,56 €'), -1234.56);
assert.equal(parseNum('1,234.56'), 1234.56);
assert.equal(parseDate('27/10/26'), '2026-10-27');
assert.equal(eur(-1234.5), '−1 234,50 €');

const res = parseCSV(sampleCsv());
assert.ok(!('error' in res));
if (!('error' in res)) {
  assert.equal(res.sep, ';');
  assert.equal(res.tx.length, sampleTransactions().length);
}
assert.ok('error' in parseCSV('a;b\nc;d'));
const dc = parseCSV('Date;Libellé;Débit;Crédit\n01/10/2026;CB LIDL;12,50;\n02/10/2026;VIR SALAIRE;;2000');
assert.ok(!('error' in dc) && dc.tx.length === 2 && dc.tx.some((t) => t.amount === -12.5));

const st = computeStats(sampleTransactions(), DEFAULT_BUDGETS, '2026-10-27');
assert.ok(st && st.isToday && st.d === 27 && st.days === 31 && st.spent > 0 && st.merchants.length === 5);
assert.equal(computeStats([], DEFAULT_BUDGETS, '2026-10-27'), null);
console.log('domain ok');
