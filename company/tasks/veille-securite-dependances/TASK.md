---
name: Veille sécurité et dépendances
slug: veille-securite-dependances
assignee: devops-release
project: studio-operations
recurring: true
priority: medium
---

Chaque semaine, pour chaque dépôt `pixeeplay/client-*` :

- `npm audit --audit-level=high` (web/api), rapport Dependabot/Renovate, mises à jour Swift Package et Gradle.
- Ouvrir une PR groupée de mise à jour par dépôt, CI verte exigée ; les mises à jour majeures sont proposées au CTO, pas fusionnées d'office.
- Vérifier la santé des déploiements Coolify (`/health`) et la présence des sauvegardes de base des 7 derniers jours.
- Rendre compte en commentaire : dépôts audités, vulnérabilités hautes/critiques restantes, déploiements en anomalie.
