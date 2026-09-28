---
name: attio-visio-vers-brief
description: Transformer une visio client enregistrée dans le CRM Attio (réunion + enregistrement + transcription) en projet Paperclip et brief normalisé, puis lancer le studio. À utiliser par la routine « Veille des visios Attio » et dès qu'on demande « la visio avec X », « le rendez-vous d'hier », « crée le projet à partir de l'appel ».
metadata:
  paperclip:
    tags:
      - crm
      - attio
      - onboarding
      - client
---

# Visio Attio → projet + brief

## Prérequis
- `ATTIO_API_KEY` dans l'environnement (workspace `pixee-play`). Toujours envoyer `Authorization: Bearer $ATTIO_API_KEY` et un `User-Agent` explicite (`curl/8.4.0`) — sans User-Agent, l'API répond 403.
- Le skill `brief-metier-client` pour la structure du brief.

## 1. Trouver la visio
```
GET https://api.attio.com/v2/meetings?limit=50
```
Champs utiles : `id.meeting_id`, `title`, `description` (souvent la note de prise de rendez-vous), `start.datetime`, `participants[].email_address`, `linked_records[]` (`object_slug=companies`, `record_id`).
- Externe = au moins un participant hors `@pixeeplay.com`.
- Fiche société : `GET /v2/objects/companies/records/{record_id}` → `values.name[0].value`, `values.domains[0].domain`, `values.description[0].value`.

## 2. Enregistrement et transcription
```
GET /v2/meetings/{meeting_id}/call_recordings            → garder status = completed
GET /v2/meetings/{meeting_id}/call_recordings/{id}/transcript?limit=500[&cursor=…]
```
La transcription est une liste de **mots** (`speech`, `start_time`, `end_time`, `speaker.name`), paginée par `pagination.next_cursor`. Reconstituer les tours de parole : mots contigus du même orateur, séparés de moins de 2 s, préfixés `[mm:ss] Orateur :`. Lire l'intégralité avant d'écrire.

## 3. Écrire le brief
Sections : Client (société, site, interlocuteurs externes nom + e-mail, contexte de la prise de contact) · Existant (outils cités, problèmes concrets avec leurs mots) · Objectif en une phrase · Parcours critiques · Ce que le client attend maintenant (**engagements pris oralement par Pixeeplay** : e-mail promis, questions, délai de relance, démo, accès demandés) · Ton et contraintes (vouvoiement si le client vouvoie ; rien n'est envoyé sans validation du board ; jamais dans un dépôt public) · Livrables attendus (A1 e-mail/proposition, A2 questionnaire, A3 cadrage, B1 plan de fonctions Pixee PIM, B2 versions, C démo) · Questions ouvertes · Source (meeting_id, date, durée) · Historique.
Règle d'or : **ne rien inventer**. Ce qui n'a pas été dit devient une question ouverte.

## 4. Créer et lancer
- Projet = slug de la société (`nom-du-client`). S'il existe, réutiliser.
- Tâche `Brief — <Client> : <objet>`, priorité haute, assignée au Directeur de studio, description = brief.
- Sous-tâches par rôle comme pour tout brief ; dépôt client **privé** `pixeeplay/client-<slug>` ; réutiliser l'audit Pixee PIM déjà réalisé pour l'existant.
- Consigner `meeting_id` → tâche dans le document `visios-traitees` de la routine.

## Exemple
- Une visio découverte de 15 min avec un e-commerçant (Shopify + ERP retail) devient un brief avec parcours critiques, engagements pris oralement, questions ouvertes, puis 8 sous-tâches (dépôt privé, audit, questionnaire, e-mail de proposition, plan de fonctions, versions, cadrage, démo).
