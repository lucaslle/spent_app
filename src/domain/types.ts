export type CatId =
  | 'alim' | 'resto' | 'transport' | 'logement' | 'abo' | 'shop'
  | 'loisirs' | 'sante' | 'revenus' | 'virements' | 'autre';

export type AccountTypeId =
  | 'courant' | 'livreta' | 'ldds' | 'lep' | 'pel' | 'pea' | 'av' | 'cto' | 'crypto' | 'autre';

export type AccountGroup = 'cash' | 'save' | 'inv';

export type Category = { id: CatId; label: string; color: string; kw: string[] };
export type AccountType = { id: AccountTypeId; label: string; color: string; g: AccountGroup };

export type Transaction = {
  id: string;
  date: string;
  raw: string;
  amount: number;
  cat: CatId;
  excl?: boolean;
  manual?: boolean;
};

export type BalancePoint = { date: string; balance: number };

export type Account = {
  id: string;
  type: AccountTypeId;
  name: string;
  balance: number;
  updated: string;
  history: BalancePoint[];
};

export type Budgets = Partial<Record<CatId, number>>;

export type ParsedCsv = {
  tx: Transaction[];
  sep: string;
  header: boolean;
  skipped: number;
  cols: { date: string; label: string; amount: string };
};

export type CsvResult = ParsedCsv | { error: string };

export type PersistedState = {
  tx: Transaction[];
  budgets: Budgets;
  accounts: Account[];
  hide: boolean;
  lastImport: string;
};
