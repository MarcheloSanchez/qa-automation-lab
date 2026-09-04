# QA Automation Lab

Robot Framework ukázkový projekt pro testování přihlášení přes API.

## Struktura

- `tests/smoke/login.robot` – smoke testy proti veřejnému Practice Software Testing API.
- `tests/smoke/login_ui.robot` – UI smoke testy přihlašovací stránky (Browser library) proti `${BASE_URL}`, běží v CI proti lokální instanci aplikace ze submodulu.
- `tests/helpers/login_api_helper.robot` – stabilní lokální Robot testy helper skriptu `pst_login_api_check.py`.
- `tests/helpers/pst_login_api_check.py` – pomocný Python skript volaný z Robot testů pro reachability check a login request.
- `resources/pages/login.resource` – page object s keywords pro přihlašovací stránku, používaný `login_ui.robot`.
- `resources/pages/common.resource` – sdílené keywords pro spuštění a ukončení prohlížeče (Browser library).

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

Helper sada (lokální mock API):

```bash
robot tests/helpers/login_api_helper.robot
```

## Lint

```bash
ruff check .
```
