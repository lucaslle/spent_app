import React, { useState } from 'react';
import { View } from 'react-native';
import { Button, Card, Row, T, Toggle } from '../components/ui';
import { CATS, DEFAULT_BUDGETS } from '../domain/constants';
import { sampleTransactions } from '../domain/sample';
import { useStore } from '../store';
import { C } from '../theme';
import { useUi } from '../ui-state';
import { Screen } from './Screen';

export function Settings() {
  const { tx, hide, lastImport, commit, showToast } = useStore();
  const { setImportOpen } = useUi();
  const [armed, setArmed] = useState(false);

  const clear = () => {
    if (!armed) return setArmed(true);
    commit({ tx: [], lastImport: 'Aucun import' });
    setArmed(false);
    showToast('Données effacées');
  };

  return (
    <Screen eyebrow="Préférences" title="Réglages">
      <Card radius={20} style={{ gap: 14 }}>
        <Row style={{ justifyContent: 'space-between', gap: 12 }}>
          <View style={{ flex: 1 }}>
            <T size={12} weight="semi" color={C.muted}>Dernier import</T>
            <T numberOfLines={2}>{lastImport}</T>
          </View>
          <Button label="Importer" onPress={() => setImportOpen(true)} style={{ minHeight: 40 }} />
        </Row>
        <Row style={{ justifyContent: 'space-between' }}>
          <T size={13} weight="semi" color={C.muted}>Opérations</T>
          <T>{tx.length}</T>
        </Row>
        <Row style={{ justifyContent: 'space-between' }}>
          <T>Masquer les montants</T>
          <Toggle on={hide} onPress={() => commit({ hide: !hide })} />
        </Row>
      </Card>
      <Card radius={20} style={{ padding: 16 }}>
        <T size={15}>Catégorisation automatique</T>
        {CATS.map((c) => (
          <Row key={c.id} style={{ gap: 10, minHeight: 40 }}>
            <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: c.color }} />
            <T size={13} style={{ flex: 1 }}>{c.label}</T>
            <T size={12} weight="medium" color={C.muted}>{c.kw.length ? `${c.kw.length} mots-clés` : 'Manuel'}</T>
            <T size={12} weight="medium" color={C.muted} style={{ minWidth: 52, textAlign: 'right' }}>{tx.filter((t) => t.cat === c.id).length} op.</T>
          </Row>
        ))}
      </Card>
      <Button label="Réinitialiser les budgets" bg={C.card} fg={C.text} onPress={() => { commit({ budgets: { ...DEFAULT_BUDGETS } }); showToast('Budgets réinitialisés'); }} />
      <Button label="Recharger l’exemple" bg={C.card} fg={C.text} onPress={() => { const t = sampleTransactions(); commit({ tx: t, lastImport: `Exemple intégré · ${t.length} opérations` }); showToast('Exemple rechargé'); }} />
      <Button label={armed ? 'Confirmer : tout effacer' : 'Effacer les données'} bg={armed ? C.neg : 'transparent'} fg={armed ? C.accentInk : C.neg} border={C.neg} onPress={clear} />
    </Screen>
  );
}
