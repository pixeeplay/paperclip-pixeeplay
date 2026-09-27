#!/usr/bin/env bash
# Installation de Paperclip HORS Coolify (plan B), directement sur le VPS.
# Usage (en root sur le VPS) :
#   curl -fsSL https://raw.githubusercontent.com/pixeeplay/paperclip-pixeeplay/main/deploy/install-vps.sh | bash -s -- https://paperclip.pixeeplay.com
#
# Le script :
#   1. crée /opt/paperclip avec un docker-compose autonome (Postgres 17 + Paperclip)
#   2. génère les secrets dans /opt/paperclip/.env
#   3. démarre la stack, attend /api/health
#   4. imprime le lien d'invitation admin (bootstrap-ceo)
# Le reverse-proxy TLS reste à ta charge (Traefik de Coolify, Caddy ou Nginx) :
# le service écoute sur 127.0.0.1:3100.
set -euo pipefail

PUBLIC_URL="${1:-}"
if [[ -z "$PUBLIC_URL" ]]; then
  echo "Usage: install-vps.sh https://paperclip.example.com" >&2
  exit 1
fi

command -v docker >/dev/null || { echo "docker manquant" >&2; exit 1; }
docker compose version >/dev/null 2>&1 || { echo "docker compose (plugin v2) manquant" >&2; exit 1; }

DIR=/opt/paperclip
mkdir -p "$DIR"
cd "$DIR"

if [[ ! -f .env ]]; then
  cat > .env <<EOF
PAPERCLIP_PUBLIC_URL=${PUBLIC_URL}
POSTGRES_PASSWORD=$(openssl rand -hex 24)
BETTER_AUTH_SECRET=$(openssl rand -hex 32)
PAPERCLIP_TOOL_ACTION_SIGNING_SECRET=$(openssl rand -hex 32)
PAPERCLIP_AUTH_DISABLE_SIGN_UP=false
CLAUDE_CODE_OAUTH_TOKEN=
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GH_TOKEN=
EOF
  chmod 600 .env
  echo "→ .env généré dans $DIR/.env (complète CLAUDE_CODE_OAUTH_TOKEN / GH_TOKEN ensuite)"
fi

cat > docker-compose.yml <<'EOF'
services:
  paperclip:
    image: ghcr.io/paperclipai/paperclip:latest
    restart: unless-stopped
    pids_limit: 2048
    ports:
      - "127.0.0.1:3100:3100"
    env_file: .env
    environment:
      - HOST=0.0.0.0
      - PORT=3100
      - SERVE_UI=true
      - PAPERCLIP_HOME=/paperclip
      - PAPERCLIP_INSTANCE_ID=pixeeplay
      - TZ=Europe/Paris
      - DATABASE_URL=postgres://paperclip:${POSTGRES_PASSWORD}@db:5432/paperclip
      - PAPERCLIP_DEPLOYMENT_MODE=authenticated
      - PAPERCLIP_DEPLOYMENT_EXPOSURE=public
      - PAPERCLIP_AUTH_BASE_URL_MODE=explicit
      - PAPERCLIP_TELEMETRY_DISABLED=1
      - PAPERCLIP_DB_BACKUP_ENABLED=true
    volumes:
      - paperclip-data:/paperclip
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://127.0.0.1:3100/api/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 90s
  db:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=paperclip
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=paperclip
    volumes:
      - paperclip-pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U paperclip -d paperclip"]
      interval: 5s
      timeout: 5s
      retries: 30
volumes:
  paperclip-data:
  paperclip-pgdata:
EOF

echo "→ Téléchargement de l'image et démarrage…"
docker compose pull
docker compose up -d

echo -n "→ Attente de /api/health "
for i in $(seq 1 60); do
  if curl -fsS http://127.0.0.1:3100/api/health >/dev/null 2>&1; then echo " OK"; break; fi
  echo -n "."; sleep 3
  if [[ $i -eq 60 ]]; then echo; echo "Paperclip ne répond pas — docker compose logs paperclip" >&2; exit 1; fi
done

echo
echo "→ Invitation du premier administrateur :"
docker compose exec -T paperclip pnpm paperclipai auth bootstrap-ceo --base-url "$PUBLIC_URL" || true
echo
echo "1) Publie ${PUBLIC_URL} → 127.0.0.1:3100 dans ton reverse-proxy (TLS)."
echo "2) Ouvre ${PUBLIC_URL}, crée ton compte, puis ouvre le lien d'invitation ci-dessus."
echo "3) Mets PAPERCLIP_AUTH_DISABLE_SIGN_UP=true dans .env et: docker compose up -d"
