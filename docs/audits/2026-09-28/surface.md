# Cartographie de la surface d'attaque — Pixeeplay Co.

Auteur : Rempart — Sécurité · Date : 2026-09-28 · Issue : PIXAAA-28

Premier passage de cartographie. Collecte en lecture seule uniquement (DNS,
en-têtes HTTP publics, listing GitHub, lecture de fichiers de skills/dépôts).
Aucune action destructive, aucune exploitation au-delà de la preuve de
constat. Les zones non vérifiables depuis cet environnement sont marquées
**à vérifier**, pas devinées.

## 0. Secret trouvé en clair — résultat

Consigne de départ : faire tourner tout secret en clair, en commençant par le
token Coolify de `pixeeplay-deploy`.

- **`pixeeplay-deploy` (skill)** : le token Coolify **n'est pas en clair**.
  Le fichier contient une note explicite (« copie embarquée : le token
  Coolify a été retiré, variable `COOLIFY_TOKEN` fournie par Paperclip via
  `COOLIFY_API_TOKEN` ») et `${COOLIFY_TOKEN}` n'est qu'un placeholder shell.
  `coolify.sh` lit la variable d'environnement, ne la contient pas.
- **Balayage complet du catalogue de skills** (97 skills, tous dossiers) avec
  des motifs de secrets usuels (JWT `eyJ…`, `sk-`, `AIza`, `ghp_`,
  `github_pat_`, `xox[baprs]-`, `AKIA`, clés privées PEM, `TOKEN=`/`SECRET=`/
  `PASSWORD=` suivis d'une valeur littérale) : **aucun résultat positif**, à
  l'exception d'un `ADMIN_PASSWORD` généré dynamiquement par du code
  (`crypto.randomBytes`), pas une valeur figée.
- **Recherche GitHub code search sur le compte `pixeeplay`** (repos publics et
  privés accessibles) pour `COOLIFY_API_TOKEN`, `COOLIFY_TOKEN=`,
  `SUPABASE_SERVICE_ROLE_KEY`, `sk-ant-`, `BEGIN PRIVATE KEY`, `AIzaSy`,
  `ghp_`, `xoxb-`, `postgres://`, `AWS_SECRET_ACCESS_KEY` : uniquement des
  références à des variables d'environnement (`Deno.env.get(...)`) ou des
  `.env.example` avec valeurs factices (`tronco_secret`, `your-secret-here`).
  **Aucun secret réel en clair identifié** dans cette passe.
- `paperclip-pixeeplay/deploy/rotate-coolify-token.sh` existe déjà et
  fonctionne (usage manuel, poste un nouveau token Coolify puis rappelle de
  révoquer l'ancien). Bonne pratique déjà en place.

**Conclusion** : rien à faire tourner dans l'immédiat sur cette base — pas de
fuite constatée dans les dépôts/skills couverts par ce balayage. Ce
balayage n'est pas exhaustif (voir « Limites » §5) : rotation préventive du
token Coolify recommandée en hygiène de routine, mais ce n'est plus une
urgence « fuite confirmée ». Décision : ne pas déclencher de rotation en
urgence tant qu'aucune fuite n'est confirmée (éviter une rotation inutile qui
casserait les agents en prod sans bénéfice de sécurité net) — sauf avis
contraire de `@beffroi`/`@cabinet`.

## 1. Domaines (résolution DNS depuis cet environnement, 2026-09-28)

| Domaine | IP résolue | Hébergeur apparent | Constat HTTP |
|---|---|---|---|
| pixeeplay.com | 109.234.167.172 | o2switch (`server: o2switch-PowerBoost-v3`) | 301 → https, répond |
| pixeeplay.fr | 109.234.167.172 | o2switch | 301 → https, répond |
| chaudpata.com | 104.21.28.136 | Cloudflare (proxy, `cf-ray`) | 200 |
| mymockup.fr | 57.130.64.37 | à vérifier (pas de réponse HTTPS depuis ce sandbox — DNS seul, réseau sortant possiblement filtré ou site down) | pas de réponse (timeout `curl` code 000) |
| pixeecrawl.com | 79.137.75.196 | à vérifier | 200, en-têtes non concluants |
| paperclip.pixeeplay.com | 51.75.31.123 | **VPS OVH Coolify** (confirmé, `x-powered-by: Express` = Paperclip lui-même) | 200 |
| supabase.pixeeplay.fr | 51.75.31.123 | **VPS OVH Coolify**, Supabase self-hosted | 401 (Kong/2.8.1) — endpoint exposé mais protégé, comportement attendu |

**Écart avec la mémoire de convention** : `pixeeplay-conventions` indique
« Domaines chez Hostinger » pour `pixeeplay.com`/`pixeeplay.fr`. La
résolution DNS actuelle pointe vers de l'IP **o2switch**, pas Hostinger.
Soit le compte d'hébergement a changé, soit c'est un proxy/redirection
intermédiaire. **À confirmer auprès de qui gère le compte Hostinger avant de
corriger la mémoire** — je ne corrige pas sur la seule base d'une résolution
DNS sans accès au panneau d'hébergement.

Domaine `chaudpata.com` : passe par Cloudflare, donc l'IP d'origine réelle du
serveur n'est pas directement visible depuis l'extérieur (normal, mais à
noter — c'est une frontière de sécurité en plus, contrôlée par qui a accès au
compte Cloudflare).

## 2. Coolify — VPS OVH 51.75.31.123

- Confirmé en ligne : `paperclip.pixeeplay.com` (Paperclip lui-même) et
  `supabase.pixeeplay.fr` (instance Supabase self-hosted) y répondent.
- Panneau Coolify accessible en théorie sur `http://51.75.31.123:8000` (port
  cité dans tous les skills de déploiement) — **non testé** : sonder un
  panneau d'admin sans y être autorisé/attendu dépasse la collecte passive
  prévue pour ce premier passage.
- **Je n'ai pas d'accès API Coolify** (`GET /api/agents/me/secrets` renvoie
  une liste vide pour ce run — aucun secret `COOLIFY_*` ne m'est attribué). Je
  ne peux donc pas lister moi-même les applications/domaines/bases de données
  réellement déployées sur ce Coolify. **Donnée manquante — voir §5.**
- D'après `paperclip-pixeeplay/deploy/COOLIFY.md` et `rotate-coolify-token.sh` :
  l'app Paperclip a l'UUID `5osolxm2yfotabr5jhamazrf`, le serveur Coolify
  `n04c4gowg84k8cs40sckck80`. Les autres apps (sites clients, `PixeePIM-*`,
  etc.) ne sont pas énumérées dans ce que j'ai pu lire.

## 3. Supabase (`supa-pix`, supabase.pixeeplay.fr)

- L'endpoint public répond `401` via Kong (le gateway Supabase) — pas
  d'accès anonyme aux API REST/Auth sans clé, c'est le comportement attendu.
- Recherche de `SUPABASE_SERVICE_ROLE_KEY` en clair dans les dépôts : négatif
  (voir §0) — uniquement des lectures de variable d'environnement.
- **Non vérifié** dans ce passage : politiques RLS, clés `anon`/`service_role`
  effectivement déployées, comptes ayant les clés admin. Nécessite soit un
  accès direct au dashboard Supabase (`@amiral`/`@beffroi` ?), soit un audit
  dédié `site-security-audit` sur le projet `pixeeback`.

## 4. GitHub — comptes et dépôts

- **Identité réelle utilisée par les agents** : compte utilisateur GitHub
  `pixeeplay` (`https://github.com/pixeeplay`), **pas** une organisation
  `pixeeplayteam` — écart avec `pixeeplay-conventions` qui mentionne les
  organisations `pixeeplayteam` et `SecuHubLive`. Le token `GH_TOKEN` de ce
  run est scope `gist, read:org, repo` sur ce compte `pixeeplay`.
- `gh api user/orgs` renvoie une liste vide pour cette identité — aucune
  organisation GitHub n'est visible depuis ce token. **À vérifier** :
  `pixeeplayteam`/`SecuHubLive`/`cirquephotovideo` existent peut-être sous
  un autre compte/token que je n'ai pas ici.
- **~70 dépôts** accessibles sous `pixeeplay/*` (`gh repo list`), très
  majoritairement privés. 5 publics repérés : `france-finances`,
  `paperclip-pixeeplay`, `pixeesite`, `simplif-ia-france`,
  `style-wizard-ai-59` — **à revalider que ces 5 doivent bien être publics**
  (un dépôt public expose son historique complet, y compris tout secret
  jamais commité puis « retiré »).
- Dépôts notables repérés (rôle déduit du nom/description, pas audité en
  profondeur) :
  - `paperclip-pixeeplay` — infra Paperclip + spec company (celui-ci, PR
    jointe).
  - `PixeePIM-App`, `PixeePIM-Web`, `PixeePIM-WebDoc`, `PixeePIM-ApiDoc`,
    `PixeePIM-Sync` — suite Pixee PIM (produit interne / client).
  - `PixeeSentinel` — outil de QA exploratoire (Playwright), pas un outil de
    sécurité malgré le nom proche de « sentinel ».
  - `beffroi-gateway` — app front (Vite/React), rôle exact à confirmer avec
    `@beffroi`.
  - `secuhub` — « tour de contrôle personnel », rôle exact à confirmer.
  - `chaudpata`, `pixeeplay-website`, `PixeeCommerce`, `PixeeCommerce-Web`,
    `PixeeCrawl-Web`, `Commerce-ai` — sites/apps clients ou produits.
  - `Commerce-ai` contient des Supabase Edge Functions utilisant
    `SUPABASE_SERVICE_ROLE_KEY` (via `Deno.env.get`, pas en clair) — projet à
    inclure dans un futur audit RLS dédié.
  - `odoo-*` (plusieurs dépôts) — intégrations Odoo, surface tierce
    supplémentaire à cartographier séparément.

## 5. Limites de ce premier passage (à traiter en suivi)

Je n'ai pas inventé de chiffres au-delà de ce que j'ai pu vérifier. Ce qui
manque encore pour une cartographie complète :

1. **Accès Coolify (lecture)** : aucun secret `COOLIFY_API_TOKEN` ne m'est
   attribué en tant que Rempart. Sans lui, impossible de lister les vraies
   applications/domaines/bases déployées sur le VPS OVH. → proposition :
   demander à `@cabinet`/`@beffroi` un accès Coolify **lecture seule** dédié
   à Rempart pour les audits hebdomadaires, distinct du token « write » de
   l'agent DevOps.
2. **Accès Supabase (dashboard)** : RLS, clés `anon`/`service_role`, comptes
   admin, 2FA — non vérifiés ici.
3. **70 dépôts** listés mais pas tous ouverts en détail : le balayage de
   secrets a porté sur des motifs génériques (recherche GitHub code search),
   pas sur une lecture fichier par fichier de chaque dépôt. Un scanner dédié
   (ex. gitleaks/trufflehog) sur l'ensemble du compte `pixeeplay` donnerait
   une couverture plus fiable que des `grep` ciblés.
4. **mymockup.fr** ne répond pas depuis ce sandbox (DNS seul) — à retester
   depuis un poste avec accès réseau non filtré avant de conclure à un site
   éteint.
5. **Comptes tiers** (Hostinger ×2, Resend, Zernio, Meta Graph API,
   Higgsfield, Seedance/fal.ai, Tailscale, Attio) : inventaire déclaratif
   repris de la mémoire de convention, **pas revérifié compte par compte**
   (qui y accède, quel niveau de droit, 2FA actif) — nécessite un accès
   direct à chacun de ces panneaux, que je n'ai pas depuis cet environnement.
6. **Organisations GitHub `pixeeplayteam`/`SecuHubLive`** mentionnées dans
   la mémoire de convention : invisibles depuis le token de ce run — à
   clarifier si elles existent réellement ou si la convention est obsolète.

## Recommandation

- Pas de rotation d'urgence : aucune fuite confirmée dans ce passage.
- Ouvrir un accès Coolify **lecture seule** pour Rempart (item 1 ci-dessus) —
  condition pour qu'un prochain audit hebdomadaire puisse réellement
  cartographier les apps/domaines Coolify au lieu de les déduire des dépôts.
- Faire confirmer/corriger par `@cabinet` les deux écarts mémoire relevés :
  hébergeur réel de `pixeeplay.com`/`.fr` (o2switch vs Hostinger) et
  existence des organisations GitHub `pixeeplayteam`/`SecuHubLive`.
- Passer un scanner de secrets dédié (gitleaks) sur l'ensemble des ~70 dépôts
  `pixeeplay/*` en tâche de suivi — cette passe manuelle par motifs n'est
  qu'un premier filtre.
