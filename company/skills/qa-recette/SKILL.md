---
name: qa-recette
description: >-
  Recetter une livraison contre les critères d'acceptation du plan de fonctions, avec preuves (Playwright, Lighthouse, axe, artefacts CI, captures) et rapport PASS/FAIL/BLOQUÉ par critère et gravité. À utiliser pour toute tâche « Recette : … » et avant toute mise en production.
metadata:
  paperclip:
    tags:
      - qa
      - recette
      - tests
      - accessibilite
---

# Recette avec preuves

## Entrées
Tâche « Recette : <slug> vX.Y — <périmètre> », URL de prévisualisation ou artefacts CI, `PLAN-FONCTIONS.md` (identifiants `F-*` couverts), plan de test du lead.

## Procédure
1. Lister les critères d'acceptation des `F-*` du périmètre → grille de recette (un critère = une ligne).
2. **Web** : Playwright (Chromium + WebKit mobile) sur les parcours ; Lighthouse mobile (accueil + page métier principale) ; axe-core (0 erreur critique) ; vérification réelle de la réception d'un formulaire ; liens morts ; mentions légales et confidentialité présentes.
3. **Apps** : lire le journal du dernier run CI, vérifier tests passés ; TestFlight/APK si disponible : parcours critiques sur simulateur/émulateur via captures du runner. Sans artefact → **BLOQUÉ**.
4. **Cas limites** systématiques : champ vide, valeurs extrêmes, double soumission, réseau coupé, session expirée, mobile 320 px, zoom 200 %, lecteur d'écran sur le parcours principal.
5. **Conformité** : tokens respectés (aucune couleur hors charte), textes conformes à `content/`, allergènes/prix TTC/mentions métier si concernés.
6. Rédiger le rapport, le poster en commentaire et l'enregistrer dans `clients/<slug>/recette/vX.Y.md`.

## Format du rapport
```markdown
# Recette <slug> vX.Y — <date>
Verdict global : PASS | FAIL | BLOQUÉ
| Critère | Résultat | Gravité | Preuve |
|---|---|---|---|
| F-WEB-004 c1 formulaire ≤ 8 champs | PASS | — | capture-01.png |
| F-WEB-004 c2 devis visible BO < 1 min | FAIL | majeur | video-02.webm, délai 4 min |
Lighthouse mobile : perf 93 · a11y 100 · SEO 100 — axe : 0 critique
Étapes de reproduction des FAIL : …
Suggestions (hors périmètre, non bloquantes) : …
```

## Règles
- Un FAIL cite le critère et donne des étapes de reproduction exactes ; un FAIL « bloquant » empêche la release.
- QA ne corrige pas le code ; la tâche retourne au lead avec le rapport.
- Une remarque de goût est une suggestion, jamais un FAIL.
