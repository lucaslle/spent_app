import React from 'react';
import { Pressable, View } from 'react-native';
import { Icon } from '../components/Icon';
import { Logo } from '../components/Logo';
import { TransactionRow } from '../components/TransactionRow';
import { Card, Row, T } from '../components/ui';
import { MC, MOIS, JOURS } from '../domain/constants';
import { merchant } from '../domain/csv';
import { cap, pctS, shortDate } from '../domain/format';
import { useStore } from '../store';
import { C, FONT } from '../theme';
import { useUi } from '../ui-state';
import { BudgetCard } from './today/BudgetCard';
import { DailyBars } from './today/DailyBars';
import { WealthCard } from './today/WealthCard';
import { Screen } from './Screen';

const NBSP = ' ';

function Header() {
  const { setImportOpen } = useUi();
  return (
    <Row style={{ justifyContent: 'space-between' }}>
      <Row style={{ gap: 8 }}>
        <Logo />
        <T size={17} weight="mono" style={{ letterSpacing: -0.7, fontFamily: FONT.mono }}>écu</T>
      </Row>
      <Pressable onPress={() => setImportOpen(true)} style={{ width: 42, height: 42, borderRadius: 14, backgroundColor: C.card, alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="download" size={20} color={C.text} />
      </Pressable>
    </Row>
  );
}

export function Today() {
  const { stats: s, money, tx } = useStore();
  const { setTab, setSelId, showTx } = useUi();
  if (!s) {
    return (
      <Screen title="Vos dépenses" header={<Header />}>
        <Card><T color={C.muted} weight="medium">Aucune opération. Importez un relevé CSV pour commencer.</T></Card>
      </Screen>
    );
  }
  const eyebrow = `${s.isToday ? 'Aujourd’hui · ' : ''}${cap(JOURS[s.dow])} ${s.d} ${MOIS[s.m - 1]}`;
  const toReview = tx.filter((t) => t.cat === 'autre').length;
  const proj = s.projection - s.budgetTotal;
  return (
    <Screen eyebrow={eyebrow} title="Vos dépenses" header={<Header />}>
      <WealthCard />
      <BudgetCard s={s} />
      {s.incomeTx ? (
        <Card radius={20} onPress={() => showTx('in')} style={{ padding: 14 }}>
          <Row style={{ gap: 12 }}>
            <View style={{ width: 38, height: 38, borderRadius: 12, backgroundColor: 'rgba(74,222,155,.15)', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="up" size={18} color={C.pos} />
            </View>
            <View style={{ flex: 1 }}>
              <T>Revenus du mois</T>
              <T size={12} weight="medium" color={C.muted}>{merchant(s.incomeTx.raw)} · {shortDate(s.incomeTx.date)}</T>
            </View>
            <T color={C.pos}>{money(s.income, { sign: true })}</T>
          </Row>
        </Card>
      ) : (
        <Card radius={20} style={{ padding: 14 }}><T size={13} weight="medium" color={C.muted}>Aucun revenu détecté ce mois. Classez votre salaire en « Revenus » depuis le détail d’une opération.</T></Card>
      )}
      <Row style={{ gap: 12, alignItems: 'stretch' }}>
        <Card radius={20} style={{ flex: 1, padding: 16 }}>
          <T size={12} weight="semi" color={C.muted}>{s.isToday ? 'Dépensé aujourd’hui' : `Dépensé le ${s.d} ${MC[s.m - 1]}`}</T>
          <T size={22} weight="extra">{money(s.todaySpent)}</T>
          <T size={11} color={s.vsAvg > 0.1 ? C.neg : C.pos}>{pctS(s.vsAvg)} vs moyenne</T>
        </Card>
        <Card radius={20} style={{ flex: 1, padding: 16 }}>
          <T size={12} weight="semi" color={C.muted}>Projection fin de mois</T>
          <T size={22} weight="extra" color={proj > 0 ? C.neg : C.pos}>{money(s.projection, { dec: 0 })}</T>
          <T size={11} color={proj > 0 ? C.neg : C.pos}>{proj > 0 ? `+${money(proj, { dec: 0 })} au-dessus du budget` : `${money(-proj, { dec: 0 })} sous le budget`}</T>
        </Card>
      </Row>
      <DailyBars s={s} />
      <Card radius={20} style={{ paddingVertical: 14, paddingHorizontal: 16 }}>
        <Row style={{ justifyContent: 'space-between', marginBottom: 4 }}>
          <T size={15}>{s.isToday ? 'Aujourd’hui' : `Le ${s.d} ${MC[s.m - 1]}`}</T>
          <Pressable onPress={() => setTab('tx')}><T size={13} color={C.accent}>Tout voir ›</T></Pressable>
        </Row>
        {s.todayTx.length ? s.todayTx.map((t) => <TransactionRow key={t.id} t={t} onPress={() => setSelId(t.id)} />) : <T size={13} weight="medium" color={C.muted}>Aucune opération ce jour-là.</T>}
      </Card>
      {toReview > 0 ? (
        <Pressable onPress={() => showTx('autre')} style={{ backgroundColor: 'rgba(242,166,90,.1)', borderRadius: 20, padding: 14 }}>
          <Row style={{ justifyContent: 'space-between' }}>
            <T color={C.warn}>Opérations à classer</T>
            <T color={C.warn}>{toReview}{NBSP}›</T>
          </Row>
        </Pressable>
      ) : null}
    </Screen>
  );
}
