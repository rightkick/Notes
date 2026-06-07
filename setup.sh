#!/usr/bin/env bash
# setup.sh — First-time Forgejo homelab setup
set -euo pipefail

echo "==> Copying .env.example to .env (if not already present)"
if [ ! -f .env ]; then
  cp .env.example .env
  echo "    ✔ .env created — edit it before continuing!"
  echo ""
  echo "    Required: set POSTGRES_PASSWORD and FORGEJO_DOMAIN"
  exit 0
else
  echo "    .env already exists, skipping."
fi

echo "==> Preparing runner data directory (needs uid 1001)"
mkdir -p runner-data/.cache
chown -R 1001:1001 runner-data
chmod 775 runner-data/.cache
chmod g+s runner-data/.cache
echo "    ✔ runner-data permissions set"

echo ""
echo "==> All done. Start the stack with:"
echo "    docker compose up -d"
echo ""
echo "    Then open http://localhost:3000 (or your FORGEJO_ROOT_URL)"
echo "    Complete the web installer, then:"
echo "      1. Admin → Actions → Runners → Create new runner"
echo "      2. Copy the token into .env as RUNNER_TOKEN"
echo "      3. docker compose restart runner"