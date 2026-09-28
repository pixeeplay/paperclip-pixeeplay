#!/usr/bin/env bash
# Scan de secrets (gitleaks) sur tous les dépôts GitHub du compte pixeeplay.
#
# Usage :
#   bash scripts/secret-scan/scan-pixeeplay.sh [DOSSIER_DE_TRAVAIL] [BASELINE]
#     DOSSIER_DE_TRAVAIL  défaut : $PAPERCLIP_RUN_SCRATCH_DIR ou un mktemp
#     BASELINE            fichier d'empreintes déjà connues (une par ligne) ; optionnel
#
# Pré-requis : gh authentifié avec le scope `repo` (lecture des dépôts privés), jq, git.
# gitleaks est téléchargé automatiquement s'il est absent.
#
# Sorties (dans DOSSIER_DE_TRAVAIL/out) :
#   findings.json      tous les résultats, secrets MASQUÉS (--redact) — ne jamais publier
#   fingerprints.txt   empreintes (commit:fichier:règle:ligne), sans valeur de secret
#   new.txt            empreintes absentes de la BASELINE (= nouveaux secrets à traiter)
#   summary.md         résumé par dépôt et par règle, prêt à coller dans une issue
#
# Code retour : 0 = rien de nouveau, 2 = nouveaux résultats, 1 = erreur.
# Ce script ne publie rien et n'écrit dans aucun dépôt.
set -euo pipefail

OWNER="${GITLEAKS_OWNER:-pixeeplay}"
WORK="${1:-${PAPERCLIP_RUN_SCRATCH_DIR:-$(mktemp -d)}}/secret-scan"
BASELINE="${2:-}"
mkdir -p "$WORK/repos" "$WORK/reports" "$WORK/out"
cd "$WORK"

if ! command -v gitleaks >/dev/null 2>&1; then
  if [[ ! -x "$WORK/gitleaks" ]]; then
    gh release download -R gitleaks/gitleaks -p '*linux_x64.tar.gz' -D "$WORK" --clobber
    tar xzf "$WORK"/gitleaks_*_linux_x64.tar.gz -C "$WORK" gitleaks
  fi
  GITLEAKS="$WORK/gitleaks"
else
  GITLEAKS="$(command -v gitleaks)"
fi
echo "gitleaks $("$GITLEAKS" version)"

mapfile -t REPOS < <(gh repo list "$OWNER" --limit 500 --no-archived --json name --jq '.[].name' | sort)
echo "${#REPOS[@]} dépôts à scanner pour $OWNER"

FAILED=()
for r in "${REPOS[@]}"; do
  dir="repos/$r.git"
  if [[ -d "$dir" ]]; then
    git -C "$dir" fetch -q --prune origin '+refs/heads/*:refs/heads/*' || { FAILED+=("$r"); continue; }
  else
    gh repo clone "$OWNER/$r" "$dir" -- --bare -q 2>/dev/null || { FAILED+=("$r"); continue; }
  fi
  # Dépôt vide : rien à scanner
  git -C "$dir" rev-parse -q --verify HEAD >/dev/null 2>&1 || { echo "[]" > "reports/$r.json"; continue; }
  "$GITLEAKS" git "$dir" --log-opts="--all" --redact --no-banner --exit-code 0 \
    --report-format json --report-path "reports/$r.json" >/dev/null 2>&1 || FAILED+=("$r")
done

# Agrégation : on ajoute le nom du dépôt à chaque résultat
for f in reports/*.json; do r=$(basename "$f" .json); jq --arg r "$r" '[.[] | . + {Repo:$r}]' "$f"; done \
  | jq -s 'add // []' > out/findings.json
jq -r '.[] | "\(.Repo):\(.Fingerprint)"' out/findings.json | sort -u > out/fingerprints.txt

if [[ -n "$BASELINE" && -s "$BASELINE" ]]; then
  comm -23 out/fingerprints.txt <(sort -u "$BASELINE") > out/new.txt
else
  cp out/fingerprints.txt out/new.txt
fi

TOTAL=$(wc -l < out/fingerprints.txt | tr -d ' ')
NEW=$(wc -l < out/new.txt | tr -d ' ')
{
  echo "## Scan gitleaks — $OWNER/* — $(date -u +%Y-%m-%dT%H:%MZ)"
  echo
  echo "- Dépôts scannés : $(( ${#REPOS[@]} - ${#FAILED[@]} )) / ${#REPOS[@]} (historique complet, toutes branches)"
  echo "- Résultats : **$TOTAL** au total, **$NEW** nouveaux par rapport à la référence"
  [[ ${#FAILED[@]} -gt 0 ]] && echo "- Échecs de clonage/scan : ${FAILED[*]}"
  echo
  echo "### Par dépôt"
  echo
  echo "| Dépôt | Résultats | Règles |"
  echo "|---|---:|---|"
  jq -r 'group_by(.Repo)[] | "| \(.[0].Repo) | \(length) | \([.[].RuleID] | unique | join(", ")) |"' out/findings.json
  if [[ "$NEW" -gt 0 ]]; then
    echo
    echo "### Nouveaux résultats (secrets masqués)"
    echo
    echo "| Dépôt | Fichier | Ligne | Règle | Commit | Date |"
    echo "|---|---|---:|---|---|---|"
    jq -r --rawfile new out/new.txt '
      ($new | split("\n") | map(select(length>0))) as $n
      | .[] | select(("\(.Repo):\(.Fingerprint)") as $k | $n | index($k))
      | "| \(.Repo) | `\(.File)` | \(.StartLine) | \(.RuleID) | \(.Commit[0:8]) | \(.Date[0:10]) |"' out/findings.json \
      | awk 'NR<=200'
    [[ "$NEW" -gt 200 ]] && echo "" && echo "_(liste tronquée à 200 lignes — voir out/findings.json)_"
  fi
} > out/summary.md

cat out/summary.md
[[ ${#FAILED[@]} -gt 0 && ${#FAILED[@]} -eq ${#REPOS[@]} ]] && exit 1
[[ "$NEW" -gt 0 ]] && exit 2
exit 0
