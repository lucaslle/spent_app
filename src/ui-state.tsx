import React, { createContext, useCallback, useContext, useMemo, useState } from 'react';
import { TabId } from './components/TabBar';

type UiState = {
  tab: TabId;
  setTab: (t: TabId) => void;
  filter: string;
  setFilter: (f: string) => void;
  search: string;
  setSearch: (s: string) => void;
  selId: string | null;
  setSelId: (id: string | null) => void;
  donutSel: string | null;
  setDonutSel: (id: string | null) => void;
  importOpen: boolean;
  setImportOpen: (b: boolean) => void;
  accOpen: boolean;
  setAccOpen: (b: boolean) => void;
  showTx: (filter: string) => void;
};

const Ctx = createContext<UiState | null>(null);

export function UiProvider({ children }: { children: React.ReactNode }) {
  const [tab, setTab] = useState<TabId>('today');
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');
  const [selId, setSelId] = useState<string | null>(null);
  const [donutSel, setDonutSel] = useState<string | null>(null);
  const [importOpen, setImportOpen] = useState(false);
  const [accOpen, setAccOpen] = useState(false);

  const showTx = useCallback((f: string) => {
    setFilter(f);
    setSearch('');
    setTab('tx');
  }, []);

  const value = useMemo(
    () => ({ tab, setTab, filter, setFilter, search, setSearch, selId, setSelId, donutSel, setDonutSel, importOpen, setImportOpen, accOpen, setAccOpen, showTx }),
    [tab, filter, search, selId, donutSel, importOpen, accOpen, showTx],
  );
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useUi(): UiState {
  const u = useContext(Ctx);
  if (!u) throw new Error('UiProvider manquant');
  return u;
}
