# Déployer Paperclip sur le VPS OVH via Coolify

Cible : `https://paperclip.pixeeplay.com` — Coolify `http://51.75.31.123:8000`, serveur `localhost`.

## 0. Prérequis

- DNS : enregistrement `A paperclip.pixeeplay.com → 51.75.31.123` (propagé avant l'étape 3).
- Token Claude Max : sur ton Mac (Claude Code déjà connecté), `claude setup-token` → copier le token `sk-ant-oat01-…`.
- (Optionnel) PAT GitHub fine-grained pour les agents (`GH_TOKEN`) : Contents / Pull requests / Workflows en lecture-écriture sur `pixeeplay/*` et `cirquephotovideo/*`.

## 1. Créer la ressource

1. Coolify → **Projects** → projet *Pixeeplay* (ou nouveau) → environnement `production` → **+ New Resource**.
2. Choisir **Docker Compose Empty** (section *Docker Based*).
3. Coller le contenu de `deploy/docker-compose.yml`, **Save**.
4. Nom de la ressource : `paperclip`.

> Alternative GitOps : *Private Repository (with GitHub App)* → `pixeeplay/paperclip-pixeeplay`, branche `main`, **Build Pack = Docker Compose**, *Docker Compose Location* = `/deploy/docker-compose.yml`. Coolify redéploie alors à chaque push.

## 2. Domaine et variables

1. Onglet **General** → dans la carte du service `paperclip`, champ **Domains** : `https://paperclip.pixeeplay.com` (port 3100 déjà déclaré par `SERVICE_URL_PAPERCLIP_3100`). *Save*.
2. Onglet **Environment Variables** : Coolify a généré `SERVICE_URL_PAPERCLIP`, `SERVICE_PASSWORD_POSTGRES`, `SERVICE_PASSWORD_64_BETTERAUTH`, `SERVICE_PASSWORD_64_TOOLSIGNING`. Vérifier que `SERVICE_URL_PAPERCLIP` vaut bien `https://paperclip.pixeeplay.com`.
3. Ajouter (bouton *+ Add*) :
   - `CLAUDE_CODE_OAUTH_TOKEN` = token Max (cocher *Is Secret*)
   - `GH_TOKEN` = PAT GitHub (*Is Secret*)
   - `PAPERCLIP_AUTH_DISABLE_SIGN_UP` = `false` (pour l'instant)
4. **Deploy**. Premier démarrage ≈ 1–2 min (pull de l'image ~1,5 Go + migrations DB).

## 3. Vérifier

- Onglet **Logs** du service `paperclip` : attendre `listening on http://0.0.0.0:3100` et l'absence d'erreur de migration.
- `curl -s https://paperclip.pixeeplay.com/api/health` → `{"ok":true,...}`.

## 4. Premier administrateur (mode `authenticated/public`)

1. Ouvrir `https://paperclip.pixeeplay.com` → **Create account** avec `arnaud@pixeeplay.com` + mot de passe fort.
2. Coolify → service `paperclip` → **Terminal** → exécuter :
   ```sh
   pnpm paperclipai auth bootstrap-ceo --base-url https://paperclip.pixeeplay.com
   ```
   Le lien d'invitation à usage unique s'affiche.
3. Ouvrir ce lien dans le navigateur (session connectée) → tu deviens `instance_admin`, l'onboarding démarre.
4. Revenir dans Coolify → `PAPERCLIP_AUTH_DISABLE_SIGN_UP` = `true` → **Redeploy**. Plus personne ne peut créer de compte.

## 5. Importer la company Pixeeplay

Dans Paperclip : **Company → Import** → source GitHub :

```
https://github.com/pixeeplay/paperclip-pixeeplay/tree/main/company
```

ou depuis le terminal Coolify :

```sh
pnpm paperclipai company import https://github.com/pixeeplay/paperclip-pixeeplay/tree/main/company \
  --target new --new-company-name "Pixeeplay Studio" --yes
```

Puis, pour chaque agent : **Agents → (agent) → Adapter → Test environment** doit afficher *CLAUDE_CODE_OAUTH_TOKEN is set*. Activer le heartbeat du CEO (les heartbeats importés sont désactivés par sécurité).

## 6. Connecter GitHub et Coolify aux agents

- **Paperclip → Company → Settings → Secrets** : `GH_TOKEN`, `COOLIFY_API_TOKEN` (Coolify → Keys & Tokens → API tokens, droits *write*), `COOLIFY_URL=http://51.75.31.123:8000`.
- Les skills `deploy-coolify-github` et `site-factory-web` lisent ces secrets.

## 7. Mise à jour

Coolify → **Redeploy** (l'image `:latest` est re-tirée). Les données restent dans les volumes `paperclip-data` et `paperclip-pgdata`. Sauvegardes DB automatiques dans `/paperclip/backups` (14 jours).

## Dépannage

| Symptôme | Cause probable | Correction |
|---|---|---|
| 502 depuis Traefik | service pas encore *healthy* | attendre `start_period` (90 s), voir Logs |
| `authenticated public exposure requires auth.publicBaseUrl` | `SERVICE_URL_PAPERCLIP` vide | renseigner le domaine dans *Domains* puis Redeploy |
| Agent : `login required` | token Max absent/expiré | régénérer `claude setup-token`, mettre à jour la variable, Redeploy |
| Agent ne peut pas `git push` | `GH_TOKEN` manquant | secret company `GH_TOKEN` + `gh auth setup-git` dans le skill |
| Build iOS/Android impossible | le VPS est Linux | ces cibles passent par GitHub Actions (runner macOS) ou un Mac mini self-hosted, voir skill `apple-multiplateforme` |
