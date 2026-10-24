# QA Automation Lab

Robot Framework ukázkový projekt pro testování přihlášení přes API.

## Struktura

- `tests/smoke/login.robot` – smoke testy přihlašovacího API.
- `tests/smoke/login_security.robot` – testy cílené na známé chyby verze `sprint5-with-bugs` (tag `bug:<id>`).
- `resources/api/login_api.resource` – sdílené keywords pro volání login API.
- `scripts/start_app.sh` – spustí aplikaci ze submodulu a naplní databázi (`SPRINT=sprint5-with-bugs` pro verzi s chybami).
- `scripts/bug_scorecard.py` – z `output.xml` vyhodnotí, které známé chyby testy odhalily.
- `tests/helpers/login_api_helper.robot` – stabilní lokální Robot testy helper skriptu `pst_login_api_check.py`.
- `tests/helpers/pst_login_api_check.py` – pomocný Python skript volaný z Robot testů pro reachability check a login request.

## Instalace

```bash
pip install -r requirements.txt
```

## Spuštění testů

Všechny Robot testy:

```bash
robot tests
```

Pouze smoke sada:

```bash
robot -i smoke tests
```

Smoke sada proti lokální instanci aplikace (viz `AGENTS.md`, sekce *Running the app locally*).
`REQUIRE_API:true` způsobí, že nedostupné API test shodí místo přeskočení (takto běží CI):

```bash
robot -i smoke --variable API_BASE_URL:http://localhost:8091 --variable REQUIRE_API:true tests
```

Helper sada (lokální mock API):

```bash
robot tests/helpers/login_api_helper.robot
```

Kolik známých chyb testy odhalí (proti verzi s chybami):

```bash
SPRINT=sprint5-with-bugs scripts/start_app.sh
robot -d output -i smoke --nostatusrc --variable API_BASE_URL:http://localhost:8091 --variable REQUIRE_API:true tests
python scripts/bug_scorecard.py output/output.xml app/practice-software-testing/sprint5-with-bugs/testSessions/listOfBugs.md
```

V CI to dělá workflow `Bug Check` (ručně a jednou týdně).

## Lint

```bash
ruff check .
```
