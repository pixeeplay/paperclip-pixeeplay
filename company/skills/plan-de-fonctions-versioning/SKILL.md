---
name: plan-de-fonctions-versioning
description: Écrire et maintenir le plan de fonctions (PLAN-FONCTIONS.md) et la feuille de versions (VERSIONS.md) d'un client, découper en tâches, versionner (SemVer, tags par plateforme, CHANGELOG) et décider ce qui entre dans v0.1 / v0.5 / v1.0. À utiliser après le brief, à chaque changement de périmètre et à chaque release.
metadata:
  paperclip:
    tags:
      - produit
      - versions
      - roadmap
      - release
---

# Plan de fonctions & versions

## Livrables
- `clients/<slug>/PLAN-FONCTIONS.md` — toutes les fonctions, par plateforme, avec critères d'acceptation.
- `clients/<slug>/VERSIONS.md` — quelle fonction dans quelle version, définition de terminé, dates visées.
- `CHANGELOG.md` à la racine du dépôt client (Keep a Changelog, généré depuis les PR).

## Identifiants
`F-<PLATEFORME>-<NNN>` avec plateforme ∈ `WEB` (site public), `BO` (back-office), `API`, `IOS`, `MAC`, `WATCH`, `TV`, `AND`, `INT` (intégration ERP), `LEG` (légal/RGPD), `COM` (communication/SEO). Un identifiant ne change jamais de sens ; une fonction retirée est marquée `retirée (vX.Y)`, jamais supprimée.

## Procédure
1. Lire `BRIEF.md § Parcours critiques` : chaque parcours devient 1 à 3 fonctions **cœur** → elles constituent la **v0.5**.
2. **v0.1 « en ligne en 2 semaines »** : vitrine (accueil, offre, à propos, contact/RDV simple, mentions légales, confidentialité), tokens appliqués, SEO de base, déploiement prévisualisation. Jamais plus.
3. **v1.0** : offre complète du brief, intégrations ERP, apps demandées avec leurs parcours critiques, back-office utilisable par le client seul.
4. Pour chaque fonction, écrire :
   ```markdown
   ### F-WEB-004 · Commande sur devis (pièce montée)
   **En tant que** particulier **je veux** décrire ma pièce montée (date, parts, parfums, budget) **afin de** recevoir un devis sous 24 h.
   **Version** : 0.5 · **Plateformes** : WEB, BO · **Dépend de** : F-API-002, F-INT-001
   **Critères d'acceptation**
   - [ ] Formulaire en ≤ 8 champs, allergènes rappelés, acompte expliqué si > 80 €.
   - [ ] Le devis apparaît dans le back-office avec statut « à traiter » en < 1 min.
   - [ ] E-mail de confirmation au client, copie à la boutique.
   **Données** : nom, e-mail, téléphone, date événement — base légale : exécution précontractuelle — conservation : 3 ans.
   ```
5. Découper en tâches Paperclip (≤ 2 jours chacune), avec l'identifiant `F-*` dans le titre, les dépendances en « bloqué par », le lead assigné, et les critères copiés dans la description.
6. À chaque release : tag `web-vX.Y.Z` / `ios-vX.Y.Z` / `android-vX.Y.Z`, `CHANGELOG.md` mis à jour, `VERSIONS.md` coché, release GitHub avec la liste des `F-*` livrées.

## Règles de version
- SemVer : MAJEURE = changement de parcours ou de contrat, MINEURE = fonction, CORRECTIF = bug.
- Une version n'est « terminée » que si QA a rendu PASS sur tous ses critères et que DevOps a déployé le tag.
- Les fonctions légales (`F-LEG-*`) et de sécurité ne peuvent pas être repoussées au-delà de la version où la donnée concernée apparaît.
- Un changement de brief crée une section « Impact » dans `VERSIONS.md` : ce qui bouge, ce qui est retiré, ce qui est ajouté.
