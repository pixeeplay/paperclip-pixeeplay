---
name: charte-graphique-client
description: Dériver la charte graphique d'un client (tokens W3C Design Tokens, DESIGN.md, maquettes HTML/SVG) à partir du brief et de la famille de métier, avec contrastes WCAG vérifiés, puis générer les sorties CSS, Swift et Kotlin. À utiliser pour tout nouveau client, tout rebranding et toute revue de conformité visuelle.
metadata:
  paperclip:
    tags:
      - design
      - tokens
      - charte
      - accessibilite
---

# Charte graphique client → tokens multi-plateforme

## Livrables
- `clients/<slug>/design/tokens.json` (format W3C Design Tokens, groupes `color`, `font`, `size`, `radius`, `shadow`, `motion`).
- `clients/<slug>/DESIGN.md` — positionnement, choix expliqués, règles d'usage, contrastes mesurés.
- `clients/<slug>/design/mockups/` — `home-web.html`, `home-ios.svg`, `home-android.svg` (+ `watch.svg`, `tv.svg` si demandés).
- Dans le dépôt : `packages/design-tokens/` avec `build.mjs` (Style Dictionary) → `dist/tokens.css`, `dist/Tokens.swift`, `dist/Tokens.kt`.

## Procédure
1. Lire `BRIEF.md § Identité visuelle` et `§ Ton`, et la famille de métier. Si un logo est fourni : extraire ses couleurs dominantes ; sinon proposer une palette (jamais de logo inventé pour une marque tierce ; un logotype typographique sobre est acceptable et indiqué comme provisoire).
2. **Palette** : 1 couleur de marque, 1 accent, 1 neutre chaud ou froid en 10 paliers, sémantiques `success/warning/danger/info`. Vérifier chaque paire texte/fond utilisée : ≥ 4,5:1 corps, ≥ 3:1 titres et composants ; noter les ratios dans `DESIGN.md`. Mode sombre dérivé, pas inversé.
3. **Typographie** : 1 famille titres + 1 famille corps (Google Fonts auto-hébergées ou fonte du client avec licence notée), échelle 1,2–1,25, tailles minimales 16 px web / 17 pt iOS / 16 sp Android.
4. **Formes** : rayons (3 paliers), ombres (2 paliers), espacement base 4 px, grille 12 colonnes web.
5. **Métier** : appliquer les codes du secteur sans cliché (voir `references/moods-par-famille.md`) ; expliquer en 3 lignes.
6. Écrire `tokens.json`, générer les trois sorties, produire les maquettes de référence en HTML/SVG statique avec les tokens réels.
7. Ouvrir une PR `design: charte <slug> v1` avec `DESIGN.md` en description ; demander la revue du CPO.

## Format `tokens.json` (extrait)
```json
{
  "color": {
    "brand": { "500": { "$value": "#B5651D", "$type": "color" } },
    "text":  { "primary": { "$value": "{color.neutral.900}", "$type": "color" } }
  },
  "font": { "family": { "heading": { "$value": "Fraunces", "$type": "fontFamily" } } },
  "radius": { "md": { "$value": "12px", "$type": "dimension" } }
}
```

## Règles
- Les tokens sont la seule source de vérité ; toute couleur en dur dans une PR est un motif de refus en revue design.
- Pas de visuel, mascotte, icône ou logo d'une marque tierce ; les pictogrammes viennent de Lucide/SF Symbols/Material Symbols.
- Chaque changement de charte incrémente `design.version` dans `tokens.json` et régénère les trois sorties dans la même PR.
