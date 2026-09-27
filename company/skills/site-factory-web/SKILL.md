---
name: site-factory-web
description: Créer et faire évoluer le dépôt d'un client (monorepo pixeeplay/client-<slug>) et son site web + API + back-office à partir du gabarit Pixeeplay (Next.js 15, TypeScript, Tailwind, shadcn/ui, tokens, contenus Markdown, Dockerfile Coolify), avec intégrations Odoo / PrestaShop / Pixee PIM. À utiliser pour tout scaffold, nouvelle page ou fonction web.
metadata:
  paperclip:
    tags:
      - web
      - nextjs
      - scaffold
      - backoffice
      - integration
---

# Site factory — web, API, back-office

## Structure du dépôt client (monorepo pnpm)
```
client-<slug>/
├── apps/web/          Next.js 15 (App Router), site public + formulaires
├── apps/api/          Hono (Node 22) — devis, RDV, webhooks ERP ; ou Route Handlers si trivial
├── apps/backoffice/   Refine + shadcn (optionnel si Odoo/PIM fait déjà office de back-office)
├── apps/apple/        (skill apple-multiplateforme)
├── apps/android/      (skill android-compose)
├── packages/design-tokens/   tokens.json → CSS / Swift / Kotlin
├── packages/shared/          types zod, clients API, integrations/{odoo,prestashop,pixeepim}
├── content/           pages, ui/fr.json, emails, legal, seo (skill communication-metier)
├── clients/<slug>/    BRIEF, PLAN-FONCTIONS, VERSIONS, DESIGN, COMMUNICATION, JOURNAL, recette/
├── docs/              ADR courts, RUNBOOK
├── .github/workflows/ web.yml, api.yml, apple.yml, android.yml
├── Dockerfile.web  Dockerfile.api   (multi-stage, node:22-alpine, healthcheck /health)
└── CHANGELOG.md  README.md
```

## Procédure de scaffold (CTO puis Lead Web)
1. `gh repo create pixeeplay/client-<slug> --private --template pixeeplay/client-template` (si le gabarit n'existe pas encore : générer la structure ci-dessus depuis ce skill, puis proposer au board d'en faire un template).
2. Protection de `main` (PR + CI), branche `develop`, labels `needs-design-review`, `needs-qa`, `legal`.
3. `pnpm create next-app@latest apps/web --ts --tailwind --app --src-dir --eslint --import-alias "@/*"` ; ajouter shadcn/ui, `next-intl` (FR par défaut), `@vercel/og` pour les images sociales, `sharp`.
4. Brancher les tokens : `packages/design-tokens/dist/tokens.css` importé dans `globals.css` ; les classes Tailwind lisent les variables (`--color-brand-500`).
5. Charger les contenus : `content/pages/*.md` → routes `[slug]`, `content/ui/fr.json` → `useTranslations`, `content/legal` → `/mentions-legales`, `/confidentialite`, `/cgv`.
6. Formulaires : validation zod partagée, anti-spam (honeypot + limitation de débit), envoi via API → e-mail (Resend ou SMTP mailcow du studio) + enregistrement (Postgres ou ERP).
7. SEO : `metadata` par page, `sitemap.ts`, `robots.ts`, JSON-LD depuis `content/seo/`, images `og`.
8. Accessibilité : landmarks, focus visible, `alt` obligatoires, `eslint-plugin-jsx-a11y`, test axe dans Playwright.
9. `Dockerfile.web` (standalone output), `/health` renvoyant `{ok:true, version}`, `.env.example` complet.
10. CI `web.yml` : lint, typecheck, test, build, Lighthouse CI (mobile ≥ 90 accueil).

## Intégrations ERP (packages/shared/integrations)
- **Odoo** : JSON-RPC (`/web/dataset/call_kw`), clé API utilisateur dédiée, lecture `product.product`/`product.template`, création `sale.order` ou `crm.lead` selon le brief ; synchro cron toutes les 15 min, cache local.
- **PrestaShop** : Webservice XML/JSON, clé WS par ressource ; produits/catégories en lecture, commandes en écriture si Click & Collect.
- **Pixee PIM** : API REST du PIM (jeton compagnie) ; le PIM est la source des fiches produit enrichies quand il est présent.
- Règle : le site ne ressaisit jamais un produit qui existe dans l'ERP ; en cas de conflit, l'ERP gagne.

## Définition de terminé (v0.1 web)
- Accueil, offre, à propos, contact/RDV, mentions légales, confidentialité en ligne sur `https://<slug>.pixeeplay.app`.
- Tokens appliqués, mode sombre, mobile d'abord, Lighthouse mobile ≥ 90, axe 0 erreur critique.
- Formulaire testé de bout en bout (message réellement reçu).
- README : lancer en local, variables, déploiement.
