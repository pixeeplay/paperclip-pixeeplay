#!/usr/bin/env bash
# Pose le token d'abonnement Claude (Max) dans Coolify pour Paperclip, sans copier-coller.
#
# Usage (sur ton Mac, dans Terminal) :
#   bash ~/pixeeplay/paperclip-pixeeplay/deploy/set-claude-token.sh
#
# Ce que fait le script :
#   1. lance `claude setup-token` (une page d'autorisation s'ouvre : clique « Autoriser »,
#      puis colle le code dans le terminal si Claude te le demande) ;
#   2. récupère le token sk-ant-oat01-… affiché, le pose dans Coolify comme
#      CLAUDE_CODE_OAUTH_TOKEN de l'application Paperclip ;
#   3. redéploie Paperclip et attend que /api/health réponde.
# Le token n'est envoyé qu'à ton Coolify (http://51.75.31.123:8000) et le fichier
# temporaire est effacé à la fin.
set -euo pipefail

APP_UUID="${PAPERCLIP_COOLIFY_APP_UUID:-5osolxm2yfotabr5jhamazrf}"
COOLIFY_URL="${COOLIFY_URL:-http://51.75.31.123:8000}"
PUBLIC_URL="${PAPERCLIP_PUBLIC_URL:-https://paperclip.pixeeplay.com}"
TOKEN_API="${COOLIFY_API_TOKEN:-}"

if [[ -z "$TOKEN_API" && -f "$HOME/.config/pixeeplay/coolify_token" ]]; then
  TOKEN_API=$(tr -d '[:space:]' < "$HOME/.config/pixeeplay/coolify_token")
fi
if [[ -z "$TOKEN_API" ]]; then
  SKILL="$HOME/.claude/skills/pixeeplay-deploy/SKILL.md"
  if [[ -f "$SKILL" ]]; then
    TOKEN_API=$(grep -E '^COOLIFY_TOKEN' "$SKILL" | head -1 | sed -E 's/^[^=]*= *//' | tr -d '[:space:]')
  fi
fi
if [[ -z "$TOKEN_API" ]]; then
  read -rsp "Token API Coolify (Keys & Tokens) : " TOKEN_API; echo
fi

command -v claude >/dev/null 2>&1 || { echo "✗ La commande 'claude' (Claude Code) est introuvable." >&2; exit 1; }

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

echo "→ Autorisation Claude : une page va s'ouvrir, clique « Autoriser » (colle le code ici si demandé)."
claude setup-token 2>&1 | tee "$TMP"

CLAUDE_TOKEN=$(grep -oE 'sk-ant-oat01-[A-Za-z0-9_-]+' "$TMP" | tail -1 || true)
if [[ -z "$CLAUDE_TOKEN" ]]; then
  echo "✗ Aucun token sk-ant-oat01-… trouvé dans la sortie de 'claude setup-token'." >&2
  exit 1
fi
clear 2>/dev/null || true
echo "✓ Token récupéré (${#CLAUDE_TOKEN} caractères)."

H=(-H "Authorization: Bearer $TOKEN_API" -H "Content-Type: application/json" -H "Accept: application/json")
echo "→ Enregistrement dans Coolify (CLAUDE_CODE_OAUTH_TOKEN)…"
RESP=$(curl -s "${H[@]}" -X PATCH -d "{\"key\":\"CLAUDE_CODE_OAUTH_TOKEN\",\"value\":\"$CLAUDE_TOKEN\",\"is_shown_once\":true}" "$COOLIFY_URL/api/v1/applications/$APP_UUID/envs")
unset CLAUDE_TOKEN
echo "$RESP" | grep -q '"key":"CLAUDE_CODE_OAUTH_TOKEN"' || { echo "✗ Coolify a refusé : $RESP" >&2; exit 1; }
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
echo "Terminé. Dans Paperclip → Agents → Directeur de studio → Harness / Runtime → « Run test » doit être vert,"
echo "puis « Resume » sur les agents (ou dis à Claude « token posé »)."
