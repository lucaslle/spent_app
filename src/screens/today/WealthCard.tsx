import React from 'react';
import { Pressable, View } from 'react-native';
import { accountTotal, groupTotal, totalSeries } from '../../domain/accounts';
import { ACCOUNT_TYPE } from '../../domain/constants';
import { shortDate } from '../../domain/format';
import { useStore } from '../../store';
import { useUi } from '../../ui-state';
import { C } from '../../theme';
import { Row, T } from '../../components/ui';

export function WealthCard() {
  const { accounts, money } = useStore();
  const { setAccOpen } = useUi();
  const total = accountTotal(accounts);
  const series = totalSeries(accounts);
  const first = series[0];
  const delta = first ? total - first.v : 0;
  const groups: [string, number][] = [['Courant', groupTotal(accounts, 'cash')], ['Épargne', groupTotal(accounts, 'save')], ['Investi', groupTotal(accounts, 'inv')]];
  return (
    <Pressable onPress={() => setAccOpen(true)} style={{ backgroundColor: C.wealth, borderRadius: 24, borderWidth: 1, borderColor: C.line, padding: 18 }}>
      <Row style={{ justifyContent: 'space-between' }}>
        <T size={13} weight="semi" color={C.soft}>Patrimoine · {accounts.length} compte{accounts.length > 1 ? 's' : ''}</T>
        <T size={13} color={C.accent}>Gérer ›</T>
      </Row>
      <Row style={{ gap: 10, marginTop: 6, flexWrap: 'wrap' }}>
        <T size={30} weight="extra">{money(total)}</T>
        {series.length > 1 ? (
          <View style={{ backgroundColor: C.card, borderRadius: 10, paddingHorizontal: 8, paddingVertical: 4 }}>
            <T size={11} color={delta >= 0 ? C.pos : C.neg}>
              {money(delta, { sign: true, dec: 0 })} depuis le {shortDate(first.d)}
            </T>
          </View>
        ) : null}
      </Row>
      <Row style={{ gap: 3, height: 8, marginTop: 14 }}>
        {accounts.filter((a) => a.balance > 0).map((a) => (
          <View key={a.id} style={{ flex: a.balance, height: 8, borderRadius: 4, backgroundColor: ACCOUNT_TYPE[a.type].color }} />
        ))}
      </Row>
      <Row style={{ marginTop: 14 }}>
        {groups.map(([label, v]) => (
          <View key={label} style={{ flex: 1 }}>
            <T size={11} weight="semi" color={C.muted}>{label}</T>
            <T>{money(v, { dec: 0 })}</T>
          </View>
        ))}
      </Row>
    </Pressable>
  );
}
