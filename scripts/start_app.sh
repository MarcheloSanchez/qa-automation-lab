#!/bin/bash
# Starts the Practice Software Testing app from the submodule and seeds it.
# SPRINT selects the app version (default from the submodule's .env: sprint5),
# e.g. SPRINT=sprint5-with-bugs scripts/start_app.sh
# WAIT_FOR_UI=true also waits for the Angular UI on port 4200.
set -euo pipefail

cd "$(dirname "$0")/../app/practice-software-testing"
export SPRINT="${SPRINT:-sprint5}"
echo "Starting app version: $SPRINT"

# api.docker hardcodes 'usermod -u 1000 www-data' so php-fpm's
# user matches a typical local dev machine's own UID on a
# bind-mounted volume. GitHub Actions runners check out the repo
# under a different UID, so www-data can't write to the
# bind-mounted storage/ (logs, cache, sessions) - Laravel then
# fails every request that needs to write there.
chmod -R 777 "$SPRINT/API/storage" "$SPRINT/API/bootstrap/cache"

docker compose up -d

# 'cron' runs the app's scheduler every minute against the same
# database; CI doesn't need it and it can race migrate:fresh.
docker compose stop cron

echo "Waiting for the API to become ready on http://localhost:8091/status ..."
ready=false
for i in $(seq 1 30); do
  if curl -sf http://localhost:8091/status >/dev/null; then
    ready=true
    break
  fi
  # nginx ("web") exits at startup if the phpmyadmin container isn't in
  # Docker's DNS yet ("host not found in upstream"). Start it again.
  if ! docker compose ps --status running --services | grep -qx web; then
    echo "web (nginx) is not running, starting it again ..."
    docker compose up -d web
  fi
  sleep 5
done
if [ "$ready" != true ]; then
  echo "API did not become ready in time." >&2
  docker compose logs
  exit 1
fi

# docker compose up alone never creates the schema or seeds any
# users - the project's own docs require this as a separate step
# (see README.md 'Roll Back - Run Migrations - Seed Database').
# Retry: mariadb may still be starting after the API answers.
echo "Running migrations and seeding the database..."
migrated=false
for i in $(seq 1 30); do
  if docker compose exec -T laravel-api php artisan migrate:fresh --seed; then
    migrated=true
    break
  fi
  sleep 5
done
if [ "$migrated" != true ]; then
  echo "Migration/seed did not succeed in time." >&2
  docker compose logs
  exit 1
fi

# The UI (ng serve) builds long after the API is up. Requesting the login route
# also warms it up, so the first UI test isn't spent on lazy compilation.
if [ "${WAIT_FOR_UI:-false}" = true ]; then
  echo "Waiting for the UI on http://localhost:4200/auth/login ..."
  ui_ready=false
  for i in $(seq 1 60); do
    if curl -sf http://localhost:4200/auth/login >/dev/null; then
      ui_ready=true
      break
    fi
    sleep 5
  done
  if [ "$ui_ready" != true ]; then
    echo "UI did not become ready in time." >&2
    docker compose logs angular-ui
    exit 1
  fi

  # UI tests need data from the API, not just /status. Seen in CI: a 500
  # with a 5-byte body shortly after startup; allow a warm-up, then show
  # the body and Laravel's own log if it persists.
  api_ok=false
  for i in $(seq 1 12); do
    code=$(curl -s -o /tmp/products.json -w '%{http_code}' -H 'Accept: application/json' http://localhost:8091/products)
    echo "API /products: HTTP $code (attempt $i)"
    if [ "$code" = 200 ]; then
      api_ok=true
      break
    fi
    sleep 5
  done
  if [ "$api_ok" != true ]; then
    echo "--- last /products body:"; head -c 2000 /tmp/products.json; echo
    echo "--- laravel.log (tail):"
    docker compose exec -T laravel-api sh -c 'tail -n 60 storage/logs/laravel.log; ls -la storage/logs' || true
    docker compose ps
    docker compose logs --tail=80 laravel-api web
    exit 1
  fi
fi
