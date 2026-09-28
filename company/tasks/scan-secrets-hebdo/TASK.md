---
name: Scan de secrets hebdomadaire (gitleaks)
slug: scan-secrets-hebdo
assignee: beffroi
project: suite-pixee
recurring: true
schedule: "30 5 * * 1"   # lundi 05:30 Europe/Paris
priority: medium
---

Chaque lundi, scanner **tous** les dépôts `pixeeplay/*` (historique complet, toutes branches) avec gitleaks
et signaler uniquement ce qui est **nouveau** depuis la référence.

1. Récupérer le script : `scripts/secret-scan/scan-pixeeplay.sh` de ce dépôt.
2. Récupérer la référence (empreintes connues, sans valeur de secret) : document `baseline-gitleaks`
   de l'issue PIXAAA-39 dans Paperclip. **Ne jamais la publier dans un dépôt public.**
3. Lancer : `bash scan-pixeeplay.sh "$PAPERCLIP_RUN_SCRATCH_DIR" baseline.txt`
   - code 0 : rien de nouveau → commentaire court sur l'issue de la routine, `done`.
   - code 2 : nouveaux résultats → coller `out/summary.md` en commentaire, ouvrir une issue
     « Secrets détectés » assignée à `@rempart` (tri + rotation), puis ajouter les nouvelles
     empreintes validées à la référence.
   - code 1 : échec → le signaler à `@beffroi`/`@cabinet`.
4. Les valeurs sont masquées (`--redact`). Ne jamais recopier une valeur de secret dans un commentaire.
