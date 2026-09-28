# Scan de secrets — dépôts pixeeplay/*

`scan-pixeeplay.sh` clone (en bare) tous les dépôts non archivés du compte GitHub `pixeeplay`,
lance [gitleaks](https://github.com/gitleaks/gitleaks) sur l'historique complet, toutes branches,
avec les valeurs **masquées**, puis compare aux empreintes déjà connues.

- Exécution récurrente : routine Paperclip « Scan de secrets hebdomadaire (gitleaks) »
  (voir `company/tasks/scan-secrets-hebdo/TASK.md`).
- Référence : document `baseline-gitleaks` de l'issue PIXAAA-39 (hors dépôt, car ce dépôt est public).
- Pré-requis : `gh` avec le scope `repo`, `git`, `jq`. gitleaks est téléchargé s'il manque.

Le script ne publie rien et n'écrit dans aucun dépôt. Les rapports restent dans le dossier de travail.
