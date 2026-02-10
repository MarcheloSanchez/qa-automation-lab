from __future__ import annotations

import argparse
import json
from typing import Any

import requests


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--mode", choices=["reachability", "login"], required=True)
    parser.add_argument("--email")
    parser.add_argument("--password")
    return parser.parse_args()


def build_session() -> requests.Session:
    session = requests.Session()
    session.trust_env = False
    return session


def check_reachability(session: requests.Session, base_url: str) -> int:
    try:
        session.get(base_url, timeout=10).raise_for_status()
        return 0
    except requests.RequestException:
        return 1


def execute_login(session: requests.Session, base_url: str, email: str, password: str) -> dict[str, Any]:
    response = session.post(
        f"{base_url}/users/login",
        json={"email": email, "password": password},
        timeout=10,
    )
    try:
        body = response.json()
    except ValueError:
        body = {}

    token = body.get("access_token") or body.get("token") or body.get("jwt") or ""
    return {"status_code": response.status_code, "token": token}


def main() -> int:
    args = parse_args()
    session = build_session()

    if args.mode == "reachability":
        return check_reachability(session, args.base_url)

    if not args.email or not args.password:
        raise SystemExit("--email and --password are required for login mode")

    result = execute_login(session, args.base_url, args.email, args.password)
    print(json.dumps(result))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
