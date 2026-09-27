---
name: apple-multiplateforme
description: Construire l'app Apple d'un client en Swift 6 / SwiftUI avec un package partagé et des cibles iOS, macOS, watchOS, tvOS (XcodeGen, tokens Swift générés, CI GitHub Actions macOS, TestFlight via fastlane). À utiliser dès qu'un brief demande iPhone/iPad, Mac, Apple Watch ou Apple TV.
metadata:
  paperclip:
    tags:
      - apple
      - ios
      - macos
      - watchos
      - tvos
      - swiftui
---

# Apple multi-plateforme

## Structure `apps/apple/`
```
apps/apple/
├── project.yml                 XcodeGen : cibles iOS / macOS / watchOS / tvOS activées selon le brief
├── Packages/<Client>Kit/       SwiftPM : Models, APIClient (async/await), Persistence, DesignTokens (généré)
├── <Client>iOS/                App iPhone/iPad (SwiftUI, NavigationStack, widgets si demandés)
├── <Client>macOS/              App Mac (SwiftUI, menus, raccourcis, fenêtres multiples)
├── <Client>watchOS/            App Watch (glanceable, complications, notifications)
├── <Client>tvOS/               App TV (focus engine, top shelf, lecture plein écran)
├── fastlane/                   Fastfile (beta → TestFlight), Matchfile, Appfile
└── README.md
```

## Procédure
1. Lire `PLAN-FONCTIONS.md` (`F-IOS-*`, `F-MAC-*`, `F-WATCH-*`, `F-TV-*`) et `DESIGN.md`.
2. Générer `DesignTokens.swift` depuis `packages/design-tokens` (`pnpm tokens:build`) : `Color.brand500`, `Font.heading()`, `Radius.md`… ; jamais de valeur en dur dans les vues.
3. `project.yml` : bundle ids `com.pixeeplay.<slug>.<plateforme>`, déploiement min iOS 17 / macOS 14 / watchOS 10 / tvOS 17 (ajuster au brief), Swift 6, strict concurrency.
4. `<Client>Kit` : modèles `Codable` partagés avec `packages/shared` (zod → Swift via la CI ou à la main, mais un seul contrat), `APIClient` vers `apps/api`, gestion hors-ligne si le parcours l'exige.
5. Vues par plateforme : réutiliser les composants du Kit, adapter la navigation ; accessibilité (labels, Dynamic Type, VoiceOver), localisation FR (`Localizable.xcstrings`).
6. Tests : XCTest sur le Kit (≥ 80 % des modèles/API), UI tests des parcours critiques sur iOS.
7. CI `.github/workflows/apple.yml` : `macos-15`, `xcodegen generate`, `xcodebuild test` par cible, artefacts de logs. Lane `beta` fastlane exécutée manuellement (`workflow_dispatch`) après approbation du board.
8. `README.md` : capacités à activer dans App Store Connect (push, Sign in with Apple, StoreKit), secrets GitHub attendus (`ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8`, `MATCH_PASSWORD`).

## Contraintes
- L'agent tourne sous Linux : aucune compilation locale. Une PR Apple n'est « verte » que si le workflow macOS l'est ; sinon la tâche reste ouverte avec le lien du run.
- Runner self-hosted possible sur le Mac mini du studio (label `macmini-pixeeplay`) pour accélérer.
- Aucune ressource visuelle de marque tierce ; les icônes viennent de SF Symbols ou de la charte.
