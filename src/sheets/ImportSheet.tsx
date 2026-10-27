import * as DocumentPicker from 'expo-document-picker';
import React, { useState } from 'react';
import { Pressable, View } from 'react-native';
import { Sheet } from '../components/Sheet';
import { TransactionRow } from '../components/TransactionRow';
import { Button, Card, Row, T } from '../components/ui';
import { byDate, parseCSV } from '../domain/csv';
import { eur, shortDate } from '../domain/format';
import { readCsvFile } from '../domain/readFile';
import { sampleCsv } from '../domain/sample';
import { ParsedCsv } from '../domain/types';
import { useStore } from '../store';
import { C } from '../theme';
import { useUi } from '../ui-state';

type Draft = { fileName: string; parsed: ParsedCsv };
const SEP: Record<string, string> = { ';': 'Point-virgule', ',': 'Virgule', '\t': 'Tabulation' };
const STEPS = ['Exportez votre relevé au format CSV depuis votre banque.', 'Vérifiez qu’il contient une date, un libellé et un montant.', 'Choisissez le fichier ici : tout reste sur cet appareil.'];

export function ImportSheet() {
  const { tx, commit, showToast } = useStore();
  const { importOpen, setImportOpen, setTab, setFilter, setSearch } = useUi();
  const [draft, setDraft] = useState<Draft | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [replace, setReplace] = useState(true);

  const close = () => {
    setImportOpen(false);
    setDraft(null);
    setError(null);
  };
  const handle = (fileName: string, text: string) => {
    const parsed = parseCSV(text);
    if ('error' in parsed) return setError(parsed.error);
    setError(null);
    setDraft({ fileName, parsed });
  };
  const pick = async () => {
    const res = await DocumentPicker.getDocumentAsync({ type: ['text/csv', 'text/comma-separated-values', 'text/plain', 'application/vnd.ms-excel', '*/*'], copyToCacheDirectory: true });
    if (res.canceled) return;
    const f = res.assets[0];
    try {
      handle(f.name, await readCsvFile(f.uri));
    } catch {
      setError('Impossible de lire ce fichier.');
    }
  };
  const confirm = () => {
    if (!draft) return;
    const { tx: incoming } = draft.parsed;
    let next = incoming;
    if (!replace) {
      const key = (t: { date: string; raw: string; amount: number }) => `${t.date}|${t.raw}|${t.amount}`;
      const seen = new Set(tx.map(key));
      next = tx.concat(incoming.filter((t) => !seen.has(key(t)))).sort(byDate);
    }
    commit({ tx: next, lastImport: `${draft.fileName} · ${incoming.length} opérations` });
    setFilter('all');
    setSearch('');
    setTab('today');
    showToast(`${incoming.length} opérations importées`);
    close();
  };

  const p = draft?.parsed;
  return (
    <Sheet visible={importOpen} title={p ? 'Aperçu de l’import' : 'Importer un relevé'} onClose={close}>
      {!p ? (
        <View style={{ gap: 14 }}>
          <Pressable onPress={pick} style={{ height: 170, borderRadius: 20, borderWidth: 2, borderStyle: 'dashed', borderColor: C.line, alignItems: 'center', justifyContent: 'center', gap: 6 }}>
            <T size={15}>Choisir un fichier CSV</T>
            <T size={12} weight="medium" color={C.muted}>date ; libellé ; montant</T>
          </Pressable>
          {error ? <View style={{ backgroundColor: 'rgba(255,122,122,.12)', borderRadius: 14, padding: 12 }}><T size={13} color={C.neg}>{error}</T></View> : null}
          {STEPS.map((s, i) => (
            <Row key={s} style={{ gap: 12 }}>
              <View style={{ width: 26, height: 26, borderRadius: 13, backgroundColor: C.cardInner, alignItems: 'center', justifyContent: 'center' }}><T size={12} color={C.accent}>{i + 1}</T></View>
              <T size={13} weight="medium" color={C.soft} style={{ flex: 1 }}>{s}</T>
            </Row>
          ))}
          <Button label="Essayer avec un relevé d’exemple" bg={C.cardInner} fg={C.text} onPress={() => handle('releve_compte_courant.csv', sampleCsv())} />
        </View>
      ) : (
        <Preview draft={draft!} replace={replace} setReplace={setReplace} onBack={() => setDraft(null)} onConfirm={confirm} />
      )}
    </Sheet>
  );
}

function Preview({ draft, replace, setReplace, onBack, onConfirm }: { draft: Draft; replace: boolean; setReplace: (b: boolean) => void; onBack: () => void; onConfirm: () => void }) {
  const p = draft.parsed;
  const dates = p.tx.map((t) => t.date).sort();
  const out = p.tx.filter((t) => t.amount < 0).reduce((a, t) => a + t.amount, 0);
  const inn = p.tx.filter((t) => t.amount > 0).reduce((a, t) => a + t.amount, 0);
  const toReview = p.tx.filter((t) => t.cat === 'autre').length;
  const auto = Math.round((1 - toReview / p.tx.length) * 100);
  return (
    <View style={{ gap: 12 }}>
      <Row style={{ justifyContent: 'space-between' }}>
        <View style={{ flex: 1 }}>
          <T numberOfLines={1}>{draft.fileName}</T>
          <T size={12} weight="medium" color={C.muted}>{p.tx.length} opérations · {shortDate(dates[0])} → {shortDate(dates[dates.length - 1])} {dates[dates.length - 1].slice(0, 4)}</T>
        </View>
        <Pressable onPress={onBack} hitSlop={8}><T size={13} color={C.accent}>Changer</T></Pressable>
      </Row>
      <Row style={{ gap: 12 }}>
        <Card radius={16} style={{ flex: 1, padding: 12, backgroundColor: C.cardInner }}><T size={11} weight="semi" color={C.muted}>Sorties</T><T size={15} weight="extra">{eur(out)}</T></Card>
        <Card radius={16} style={{ flex: 1, padding: 12, backgroundColor: C.cardInner }}><T size={11} weight="semi" color={C.muted}>Entrées</T><T size={15} weight="extra" color={C.pos}>{eur(inn, { sign: true })}</T></Card>
      </Row>
      <Card radius={16} style={{ padding: 14, backgroundColor: C.cardInner, gap: 8 }}>
        <Row style={{ justifyContent: 'space-between' }}><T size={13}>Catégorisées automatiquement</T><T size={13} color={C.accent}>{auto}{' '}%</T></Row>
        <View style={{ height: 6, borderRadius: 3, backgroundColor: C.track }}><View style={{ width: `${auto}%`, height: 6, borderRadius: 3, backgroundColor: C.accent }} /></View>
        <T size={12} weight="medium" color={C.muted}>{toReview} à classer · {p.skipped} ligne{p.skipped > 1 ? 's' : ''} ignorée{p.skipped > 1 ? 's' : ''} · {SEP[p.sep]}</T>
        <T size={12} weight="medium" color={C.soft}>Date ← {p.cols.date} · Libellé ← {p.cols.label} · Montant ← {p.cols.amount}</T>
      </Card>
      <Card radius={16} style={{ paddingVertical: 4, paddingHorizontal: 14, backgroundColor: C.cardInner }}>
        {p.tx.slice(0, 5).map((t) => <TransactionRow key={t.id} t={t} onPress={() => undefined} />)}
      </Card>
      <Row style={{ backgroundColor: C.cardInner, borderRadius: 14, padding: 3 }}>
        {[[true, 'Remplacer'], [false, 'Ajouter']].map(([v, l]) => (
          <Pressable key={String(l)} onPress={() => setReplace(v as boolean)} style={{ flex: 1, height: 38, borderRadius: 11, alignItems: 'center', justifyContent: 'center', backgroundColor: replace === v ? C.line : 'transparent' }}>
            <T size={13} color={replace === v ? C.text : C.muted}>{l as string}</T>
          </Pressable>
        ))}
      </Row>
      <Button label={`${replace ? 'Remplacer par' : 'Ajouter'} ${p.tx.length} opérations`} onPress={onConfirm} style={{ minHeight: 54, borderRadius: 18 }} />
    </View>
  );
}
