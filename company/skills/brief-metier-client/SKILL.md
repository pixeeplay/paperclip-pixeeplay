---
name: brief-metier-client
description: Normaliser un brief métier + client (notes de rendez-vous, mail, formulaire) en un BRIEF.md structuré et réutilisable — métier, cibles, offre, plateformes, existant, charte, ton, contraintes légales françaises, questions ouvertes. À utiliser à l'ouverture de tout dossier client et à chaque changement de client ou de périmètre.
metadata:
  paperclip:
    tags:
      - produit
      - onboarding
      - metier
      - client
---

# Brief métier + client → `clients/<slug>/BRIEF.md`

## Quand l'utiliser
- Une tâche « Brief : … » arrive dans `onboarding-client`.
- Le client change d'activité, de cible ou de périmètre (le brief est **re-normalisé**, pas patché à la main).

## Entrées acceptées
Notes brutes, mail, formulaire, transcription d'appel, ancien site. Tout est bon : le skill structure.

## Procédure
1. **Identifier** : nom commercial, forme, ville, effectif, ancienneté, décideur. Créer le `slug` (minuscules, tirets, sans accent — `maison-dupain`).
2. **Classer le métier** dans une famille (droit & chiffre · santé & soins · métiers de bouche · restauration & hébergement · bâtiment & architecture · commerce de proximité · beauté & bien-être · auto & mobilité · immobilier & services · services du quotidien · association & culture · SaaS/B2B · autre). La famille conditionne les obligations légales, les parcours critiques et la charte (voir `references/familles-metier.md`).
3. **Extraire** dans cet ordre : objectif business (1 phrase) · cibles (personas) · offre (produits/services, prix, saisonnalité) · **parcours critiques** (3 max, ce que le client doit pouvoir faire sans appeler) · plateformes demandées (web, back-office, iOS, macOS, Android, watchOS, tvOS) · existant à intégrer (Odoo, PrestaShop, Pixee PIM, caisse, agenda, CRM) · identité (logo, couleurs, typo, photos, ce qu'il déteste) · ton · contraintes (légales du métier, RGPD, accessibilité, délais, budget, domaine) · succès mesurable à 3 mois.
4. **Ne rien inventer** : chaque case non renseignée va dans « Questions ouvertes » avec la question à poser au client, formulée pour une réponse en une ligne.
5. **Écrire** `clients/<slug>/BRIEF.md` selon le gabarit ci-dessous, puis `clients/<slug>/JOURNAL.md` (première ligne datée « Brief reçu »).
6. **Proposer** au CEO la liste des sous-tâches du flux standard (01→09) avec, pour chaque plateforme non demandée, la mention « non demandé ».

## Gabarit `BRIEF.md`
```markdown
---
client: Maison Dupain
slug: maison-dupain
famille_metier: metiers-de-bouche
plateformes: [web, backoffice, ios]
existant: [odoo-pos]
domaine: maisondupain.fr
statut: brief-valide | en-questions
version_brief: 1
---
## Objectif (1 phrase)
## Cibles
## Offre
## Parcours critiques (3 max)
## Plateformes & priorités
## Existant à intégrer
## Identité visuelle fournie
## Ton & vocabulaire
## Contraintes (légales métier · RGPD · accessibilité · délais · budget)
## Succès à 3 mois (mesurable)
## Questions ouvertes
## Historique des versions du brief
```

## Règles
- Le brief est la source de vérité : plan, charte et communication le citent (`BRIEF.md § Parcours critiques`).
- Une re-normalisation incrémente `version_brief` et note ce qui change dans « Historique ».
- Langue : français ; identifiants et slug en ASCII.
