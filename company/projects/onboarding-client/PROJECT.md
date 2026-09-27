---
name: Onboarding client
slug: onboarding-client
description: Porte d'entrée du studio. Le board dépose ici un brief métier + client ; le CEO ouvre le dossier et le flux standard se déroule jusqu'à la livraison v1.0.
owner: ceo
---

# Onboarding client

**Comment déposer un brief** : créer une tâche intitulée `Brief : <Nom du client> — <métier>` assignée au CEO, dont la description suit `templates/BRIEF-METIER-CLIENT.md` (ou colle simplement les notes de rendez-vous : le skill `brief-metier-client` normalise).

**Ce qui se passe ensuite** (une tâche enfant par étape, dans cet ordre) :

1. `01 · Brief normalisé` — CEO → `clients/<slug>/BRIEF.md`
2. `02 · Plan de fonctions + versions` — CPO → `PLAN-FONCTIONS.md`, `VERSIONS.md`
3. `03 · Charte graphique` — DA → `design/tokens.json`, `DESIGN.md`, maquettes
4. `04 · Communication + contenus` — Responsable communication → `COMMUNICATION.md`, `content/`
5. `05 · Dépôt + scaffold` — CTO → `pixeeplay/client-<slug>`
6. `06 · Site v0.1 en prévisualisation` — Lead Web + DevOps → `https://<slug>.pixeeplay.app`
7. `07 · Apps (si demandées)` — Lead Apple / Lead Android → CI verte, builds de test
8. `08 · Recette v0.x` — QA → `recette/<version>.md`
9. `09 · Livraison + approbation production` — CEO ↔ board

Les tâches 01 à 06 sont créées automatiquement par le CEO à la lecture du brief ; 07 dépend des plateformes demandées.
