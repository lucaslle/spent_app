import { AccountType, AccountTypeId, Budgets, CatId, Category } from './types';

export const CATS: Category[] = [
  { id: 'alim', label: 'Courses', color: '#7BD389', kw: ['monoprix', 'carrefour', 'lidl', 'franprix', 'auchan', 'leclerc', 'intermarche', 'picard', 'biocoop', 'super u', 'naturalia'] },
  { id: 'resto', label: 'Restaurants', color: '#F2A65A', kw: ['uber eats', 'deliveroo', 'boulangerie', 'paul', 'starbucks', 'mcdo', 'burger', 'bistrot', 'restaurant', 'sushi', 'pizza', 'cafe', 'brasserie', 'kfc', 'big mamma'] },
  { id: 'transport', label: 'Transport', color: '#6FB7FF', kw: ['navigo', 'ratp', 'sncf', 'uber', 'bolt', 'total', 'esso', 'shell', 'blablacar', 'parking', 'vinci'] },
  { id: 'logement', label: 'Logement', color: '#B49CFF', kw: ['loyer', 'foncia', 'edf', 'engie', 'syndic', 'nexity'] },
  { id: 'abo', label: 'Abonnements', color: '#FF7FB0', kw: ['netflix', 'spotify', 'free mobile', 'sfr', 'bouygues', 'disney', 'deezer', 'basic fit', 'icloud', 'canal+'] },
  { id: 'shop', label: 'Shopping', color: '#8FA8FF', kw: ['amazon', 'zara', 'fnac', 'decathlon', 'h&m', 'uniqlo', 'ikea', 'darty', 'sephora', 'vinted', 'zalando'] },
  { id: 'loisirs', label: 'Loisirs', color: '#5ED6C9', kw: ['ugc', 'pathe', 'cinema', 'steam', 'playstation', 'concert', 'ticketmaster', 'musee', 'fnac spectacles', 'bar '] },
  { id: 'sante', label: 'Santé', color: '#FF8A80', kw: ['pharmacie', 'doctolib', 'medecin', 'dentiste', 'mutuelle', 'opticien'] },
  { id: 'revenus', label: 'Revenus', color: '#9BE15D', kw: ['salaire', 'caf ', 'remboursement'] },
  { id: 'virements', label: 'Virements', color: '#9AA3AE', kw: ['lydia', 'vir ', 'virement', 'paylib', 'wero'] },
  { id: 'autre', label: 'À classer', color: '#8C8C99', kw: [] },
];

export const CAT = Object.fromEntries(CATS.map((c) => [c.id, c])) as Record<CatId, Category>;

export const SPEND: CatId[] = ['alim', 'resto', 'transport', 'logement', 'abo', 'shop', 'loisirs', 'sante', 'autre'];
export const FIXED: CatId[] = ['logement', 'abo'];

export const DEFAULT_BUDGETS: Budgets = { alim: 320, resto: 180, transport: 120, logement: 800, abo: 90, shop: 150, loisirs: 80, sante: 40, autre: 50 };

export const ACCOUNT_TYPES: AccountType[] = [
  { id: 'courant', label: 'Compte courant', color: '#9AA3AE', g: 'cash' },
  { id: 'livreta', label: 'Livret A', color: '#6FB7FF', g: 'save' },
  { id: 'ldds', label: 'LDDS', color: '#5ED6C9', g: 'save' },
  { id: 'lep', label: 'LEP', color: '#7BD389', g: 'save' },
  { id: 'pel', label: 'PEL', color: '#EBCB5C', g: 'save' },
  { id: 'pea', label: 'PEA', color: '#B49CFF', g: 'inv' },
  { id: 'av', label: 'Assurance-vie', color: '#F2A65A', g: 'inv' },
  { id: 'cto', label: 'Compte-titres', color: '#FF7FB0', g: 'inv' },
  { id: 'crypto', label: 'Crypto', color: '#F5B544', g: 'inv' },
  { id: 'autre', label: 'Autre', color: '#8C8C99', g: 'save' },
];

export const ACCOUNT_TYPE = Object.fromEntries(ACCOUNT_TYPES.map((a) => [a.id, a])) as Record<AccountTypeId, AccountType>;

export const MOIS = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];
export const MC = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
export const JOURS = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
export const JC = ['dim.', 'lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.'];
