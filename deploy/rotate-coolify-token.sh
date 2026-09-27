#!/usr/bin/env bash
# Fait tourner le token API Coolify et le met à disposition de l'agent DevOps & Release.
#
# Usage (sur ton Mac, dans Terminal) :
#   bash ~/pixeeplay/paperclip-pixeeplay/deploy/rotate-coolify-token.sh
#
# Avant : crée un NOUVEAU token dans Coolify → Keys & Tokens → API tokens
#   (http://51.75.31.123:8000/security/api-tokens, permission « root » ou « write »).
# Ce que fait le script :
#   1. demande le nouveau token et vérifie qu'il fonctionne ;
#   2. l'enregistre dans ~/.config/pixeeplay/coolify_token (lu par tous les scripts et le skill) ;
#   3. pose COOLIFY_URL / COOLIFY_API_TOKEN / COOLIFY_SERVER_UUID / COOLIFY_PROJECT_UUID
#      dans l'application Paperclip (Coolify) et redéploie ;
#   4. te rappelle de révoquer l'ANCIEN token dans l'interface Coolify.
set -euo pipefail

APP_UUID="${PAPERCLIP_COOLIFY_APP_UUID:-5osolxm2yfotabr5jhamazrf}"
COOLIFY_URL="${COOLIFY_URL:-http://51.75.31.123:8000}"
PUBLIC_URL="${PAPERCLIP_PUBLIC_URL:-https://paperclip.pixeeplay.com}"
SERVER_UUID="${COOLIFY_SERVER_UUID:-n04c4gowg84k8cs40sckck80}"
CFG_DIR="$HOME/.config/pixeeplay"
CFG="$CFG_DIR/coolify_token"

echo "Crée un nouveau token ici : $COOLIFY_URL/security/api-tokens  (nom conseillé : paperclip-agents-$(date +%Y%m))"
read -rsp "Nouveau token API Coolify : " NEW; echo
NEW=$(echo "$NEW" | tr -d '[:space:]')
[[ -n "$NEW" ]] || { echo "✗ Token vide." >&2; exit 1; }

H=(-H "Authorization: Bearer $NEW" -H "Content-Type: application/json" -H "Accept: application/json")
VER=$(curl -fsS -m 15 "${H[@]}" "$COOLIFY_URL/api/v1/version" 2>/dev/null || true)
[[ -n "$VER" ]] || { echo "✗ Coolify refuse ce token (vérifie qu'il est bien copié et a la permission write/root)." >&2; exit 1; }
echo "✓ Token valide (Coolify $VER)."

mkdir -p "$CFG_DIR"; chmod 700 "$CFG_DIR"
OLD_ID=""
if [[ -f "$CFG" ]]; then OLD_ID=$(cut -d'|' -f1 < "$CFG" | tr -d '[:space:]'); fi
umask 077; printf '%s\n' "$NEW" > "$CFG"; chmod 600 "$CFG"
echo "✓ Enregistré dans $CFG."

# Projet Coolify qui héberge Paperclip (pour l'agent DevOps)
PROJECT_UUID=$(curl -fsS "${H[@]}" "$COOLIFY_URL/api/v1/projects" 2>/dev/null \
  | python3 -c 'import sys,json
ps=json.load(sys.stdin)
m=[p for p in ps if str(p.get("name","")).lower().startswith("paperclip")]
print((m or ps or [{}])[0].get("uuid",""))' 2>/dev/null || true)

set_env() { # key value shown_once
  local body="{\"key\":\"$1\",\"value\":\"$2\",\"is_shown_once\":$3}"
  local resp
  resp=$(curl -s "${H[@]}" -X PATCH -d "$body" "$COOLIFY_URL/api/v1/applications/$APP_UUID/envs")
  echo "$resp" | grep -q "\"key\":\"$1\"" || resp=$(curl -s "${H[@]}" -X POST -d "$body" "$COOLIFY_URL/api/v1/applications/$APP_UUID/envs")
  echo "$resp" | grep -q "$1\|\"uuid\"" && echo "  ✓ $1" || echo "  ✗ $1 : $resp"
}
echo "→ Variables pour l'agent DevOps & Release (application Paperclip)…"
set_env COOLIFY_URL "$COOLIFY_URL" false
set_env COOLIFY_SERVER_UUID "$SERVER_UUID" false
[[ -n "$PROJECT_UUID" ]] && set_env COOLIFY_PROJECT_UUID "$PROJECT_UUID" false
set_env COOLIFY_API_TOKEN "$NEW" true
unset NEW

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
echo "Dernière étape (à la main) : révoque l'ANCIEN token${OLD_ID:+ (id $OLD_ID)} dans"
echo "  $COOLIFY_URL/security/api-tokens  — c'est celui qui ne s'appelle pas « paperclip-agents-… »."
echo "Le skill pixeeplay-deploy et les scripts lisent désormais $CFG."
