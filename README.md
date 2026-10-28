# écu

Suivi des dépenses quotidiennes pour jeunes épargnants. App Flutter (iOS / Android). Toutes les données restent sur l'appareil.

- Import d'un relevé bancaire CSV (date ; libellé ; montant) et catégorisation automatique par mots-clés
- Tableau de bord du jour, budget mensuel par catégorie, analyses
- Détail d'une opération avec reclassement en masse
- Comptes d'épargne et de placement saisis à la main, avec historique des soldes

## Lancer

```bash
flutter pub get
flutter run
```

## Vérifier

```bash
flutter analyze
flutter test
```

## Structure (OSDD)

- `lib/layers/technical/` : Theme (design system), Formatting (formats FR, masquage des montants), Charts
- `lib/layers/functional/Spending/` : opérations, budgets, statistiques, import CSV (domain / data / presentation)
- `lib/layers/functional/Savings/` : comptes et patrimoine (domain / data / presentation)
- `lib/app/` : composition des onglets et de la barre flottante
