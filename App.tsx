import { GeistMono_500Medium } from '@expo-google-fonts/geist-mono';
import { Manrope_400Regular, Manrope_500Medium, Manrope_600SemiBold, Manrope_700Bold, Manrope_800ExtraBold, useFonts } from '@expo-google-fonts/manrope';
import { StatusBar } from 'expo-status-bar';
import React from 'react';
import { View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { TabBar } from './src/components/TabBar';
import { T } from './src/components/ui';
import { Budget } from './src/screens/Budget';
import { Settings } from './src/screens/Settings';
import { StatsScreen } from './src/screens/Stats';
import { Today } from './src/screens/Today';
import { Transactions } from './src/screens/Transactions';
import { AccountsSheet } from './src/sheets/AccountsSheet';
import { DetailSheet } from './src/sheets/DetailSheet';
import { ImportSheet } from './src/sheets/ImportSheet';
import { StoreProvider, useStore } from './src/store';
import { C } from './src/theme';
import { UiProvider, useUi } from './src/ui-state';

const SCREENS = { today: Today, tx: Transactions, budget: Budget, stats: StatsScreen, settings: Settings };

function Shell() {
  const { ready, toast } = useStore();
  const { tab, setTab } = useUi();
  if (!ready) return <View style={{ flex: 1, backgroundColor: C.bg }} />;
  const Current = SCREENS[tab];
  return (
    <View style={{ flex: 1, backgroundColor: C.bg }}>
      <Current />
      <TabBar tab={tab} onChange={setTab} />
      <ImportSheet />
      <DetailSheet />
      <AccountsSheet />
      {toast ? (
        <View pointerEvents="none" style={{ position: 'absolute', bottom: 104, alignSelf: 'center', backgroundColor: C.text, borderRadius: 16, paddingHorizontal: 16, paddingVertical: 12, elevation: 12, shadowColor: '#000', shadowOpacity: 0.4, shadowRadius: 15, shadowOffset: { width: 0, height: 10 } }}>
          <T size={13} color={C.accentInk}>{toast}</T>
        </View>
      ) : null}
    </View>
  );
}

export default function App() {
  const [loaded] = useFonts({ Manrope_400Regular, Manrope_500Medium, Manrope_600SemiBold, Manrope_700Bold, Manrope_800ExtraBold, GeistMono_500Medium });
  if (!loaded) return <View style={{ flex: 1, backgroundColor: C.bg }} />;
  return (
    <SafeAreaProvider>
      <StatusBar style="light" />
      <StoreProvider>
        <UiProvider>
          <Shell />
        </UiProvider>
      </StoreProvider>
    </SafeAreaProvider>
  );
}
