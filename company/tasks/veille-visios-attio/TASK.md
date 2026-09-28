---
name: Veille des visios Attio et nouveaux projets clients
slug: veille-visios-attio
assignee: ceo
project: studio-operations
recurring: true
priority: high
---

Toutes les 3 heures (heures ouvrées, Europe/Paris), vérifie dans le CRM Attio s'il y a une **nouvelle visio client enregistrée** et, pour chacune, **crée le projet et lance le studio** — exactement comme pour les premiers dossiers clients du studio.

## Accès
- Clé : variable d'environnement `ATTIO_API_KEY` (workspace `pixee-play`). Header `Authorization: Bearer $ATTIO_API_KEY`, User-Agent `curl/8.4.0`.
- API : `GET https://api.attio.com/v2/meetings?limit=50` (champs `id.meeting_id`, `title`, `description`, `start`, `participants[].email_address`, `linked_records[]`) ; `GET /v2/meetings/{meeting_id}/call_recordings` (garder `status = completed`) ; `GET /v2/meetings/{meeting_id}/call_recordings/{call_recording_id}/transcript?limit=500` (mots + `speaker.name`, pagination par `pagination.next_cursor` → `&cursor=`) ; `GET /v2/objects/companies/records/{record_id}` pour la fiche société liée.

## Règles
1. **Mémoire** : le document `visios-traitees` de cette routine liste les `meeting_id` déjà traités (un par ligne, avec la date et le projet créé). Ne retraite jamais un identifiant présent. Si le document n'existe pas, crée-le en y inscrivant `<meeting_id> des visios déjà traitées.
2. **Filtre** : ignore les réunions dont tous les participants sont `@pixeeplay.com`, celles sans enregistrement `completed`, et celles de moins de 5 minutes. Une réunion **sans enregistrement mais avec une fiche société liée** n'est pas traitée : ajoute une ligne « en attente d'enregistrement » dans le document et repasse la fois suivante.
3. **Transcription → brief** : reconstitue les tours de parole (mots contigus du même orateur), lis toute la transcription, puis rédige un brief normalisé avec le skill `brief-metier-client`, sur le modèle des briefs existants : client, interlocuteurs (nom + e-mail des participants externes), existant, objectif en une phrase, parcours critiques, ce que le client attend maintenant (engagements pris oralement par Arnaud : e-mail, questions, délai de relance, démo), ton et contraintes, livrables attendus (A1 e-mail/proposition, A2 questionnaire, A3 cadrage, B1 plan de fonctions Pixee PIM, B2 versions, C démo), questions ouvertes, source (meeting_id, date, durée). Cite le client sans inventer : ce qui n'a pas été dit est une question ouverte.
4. **Projet + tâche** : slug = nom de la société en minuscules avec tirets (`nom-du-client`). Si un projet du même slug existe, rattache la tâche à ce projet au lieu d'en créer un. Crée la tâche `Brief — <Client> : <objet>` (priorité haute, assignée à toi-même, projet = slug) avec le brief en description, puis traite-la comme n'importe quel brief : sous-tâches par rôle (Communication, Chef de produit, CTO — dépôt privé `pixeeplay/client-<slug>`), en réutilisant l'audit Pixee PIM déjà réalisé pour l'existant.
5. **Confidentialité** : la transcription et le brief ne vont **jamais** dans un dépôt public (`paperclip-pixeeplay` est public). Dépôt client privé uniquement. Ne recopie pas la transcription entière dans une tâche : résume, cite au besoin.
6. **Compte rendu** : à la fin de chaque passage, un commentaire sur cette routine : « aucune nouvelle visio » ou, par visio traitée, client, date, identifiant de la tâche créée et sous-tâches. Rien n'est envoyé au client sans validation d'Arnaud (board).
