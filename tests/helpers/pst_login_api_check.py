from __future__ import annotations

import argparse
import json

import requests


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-url", required=True)
    parser.add_argument("--mode", choices=["reachability", "login"], required=True)
    parser.add_argument("--email")
    parser.add_argument("--password")
    args = parser.parse_args()

    session = requests.Session()
    session.trust_env = False

    if args.mode == "reachability":
        try:
            session.get(args.base_url, timeout=10).raise_for_status()
            return 0
        except requests.RequestException:
            return 1

    response = session.post(
        f"{args.base_url}/users/login",
        json={"email": args.email, "password": args.password},
        timeout=10,
    )
    try:
        body = response.json()
    except ValueError:
        body = {}

    token = body.get("access_token") or body.get("token") or body.get("jwt") or ""
    print(json.dumps({"status_code": response.status_code, "token": token}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
