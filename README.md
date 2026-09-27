# paperclip-pixeeplay

Déploiement de [Paperclip](https://paperclip.ing) (orchestrateur open source d'agents IA, MIT) sur le VPS OVH de Pixeeplay via Coolify, et **company d'agents « Pixeeplay Studio »** : une agence tenue par des agents qui reçoit un brief métier + client et livre, versionne et redéploie la solution complète — site web, back-office, apps iOS/macOS/watchOS/tvOS/Android — en s'adaptant au concept, à la charte graphique, au métier et à la communication du client.

```
deploy/      docker-compose.yml (Coolify), .env.example, COOLIFY.md (pas à pas), install-vps.sh (plan B SSH)
company/     package Paperclip importable (spec agentcompanies/v1) : COMPANY.md, agents/, teams/, projects/, tasks/, skills/, .paperclip.yaml
templates/   modèle de brief et exemple de brief normalisé (Maison Dupain)
```

## Installer Paperclip

Suivre `deploy/COOLIFY.md` (≈ 10 min) : ressource *Docker Compose Empty* dans Coolify, domaine `paperclip.pixeeplay.com`, variables `CLAUDE_CODE_OAUTH_TOKEN` (abonnement Claude Max) et `GH_TOKEN`, premier admin via `pnpm paperclipai auth bootstrap-ceo`, puis verrouillage des inscriptions.

## Importer la company

Dans Paperclip → **Company → Import** → GitHub :

```
https://github.com/pixeeplay/paperclip-pixeeplay/tree/main/company
```

(Le dépôt doit être public pour l'import par URL ; sinon, depuis le terminal Coolify du service : `git clone` avec `GH_TOKEN` dans `/paperclip/import` puis `pnpm paperclipai company import /paperclip/import/company --target new --new-company-name "Pixeeplay Studio" --yes`.)

Après import : renseigner les secrets company (`GH_TOKEN`, `COOLIFY_URL`, `COOLIFY_API_TOKEN`, `COOLIFY_SERVER_UUID`, `COOLIFY_PROJECT_UUID`), tester l'adapter de chaque agent, activer le heartbeat du **CEO** (les autres se réveillent sur assignation), et déposer un premier brief dans le projet **Onboarding client**.

## L'organisation

| Agent | Rôle | Modèle | Skills |
|---|---|---|---|
| **Directeur de studio (CEO)** | reçoit les briefs, ouvre les dossiers, délègue, rend compte au board | Opus 5.5 | brief-metier-client, plan-de-fonctions-versioning |
| **Chef de produit (CPO)** | plan de fonctions, feuille de versions, conformité promis/livré | Opus 5.5 | brief, plan-de-fonctions, qa-recette |
| **Directeur artistique** | charte → tokens W3C → CSS/Swift/Kotlin, maquettes | Sonnet 5 | charte-graphique-client |
| **Responsable communication** | ton, contenus, e-mails, fiches stores, SEO local, légal FR | Sonnet 5 | communication-metier |
| **CTO** | architecture, dépôts, découpage, revue, fusion | Opus 5.5 | github-pr-workflow, site-factory-web, deploy-coolify-github |
| **Lead Web** | Next.js + API + back-office, intégrations Odoo/PrestaShop/Pixee PIM | Sonnet 5 | site-factory-web |
| **Lead Apple** | SwiftUI multi-cibles, CI macOS, TestFlight | Sonnet 5 | apple-multiplateforme |
| **Lead Android** | Kotlin/Compose, CI, Play interne | Sonnet 5 | android-compose |
| **DevOps & Release** | Coolify, domaines, versions/tags, changelog, veille | Sonnet 5 | deploy-coolify-github, plan-de-fonctions-versioning |
| **QA** | recette avec preuves, verdict par critère | Sonnet 5 | qa-recette |

Deux pôles réimportables séparément : `teams/produit-design` (CPO + DA + Communication) et `teams/ingenierie` (CTO + leads + DevOps + QA).

## Flux « nouveau client »

Brief déposé → `BRIEF.md` normalisé → `PLAN-FONCTIONS.md` + `VERSIONS.md` → `design/tokens.json` + `DESIGN.md` → `COMMUNICATION.md` + `content/` → dépôt `pixeeplay/client-<slug>` scaffoldé → site v0.1 sur `https://<slug>.pixeeplay.app` → apps si demandées → recette → approbation du board → production.

Tout ce qui coûte de l'argent, publie publiquement ou touche à la production d'un client existant passe par une approbation du board (Arnaud).

## Faire évoluer les skills

Les skills sont des dossiers `SKILL.md` compatibles Agent Skills / skills.sh. Un nouveau métier ou un nouveau client réutilisable = un skill (ou une référence dans `brief-metier-client/references/familles-metier.md`) ajouté par PR ; Paperclip réimporte le package en mode `existing` (collision `replace`) pour le mettre à jour.

## Licence

MIT pour ce dépôt. Paperclip est © Paperclip Labs, Inc, MIT.
