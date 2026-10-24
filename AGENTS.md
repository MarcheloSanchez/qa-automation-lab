# Agent instructions

Robot Framework lab testing [Practice Software Testing](https://github.com/testsmith-io/practice-software-testing)
(PST). The app itself is a git submodule in `app/practice-software-testing`; this repo only holds tests.

## Layout

- `tests/smoke/` – suites against a real PST instance (tag `smoke`). Base URLs come from
  `resources/variables/env.resource` and are overridden with `--variable`.
- `tests/helpers/` – Python helper scripts plus `login_api_helper.robot`, which tests them against
  `mock_login_api_server.py` on `127.0.0.1:8899`. Fully offline.
- `resources/pages/` – page-object keywords (Browser library). `resources/variables/` – shared variables.

## Commands

```bash
pip install -r requirements.txt     # done automatically by the SessionStart hook in cloud sessions
ruff check .                        # lint
robot -d output tests/helpers       # offline helper suite - always runnable
robot -d output -i smoke --variable API_BASE_URL:http://localhost:8091 tests   # needs the app running
```

UI tests also need `rfbrowser init` (downloads Node deps and browsers; slow, run only when needed).

## Running the app locally

```bash
git submodule update --init --depth 1
cd app/practice-software-testing
chmod -R 777 sprint5/API/storage sprint5/API/bootstrap/cache   # www-data UID mismatch on bind mounts
docker compose up -d
docker compose stop cron                                       # scheduler noise, races migrations
docker compose exec -T laravel-api php artisan migrate:fresh --seed   # compose never seeds; retry until DB is up
```

Ports: UI `http://localhost:4200`, API `http://localhost:8091` (health route `/status`; `/` returns 404).
Seeded customer: `customer@practicesoftwaretesting.com` / `welcome01`.

## Conventions

- Robot: separate keyword arguments with **at least two spaces** (one space silently merges them into
  one argument). Four-space indentation, `Title Case` keyword and test names.
- Every test gets tags: suite type (`smoke`, `ui`) plus area (`login`, `cart`, ...).
- Shared keywords go in `resources/`, not copied between suites.
- Compare status codes as numbers (`${401}`), not strings.
- Python: must pass `ruff check .`; type-hint new functions.

## Definition of done

1. `ruff check .` and `robot tests/helpers` pass locally.
2. A **skipped** smoke test is not a pass. If the API was unreachable, say the change is unverified
   against the real app instead of reporting success.
3. README (Czech) updated if you add a suite or change how tests are run.

## Workflow

- One roadmap item per branch and PR; keep PRs small. Never push to `main`.
- CI: `checks.yml` (lint + helper suite, offline) and `pr-smoke.yml` (smoke suite against the
  Docker app). Both must be green before merge.
- Before touching `pr-smoke.yml`, check open PRs and `claude/*` / `codex/*` branches - CI fixes
  have been attempted in parallel before.
