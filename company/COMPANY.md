---
schema: agentcompanies/v1
kind: company
name: Pixeeplay Studio
slug: pixeeplay-studio
description: Studio d'agents IA de Pixeeplay — reçoit un brief métier + client et livre, versionne et redéploie la solution complète (site web, back-office, apps macOS/iOS/Android/watchOS/tvOS) en s'adaptant au concept, à la charte graphique, au métier et à la communication du client.
version: 1.0.0
license: MIT
authors:
  - name: Arnaud — Pixeeplay (Paris)
homepage: https://pixeeplay.com
tags:
  - agence
  - site-factory
  - multi-plateforme
  - france
goals:
  - Transformer tout brief métier + client en solution numérique complète, déployée et versionnée, sans ressaisie.
  - Adapter systématiquement concept, charte graphique, ton de communication et fonctions au métier et au client, en réutilisant les skills du studio.
  - Garder chaque client dans son propre dépôt GitHub et sa propre ressource Coolify, avec une trace (plan de fonctions, changelog, recette) auditable.
  - Ne jamais engager de dépense, de publication publique ou de suppression sans validation du board (Arnaud).
requirements:
  secrets:
    - CLAUDE_CODE_OAUTH_TOKEN
    - GH_TOKEN
    - COOLIFY_API_TOKEN
    - COOLIFY_URL
    - ATTIO_API_KEY
---

# Pixeeplay Studio

Une agence numérique tenue par des agents. Le **board** (Arnaud) dépose un brief dans le projet `onboarding-client` ; le **CEO** ouvre le dossier client, le **CPO** écrit le plan de fonctions et la feuille de versions, le **Directeur artistique** dérive la charte, le **Responsable communication** fixe le ton et les contenus, le **CTO** fait construire par les leads Web, Apple et Android, **DevOps/Release** déploie sur Coolify et publie les builds, **QA** recette. Chaque étape produit un document versionné dans le dépôt du client.

## Flux standard « nouveau client »

1. `brief-metier-client` — normaliser le brief dans `clients/<slug>/BRIEF.md`.
2. `plan-de-fonctions-versioning` — `PLAN-FONCTIONS.md` + `VERSIONS.md` (v0.1 → v1.0).
3. `charte-graphique-client` — `design/tokens.json`, `DESIGN.md`.
4. `communication-metier` — `COMMUNICATION.md`, textes des pages, SEO local.
5. `site-factory-web` + `deploy-coolify-github` — dépôt, scaffold, site v0.1 en ligne sur `<slug>.pixeeplay.app`.
6. `apple-multiplateforme` / `android-compose` — apps si le brief les demande.
7. `qa-recette` — preuves, puis livraison au board.

## Règles de la maison

- Français par défaut (code et commits en anglais, documents et interfaces en français sauf brief contraire).
- Un client = un dépôt GitHub `pixeeplay/client-<slug>` + une ressource Coolify + un sous-domaine.
- Tout ce qui coûte de l'argent, touche à la production d'un client existant ou publie publiquement passe par une **approbation du board**.
- Hébergement souverain : OVH + Coolify, pas de service tiers américain non demandé par le client.
