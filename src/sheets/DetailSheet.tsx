import React, { useState } from 'react';
import { View } from 'react-native';
import { Sheet } from '../components/Sheet';
import { Avatar, Card, Chip, Row, T, Toggle } from '../components/ui';
import { CAT, CATS } from '../domain/constants';
import { initials, merchant } from '../domain/csv';
import { longDate, shortDate } from '../domain/format';
import { CatId } from '../domain/types';
import { useStore } from '../store';
import { C } from '../theme';
import { useUi } from '../ui-state';

export function DetailSheet() {
  const { tx, commit, money, showToast } = useStore();
  const { selId, setSelId } = useUi();
  const [similar, setSimilar] = useState(true);
  const t = tx.find((x) => x.id === selId);
  const close = () => setSelId(null);
  if (!t) return <Sheet visible={false} title="" onClose={close}>{null}</Sheet>;

  const name = merchant(t.raw);
  const same = tx.filter((x) => merchant(x.raw) === name);
  const others = same.length - 1;
  const total = same.reduce((a, x) => a + x.amount, 0);
  const cat = CAT[t.cat];

  const classify = (id: CatId) => {
    const ids = new Set(similar ? same.map((x) => x.id) : [t.id]);
    commit({ tx: tx.map((x) => (ids.has(x.id) ? { ...x, cat: id, manual: true } : x)) });
    showToast(ids.size > 1 ? `${ids.size} opérations → ${CAT[id].label}` : `Classée en ${CAT[id].label}`);
  };

  return (
    <Sheet visible title={name} onClose={close} left={<Avatar initials={initials(name) || '?'} color={cat.color} size={44} />}>
      <View style={{ gap: 14 }}>
        <View>
          <T size={12} weight="medium" color={C.muted}>{longDate(t.date)}</T>
          <T size={36} weight="extra" color={t.amount > 0 ? C.pos : C.text}>{money(t.amount, { sign: true })}</T>
        </View>
        <Card radius={16} style={{ padding: 14, backgroundColor: C.cardInner, gap: 8 }}>
          <T size={12} weight="medium" color={C.soft}>{t.raw}</T>
          <Row style={{ justifyContent: 'space-between' }}><T size={12} color={C.muted}>Type</T><T size={13}>{t.amount < 0 ? 'Débit' : 'Crédit'}</T></Row>
          <Row style={{ justifyContent: 'space-between' }}><T size={12} color={C.muted}>{same.length} opérations</T><T size={13}>moy. {money(total / same.length)}</T></Row>
        </Card>
        <Row style={{ flexWrap: 'wrap', gap: 8 }}>
          {CATS.map((c) => <Chip key={c.id} label={c.label} on={c.id === t.cat} color={c.color} dot={c.color} onPress={() => classify(c.id)} />)}
        </Row>
        {others > 0 ? (
          <Row style={{ justifyContent: 'space-between', gap: 12 }}>
            <T size={13} style={{ flex: 1 }}>Appliquer aux {others} autres « {name} »</T>
            <Toggle on={similar} onPress={() => setSimilar(!similar)} />
          </Row>
        ) : null}
        <Row style={{ justifyContent: 'space-between', gap: 12 }}>
          <T size={13} style={{ flex: 1 }}>Exclure des statistiques</T>
          <Toggle on={!!t.excl} onPress={() => commit({ tx: tx.map((x) => (x.id === t.id ? { ...x, excl: !x.excl } : x)) })} />
        </Row>
        {others > 0 ? (
          <View style={{ gap: 6 }}>
            <T size={13} color={C.soft}>Historique chez ce marchand</T>
            {same.filter((x) => x.id !== t.id).slice(0, 4).map((x) => (
              <Row key={x.id} style={{ justifyContent: 'space-between' }}>
                <T size={13} weight="medium" color={C.muted}>{shortDate(x.date)}</T>
                <T size={13}>{money(x.amount, { sign: true })}</T>
              </Row>
            ))}
          </View>
        ) : null}
      </View>
    </Sheet>
  );
}
