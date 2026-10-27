# écu

Suivi des dépenses quotidiennes pour jeunes épargnants. App mobile Expo (React Native, TypeScript). Toutes les données restent sur l'appareil.

## Lancer

```bash
npm install
npx expo start
```

Scanner le QR code avec Expo Go, ou `npm run android` / `npm run ios`.

## Scripts

- `npm test` : tests de la logique métier (`src/domain`)
- `npm run typecheck` : vérification TypeScript

## Structure

- `src/domain` : logique pure (parsing CSV, catégorisation, statistiques, comptes)
- `src/screens` : Jour, Opérations, Budget, Analyse, Réglages
- `src/sheets` : import CSV, détail d'une opération, comptes
- `src/components` : composants partagés
