---
name: android-compose
description: Construire l'app Android d'un client en Kotlin / Jetpack Compose (Material 3 thémé par les tokens, modules core/feature, Ktor, Room, CI GitHub Actions, AAB Play Console piste interne). À utiliser dès qu'un brief demande Android.
metadata:
  paperclip:
    tags:
      - android
      - kotlin
      - compose
---

# Android — Kotlin / Jetpack Compose

## Structure `apps/android/`
```
apps/android/
├── settings.gradle.kts  build.gradle.kts  gradle/libs.versions.toml
├── app/                 point d'entrée, navigation, DI (Hilt)
├── core-ui/             Theme.kt généré depuis les tokens, composants partagés
├── core-data/           APIClient (Ktor), modèles (kotlinx.serialization), Room si hors-ligne
├── feature-<parcours>/  un module par parcours critique
└── README.md
```

## Procédure
1. Lire `PLAN-FONCTIONS.md` (`F-AND-*`) et `DESIGN.md` ; générer `Tokens.kt` depuis `packages/design-tokens` → `ColorScheme`, `Typography`, `Shapes` Material 3 (clair/sombre).
2. `minSdk 26`, `targetSdk` courant, Kotlin 2.x, Compose BOM, Hilt, Navigation Compose, Coil.
3. Écrans par parcours ; états `Loading/Empty/Error/Content` explicites ; TalkBack, tailles de police système, RTL neutre.
4. Tests : JUnit 5 + Turbine (ViewModels), Compose UI tests des parcours critiques, screenshot tests optionnels.
5. CI `.github/workflows/android.yml` (ubuntu) : `./gradlew lint testDebugUnitTest assembleDebug bundleRelease`, artefacts APK/AAB. Publication piste interne Play via `r0adkll/upload-google-play` seulement en `workflow_dispatch` après approbation du board.
6. `README.md` : permissions et justification, secrets GitHub attendus (`PLAY_SERVICE_ACCOUNT_JSON`, `ANDROID_KEYSTORE_B64`, `KEYSTORE_PASSWORD`).

## Règles
- Aucune couleur/taille en dur ; tout passe par `core-ui`.
- Contrat d'API identique au web et à Apple (`packages/shared`).
- Keystore et identifiants Play hors dépôt.
