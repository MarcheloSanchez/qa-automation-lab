# QA Automation Lab

Robot Framework ukázkový projekt pro testování přihlášení přes API.

## Struktura

- `tests/smoke/login.robot` – smoke testy proti veřejnému Practice Software Testing API.
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

## Lint

```bash
ruff check .
```
