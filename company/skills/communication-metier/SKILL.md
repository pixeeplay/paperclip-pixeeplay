---
name: communication-metier
description: Définir le ton et écrire les contenus d'un client (COMMUNICATION.md, pages du site, micro-copy des apps, e-mails transactionnels, fiches stores, mentions légales) et poser le SEO local France adapté au métier. À utiliser pour tout nouveau client, toute nouvelle page ou écran, et à chaque changement d'offre.
metadata:
  paperclip:
    tags:
      - communication
      - contenu
      - seo
      - legal
---

# Communication métier → contenus prêts à intégrer

## Livrables
- `clients/<slug>/COMMUNICATION.md` — promesse, messages clés, ton, vocabulaire, personas, preuves autorisées, CTA.
- `clients/<slug>/content/pages/*.md` (frontmatter `title`, `description`, `slug`, `schema`) — une page par entrée du plan de site.
- `clients/<slug>/content/ui/fr.json` — micro-copy des apps et du site (clés stables `home.hero.title`, `form.error.required`…).
- `clients/<slug>/content/emails/*.md` — confirmation, rappel J-1, devis envoyé, mot de passe.
- `clients/<slug>/content/legal/` — mentions légales, confidentialité, CGV/CGU, cookies (depuis `references/legal-fr.md`, champs à compléter marqués `{{ }}`).
- `clients/<slug>/content/stores/` — fiche App Store (nom ≤ 30, sous-titre ≤ 30, description, mots-clés ≤ 100) et Play Store (titre ≤ 30, courte ≤ 80, longue ≤ 4000).
- `clients/<slug>/content/seo/` — plan de site, titres/descriptions, données structurées `LocalBusiness` (sous-type métier), FAQ, textes Google Business Profile.

## Procédure
1. Lire `BRIEF.md § Ton`, `§ Cibles`, `§ Offre`, la famille de métier (`brief-metier-client/references/familles-metier.md`).
2. Écrire `COMMUNICATION.md` : promesse (≤ 12 mots), 3 messages clés avec la preuve associée (ou « preuve à obtenir »), registre (vouvoiement par défaut ; tutoiement seulement si le brief le dit), 10 mots à utiliser / 10 à bannir, 2 personas, CTA principal et secondaire.
3. Plan de site depuis `PLAN-FONCTIONS.md` (une page par fonction `F-WEB-*` visible + pages légales). Écrire chaque page : H1 unique, chapô, sections courtes, CTA, FAQ métier (3–5 questions réelles).
4. Micro-copy : états vides, erreurs (dire quoi faire), confirmations, boutons (verbe + objet), notifications push (≤ 60 caractères).
5. E-mails : objet ≤ 50 caractères, une action par e-mail, coordonnées et lien de gestion des données.
6. SEO local : mots-clés « métier + ville/quartier », `LocalBusiness` avec horaires, zone, `priceRange`, avis uniquement si réels et autorisés ; page par zone seulement si le brief couvre plusieurs zones.
7. Relecture : typographie française, aucune promesse de résultat pour les professions réglementées, aucun superlatif sans preuve.

## Règles
- Pas de faux avis, pas de témoignage inventé, pas de chiffre non sourcé.
- Professions réglementées : information générale, renvoi vers le professionnel, respect des règles déontologiques de la profession.
- Les contenus sont en français ; toute autre langue est une fonction `F-COM-*` à part (i18n).
