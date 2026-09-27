#!/usr/bin/env bash
# Donne l'accès GitHub aux agents Paperclip : pose GH_TOKEN dans Coolify, redéploie, vérifie.
#
# Usage (sur ton Mac, dans Terminal) :
#   bash ~/pixeeplay/paperclip-pixeeplay/deploy/set-github-token.sh
#
# Ce que fait le script :
#   1. propose d'utiliser le token du compte GitHub connecté dans `gh` (sinon demande un PAT) ;
#   2. vérifie que le token voit l'organisation `pixeeplay` ;
#   3. le pose dans Coolify comme GH_TOKEN de l'application Paperclip, puis redéploie ;
#   4. attend que https://paperclip.pixeeplay.com réponde.
# Le token n'est envoyé qu'à ton Coolify (http://51.75.31.123:8000) et n'est jamais affiché.
set -euo pipefail

APP_UUID="${PAPERCLIP_COOLIFY_APP_UUID:-5osolxm2yfotabr5jhamazrf}"
COOLIFY_URL="${COOLIFY_URL:-http://51.75.31.123:8000}"
PUBLIC_URL="${PAPERCLIP_PUBLIC_URL:-https://paperclip.pixeeplay.com}"
GITHUB_ORG="${GITHUB_ORG:-pixeeplay}"
TOKEN_API="${COOLIFY_API_TOKEN:-}"

if [[ -z "$TOKEN_API" && -f "$HOME/.config/pixeeplay/coolify_token" ]]; then
  TOKEN_API=$(tr -d '[:space:]' < "$HOME/.config/pixeeplay/coolify_token")
fi
if [[ -z "$TOKEN_API" ]]; then
  read -rsp "Token API Coolify (Keys & Tokens) : " TOKEN_API; echo
fi

# --- 1. Token GitHub ---------------------------------------------------------
GH=""
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
  LOGIN=$(gh api user -q .login 2>/dev/null || echo "?")
  SCOPES=$(gh auth status 2>&1 | grep -o 'Token scopes:.*' || true)
  echo "Compte GitHub connecté dans gh : $LOGIN  ($SCOPES)"
  read -rp "Utiliser ce token gh comme GH_TOKEN des agents ? [O/n] " ans
  if [[ "${ans:-O}" =~ ^[OoYy]?$ ]]; then GH=$(gh auth token); fi
fi
if [[ -z "$GH" ]]; then
  echo "Crée un PAT fine-grained sur https://github.com/settings/personal-access-tokens/new"
  echo "  Resource owner = $GITHUB_ORG · Repository access = All · Permissions : Administration (RW),"
  echo "  Contents (RW), Pull requests (RW), Metadata (R), Workflows (RW)."
  read -rsp "PAT GitHub : " GH; echo
fi
[[ -n "$GH" ]] || { echo "✗ Aucun token GitHub." >&2; exit 1; }

# --- 2. Vérification ----------------------------------------------------------
GH_LOGIN=$(curl -fsS -H "Authorization: Bearer $GH" https://api.github.com/user 2>/dev/null \
  | sed -n 's/.*"login": *"\([^"]*\)".*/\1/p' | head -1 || true)
[[ -n "$GH_LOGIN" ]] || { echo "✗ GitHub refuse ce token." >&2; exit 1; }
echo "✓ Token GitHub valide (compte $GH_LOGIN)."
if curl -fsS -o /dev/null -H "Authorization: Bearer $GH" "https://api.github.com/orgs/$GITHUB_ORG/repos?per_page=1"; then
  echo "✓ L'organisation $GITHUB_ORG est visible avec ce token."
else
  echo "! Le token ne voit pas l'organisation $GITHUB_ORG (droits insuffisants ?) — je continue quand même."
fi

# --- 3. Coolify -----------------------------------------------------------------
H=(-H "Authorization: Bearer $TOKEN_API" -H "Content-Type: application/json" -H "Accept: application/json")
BODY="{\"key\":\"GH_TOKEN\",\"value\":\"$GH\",\"is_shown_once\":true}"
echo "→ Enregistrement de GH_TOKEN dans Coolify…"
RESP=$(curl -s "${H[@]}" -X PATCH -d "$BODY" "$COOLIFY_URL/api/v1/applications/$APP_UUID/envs")
if ! echo "$RESP" | grep -q '"key":"GH_TOKEN"'; then
  RESP=$(curl -s "${H[@]}" -X POST -d "$BODY" "$COOLIFY_URL/api/v1/applications/$APP_UUID/envs")
fi
unset GH
echo "$RESP" | grep -q 'GH_TOKEN\|"uuid"' || { echo "✗ Coolify a refusé : $RESP" >&2; exit 1; }
echo "✓ Variable posée."

echo "→ Redéploiement de Paperclip…"
curl -s "${H[@]}" -X POST "$COOLIFY_URL/api/v1/deploy?uuid=$APP_UUID" >/dev/null
echo -n "→ Attente du redémarrage "
sleep 40
for i in $(seq 1 30); do
  if curl -fsS -m 10 "$PUBLIC_URL/api/health" 2>/dev/null | grep -q '"status":"ok"'; then echo " ✓"; break; fi
  echo -n "."; sleep 10
  [[ $i -eq 30 ]] && { echo; echo "✗ Paperclip ne répond pas encore — vérifie les logs dans Coolify." >&2; exit 1; }
done
echo
echo "Terminé. Dans Paperclip → tâche PIX-4 → « Run now » sur le CTO : il doit créer pixeeplay/client-<slug>."
