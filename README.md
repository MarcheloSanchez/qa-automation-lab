# QA Automation Lab

Robot Framework ukázkový projekt pro testování přihlášení přes API.

## Struktura

- `tests/smoke/login.robot` – smoke testy přihlašovacího API.
- `tests/smoke/login_security.robot` – testy cílené na známé chyby verze `sprint5-with-bugs` (tag `bug:<id>`).
- `tests/smoke/authorization.robot` – autorizační testy (OWASP API) cílené na známé chyby (tag `bug:<id>`).
- `tests/smoke/data_exposure.robot` – testy úniku dat z API (citlivá pole, logy, odhadnutelná ID).
- `tests/ui/storefront_bugs.robot` – UI testy cílené na známé chyby obchodu (překlepy, odkazy, řazení; tag `bug:<id>`).
- `tests/ui/product_and_account_bugs.robot` – UI testy chyb na detailu produktu, v košíku a v profilu (tag `bug:<id>`).
- `tests/ui/login.robot` – UI testy přihlášení (Browser library) proti `${BASE_URL}`; v CI proti lokální aplikaci (port 4200).
- `resources/pages/` – page objecty (`login.resource`, `product.resource`) a sdílené keywords prohlížeče (`common.resource`).
- `tests/helpers/pst_api_library.robot` – offline testy knihovny `PstApi.py` proti mock API.
- `resources/api/PstApi.py` – Python keyword knihovna pro API (jedna HTTP session, bearer tokeny).
- `resources/api/login_api.resource` – sdílené keywords pro login nad `PstApi.py`.
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

V CI to dělá workflow `Bug Check` (ručně, jednou týdně a u PR, které mění testy).

UI testy (vyžadují `rfbrowser init` a běžící UI):

```bash
WAIT_FOR_UI=true scripts/start_app.sh
robot -d output --variable BASE_URL:http://localhost:4200 --variable API_BASE_URL:http://localhost:8091 tests/ui
```

## Lint

```bash
ruff check .
```
