import { CATS } from './constants';
import { parseDate, parseNum } from './format';
import { CatId, CsvResult, Transaction } from './types';

export function categorize(label: string, amount: number): CatId {
  const l = ` ${label.toLowerCase()} `;
  let best: CatId | null = null;
  let bestLen = 0;
  for (const c of CATS) {
    for (const k of c.kw) {
      if (l.includes(k) && k.length > bestLen) {
        best = c.id;
        bestLen = k.length;
      }
    }
  }
  if (!best) best = amount > 0 ? 'revenus' : 'autre';
  if (best === 'revenus' && amount < 0) best = 'autre';
  return best;
}

const STOP = ['SAS', 'SA', 'SARL', 'FR', 'PARIS', 'EU', 'P', 'CLIENTS', 'INTERNET', 'ANNUEL', 'TRIP', 'CITE', 'GAMES', 'SEPA'];
const ACRONYMS = ['UGC', 'EDF', 'SNCF', 'RATP', 'SFR', 'KFC', 'H&M'];
const LOWER = ['DE', 'DU', 'LA', 'LE', 'DES'];
const PREFIX = /^(PAIEMENT PAR CARTE|PAIEMENT CB|CARTE\s?X?\d*|CB\*?\d*|PRLV SEPA|PRELEVEMENT|PRLV|VIREMENT SEPA|VIR SEPA|VIREMENT|VIR INST|VIR|RETRAIT DAB)\s+/;

const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);

function words(raw: string): string[] {
  const s = String(raw)
    .toUpperCase()
    .replace(PREFIX, '')
    .replace(/^(SQ|SUMUP|ZTL|PAYPAL)\s?\*\s?/, '')
    .replace(/\.COM\b/g, '')
    .replace(/\*/g, ' ');
  return s.split(/\s+/).filter((w) => w && !/\d/.test(w) && !STOP.includes(w)).slice(0, 3);
}

export function merchant(raw: string): string {
  const w = words(raw);
  if (!w.length) return cap(String(raw).toLowerCase());
  return w
    .map((x, i) => (ACRONYMS.includes(x) ? x : i > 0 && LOWER.includes(x) ? x.toLowerCase() : x.charAt(0) + x.slice(1).toLowerCase()))
    .join(' ');
}

export const initials = (name: string) =>
  name
    .split(' ')
    .filter((w) => /^[A-ZÀ-Ü0-9&]/i.test(w))
    .slice(0, 2)
    .map((w) => w[0].toUpperCase())
    .join('');

export const byDate = (a: { date: string }, b: { date: string }) => (a.date < b.date ? 1 : a.date > b.date ? -1 : 0);

const HEADER_RE = /date|libell|montant|amount|label|description|d[ée]bit|cr[ée]dit/i;
const LABEL_RE = /libell|label|description|intitul|nature|d[ée]tail|merchant|b[ée]n[ée]ficiaire/i;

function splitLine(line: string, sep: string): string[] {
  const out: string[] = [];
  let cur = '';
  let quoted = false;
  for (let i = 0; i < line.length; i++) {
    const ch = line[i];
    if (ch === '"') {
      if (quoted && line[i + 1] === '"') {
        cur += '"';
        i++;
      } else quoted = !quoted;
    } else if (ch === sep && !quoted) {
      out.push(cur);
      cur = '';
    } else cur += ch;
  }
  out.push(cur);
  return out.map((x) => x.trim());
}

export function parseCSV(input: string): CsvResult {
  const text = String(input).replace(/^﻿/, '');
  const lines = text.split(/\r?\n/).filter((l) => l.trim());
  if (!lines.length) return { error: 'Fichier vide.' };

  const probe = lines.slice(0, 8).join('\n');
  const count = (ch: string) => probe.split(ch).length - 1;
  const sep = [';', '\t', ','].reduce((b, ch) => (count(ch) > count(b) ? ch : b), ';');
  const rows = lines.map((l) => splitLine(l, sep));

  const isHead = (r: string[]) => r.some((x) => HEADER_RE.test(x)) && !r.some((x) => parseDate(x));
  const hi = rows.findIndex((r) => r.length >= 2 && isHead(r));
  const header = hi >= 0 ? rows[hi] : null;
  const body = rows.slice(hi + 1).filter((r) => r.length >= 2);

  const find = (re: RegExp) => (header ? header.findIndex((h) => re.test(h)) : -1);
  let di = find(/date/i);
  let li = find(LABEL_RE);
  let ai = find(/montant|amount|somme|valeur/i);
  const dbi = find(/d[ée]bit/i);
  const cri = find(/cr[ée]dit/i);

  if (di < 0 || li < 0 || (ai < 0 && dbi < 0)) {
    const r0 = body[0] ?? [];
    if (di < 0) di = r0.findIndex((x) => parseDate(x));
    if (ai < 0 && dbi < 0) ai = r0.findIndex((x, i) => i !== di && !isNaN(parseNum(x)));
    if (li < 0) {
      let best = -1;
      let bestLen = -1;
      r0.forEach((x, i) => {
        if (i !== di && i !== ai && x.length > bestLen) {
          bestLen = x.length;
          best = i;
        }
      });
      li = best;
    }
  }
  if (di < 0 || li < 0 || (ai < 0 && dbi < 0)) {
    return { error: 'Colonnes introuvables. Format attendu : date ; libellé ; montant.' };
  }

  const tx: Transaction[] = [];
  let skipped = 0;
  body.forEach((r, i) => {
    const date = parseDate(r[di]);
    let amt: number;
    if (ai >= 0) amt = parseNum(r[ai]);
    else {
      const d = parseNum(r[dbi]);
      const c = parseNum(r[cri]);
      amt = (isNaN(c) ? 0 : Math.abs(c)) - (isNaN(d) ? 0 : Math.abs(d));
    }
    const raw = (r[li] ?? '').replace(/\s+/g, ' ').trim();
    if (!date || isNaN(amt) || !raw || amt === 0) {
      skipped++;
      return;
    }
    tx.push({ id: `i${i}_${Math.random().toString(36).slice(2, 6)}`, date, raw, amount: Math.round(amt * 100) / 100, cat: categorize(raw, amt) });
  });
  if (!tx.length) return { error: 'Aucune opération lisible dans ce fichier.' };

  tx.sort(byDate);
  const name = (i: number) => (header && i >= 0 ? header[i] : `Colonne ${i + 1}`);
  return {
    tx,
    sep,
    header: !!header,
    skipped,
    cols: { date: name(di), label: name(li), amount: ai >= 0 ? name(ai) : `${name(dbi)} / ${name(cri)}` },
  };
}
