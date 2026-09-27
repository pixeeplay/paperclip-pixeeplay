---
name: github-pr-workflow
description: Discipline Git et GitHub du studio — branches, Conventional Commits, PR courtes et descriptives, CI verte, revue, fusion par le CTO uniquement, pas de secrets. À utiliser pour toute contribution de code, revue ou fusion.
metadata:
  paperclip:
    tags:
      - git
      - github
      - revue
      - qualite
---

# Flux PR GitHub

## Branches
- `main` : production, protégée, fusion par le CTO seulement.
- `develop` : intégration, déployée en prévisualisation.
- `feat/F-WEB-004-devis-piece-montee`, `fix/…`, `chore/…`, `design/…` : une branche par tâche Paperclip, créée depuis `develop`.

## Commits — Conventional Commits, en anglais
`feat(web): add quote request form (F-WEB-004)` · `fix(api): reject duplicate submissions` · `design(tokens): bump palette to v1.1` · `chore(ci): cache pnpm store`.
Un commit = une intention. Pas de « wip », pas de « fix fix ». Rebase interactif avant revue si nécessaire.

## Pull request
- Titre = type + portée + identifiant `F-*`. Description : **Quoi / Pourquoi / Comment tester / Captures** (obligatoires pour l'UI) / **Risques**.
- ≤ 400 lignes modifiées sauf justification écrite ; sinon découper.
- CI verte exigée ; tests ajoutés ou modifiés pour tout comportement nouveau.
- Labels : `needs-design-review` (UI), `needs-qa` (parcours), `legal` (contenu légal/RGPD), `security` (auth, secrets, paiement).
- Lier la tâche Paperclip dans la description ; poster le lien de la PR en commentaire de la tâche.

## Revue (CTO / DA / pairs)
- Refus automatique : secret en clair, dépendance non justifiée, test absent, CI rouge, couleur en dur, texte public non issu de `content/`.
- Commentaires concrets : ce qui bloque vs suggestion. Le relecteur ne pousse pas de correctif sur la branche de l'auteur sans le dire.
- Fusion : squash par défaut sur `develop`, merge commit de `develop` vers `main` au moment de la release (tag).

## Sécurité
- `gh auth setup-git` avec `GH_TOKEN` ; jamais de mot de passe.
- Changements `security` : revue dédiée + commentaire « menaces considérées » avant fusion.
- Ne jamais désactiver les hooks, la signature ou la CI sans approbation du board.
