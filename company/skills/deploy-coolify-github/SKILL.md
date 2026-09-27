---
name: deploy-coolify-github
description: Créer et gérer les dépôts GitHub des clients (org pixeeplay) et leurs déploiements Coolify sur le VPS OVH du studio via l'API Coolify — application depuis dépôt, domaine de prévisualisation <slug>.pixeeplay.app, production après approbation, variables, healthcheck, rollback, runbook. À utiliser pour tout déploiement, changement de domaine ou incident.
metadata:
  paperclip:
    tags:
      - devops
      - coolify
      - github
      - deploiement
      - ovh
---

# Déploiement GitHub → Coolify (VPS OVH)

## Secrets company attendus
`GH_TOKEN` (PAT fine-grained, org `pixeeplay`) · `COOLIFY_URL` (ex. `http://51.75.31.123:8000`) · `COOLIFY_API_TOKEN` (API token *write*) · `COOLIFY_SERVER_UUID`, `COOLIFY_PROJECT_UUID` (projet « Clients »), `COOLIFY_ENV_NAME` (`production`). Sans ces secrets : la tâche est **bloquée**, on ne contourne pas.

## Conventions
- Dépôt : `pixeeplay/client-<slug>` — branches `develop` (prévisualisation) et `main` (production).
- Ressources Coolify : `client-<slug>-web`, `client-<slug>-api`, `client-<slug>-db` (Postgres) — nommage strict, une ressource par service.
- Domaines : prévisualisation `https://<slug>.pixeeplay.app` (wildcard DNS déjà pointé sur le VPS) ; production = domaine du client, uniquement après tâche d'approbation validée.
- Limites : `memory 512m` web / `768m` api par défaut (le VPS héberge déjà ~36 apps), pas de port hôte, tout passe par Traefik.

## Procédure — nouveau client
1. GitHub : `gh repo create pixeeplay/client-<slug> --private`, protection de `main`, secrets Actions nécessaires (voir skills Apple/Android), Dependabot activé.
2. Coolify (API `POST /api/v1/applications/private-github-app` ou `/public` selon l'accès du GitHub App) : `git_repository`, `git_branch=develop`, `build_pack=dockerfile`, `dockerfile_location=/Dockerfile.web`, `domains=https://<slug>.pixeeplay.app`, `health_check_enabled=true`, `health_check_path=/health`, `instant_deploy=false`.
3. Variables : `POST /api/v1/applications/{uuid}/envs/bulk` depuis `apps/web/.env.example` (valeurs depuis les secrets company, jamais en clair dans la tâche).
4. Base : `POST /api/v1/databases/postgresql` si le client a une base propre ; sauvegardes quotidiennes activées, 14 jours.
5. `POST /api/v1/deploy?uuid={uuid}` puis attendre `GET /api/v1/deployments/{deployment_uuid}` → `finished` ; vérifier `curl -fsS https://<slug>.pixeeplay.app/health`.
6. Écrire `clients/<slug>/RUNBOOK.md` : uuids, URLs, variables (noms seulement), procédure de rollback, contacts.
7. Commenter la tâche avec l'URL de prévisualisation et le lien du déploiement.

## Procédure — production (domaine client)
1. Tâche « Approbation : mise en production <slug> vX.Y.Z » assignée au board, avec checklist QA PASS, DNS prêt (`A`/`CNAME` vers le VPS), variables prod, sauvegarde faite.
2. Après approbation : ressource `client-<slug>-web-prod` sur `main`, domaine client, redéploiement, vérification `/health` et parcours critiques.
3. Tag et release GitHub (`plan-de-fonctions-versioning`), `JOURNAL.md` mis à jour.

## Rollback
`POST /api/v1/deploy?uuid={uuid}&tag=<tag précédent>` (ou redeploy du commit précédent) ; noter l'incident dans `RUNBOOK.md § Incidents`.

## Interdits
- Supprimer une ressource, un volume ou un dépôt (archiver, proposer au board).
- Exposer un port hôte, désactiver TLS, mettre un secret dans un commentaire ou un commit.
- Déployer en production sans approbation validée.
