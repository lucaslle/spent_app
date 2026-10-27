import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { createContext, useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { DEFAULT_BUDGETS } from './domain/constants';
import { eur, EurOptions, todayIso } from './domain/format';
import { defaultAccounts, sampleTransactions } from './domain/sample';
import { computeStats, Stats } from './domain/stats';
import { Account, Budgets, PersistedState, Transaction } from './domain/types';

const KEY = 'ecu-state-v1';

type Store = PersistedState & {
  ready: boolean;
  stats: Stats | null;
  money: (n: number, o?: EurOptions) => string;
  commit: (p: Partial<PersistedState>) => void;
  toast: string | null;
  showToast: (m: string) => void;
};

const Ctx = createContext<Store | null>(null);

const initial = (): PersistedState => {
  const tx = sampleTransactions();
  return { tx, budgets: { ...DEFAULT_BUDGETS }, accounts: defaultAccounts(), hide: false, lastImport: `Exemple intégré · ${tx.length} opérations` };
};

export function StoreProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<PersistedState>(initial);
  const [ready, setReady] = useState(false);
  const [toast, setToast] = useState<string | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout>>(undefined);

  useEffect(() => {
    AsyncStorage.getItem(KEY)
      .then((raw) => {
        if (raw) setState({ ...initial(), ...(JSON.parse(raw) as Partial<PersistedState>) });
      })
      .catch(() => undefined)
      .finally(() => setReady(true));
  }, []);

  const commit = useCallback((p: Partial<PersistedState>) => {
    setState((prev) => {
      const next = { ...prev, ...p };
      AsyncStorage.setItem(KEY, JSON.stringify(next)).catch(() => undefined);
      return next;
    });
  }, []);

  const showToast = useCallback((m: string) => {
    clearTimeout(timer.current);
    setToast(m);
    timer.current = setTimeout(() => setToast(null), 2400);
  }, []);

  const stats = useMemo(() => computeStats(state.tx, state.budgets, todayIso()), [state.tx, state.budgets]);
  const money = useCallback((n: number, o?: EurOptions) => (state.hide ? '••• €' : eur(n, o)), [state.hide]);

  const value = useMemo(() => ({ ...state, ready, stats, money, commit, toast, showToast }), [state, ready, stats, money, commit, toast, showToast]);
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useStore(): Store {
  const s = useContext(Ctx);
  if (!s) throw new Error('StoreProvider manquant');
  return s;
}

export type { Account, Budgets, Transaction };
