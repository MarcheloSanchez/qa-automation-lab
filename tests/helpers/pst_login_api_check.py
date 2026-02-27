from __future__ import annotations

import argparse
import json
import logging
import sys
from typing import Any

import requests

logging.basicConfig(
    level=logging.DEBUG,
    format="%(levelname)s: %(message)s",
    stream=sys.stderr,
)
logger = logging.getLogger(__name__)


def parse_args() -> argparse.Namespace:
    """Parse command-line arguments for mode and connection details."""
    parser = argparse.ArgumentParser(
        description="Practice Software Testing login API helper."
    )
    parser.add_argument("--base-url", required=True, help="Base URL of the API server.")
    parser.add_argument(
        "--mode",
        choices=["reachability", "login"],
        required=True,
        help="Operation mode: 'reachability' checks the health endpoint, 'login' performs authentication.",
    )
    parser.add_argument("--email", help="User email address (required for login mode).")
    parser.add_argument("--password", help="User password (required for login mode).")
    return parser.parse_args()


def build_session() -> requests.Session:
    """Create a requests Session with proxy environment variables disabled."""
    session = requests.Session()
    session.trust_env = False
    return session


def check_reachability(session: requests.Session, base_url: str) -> int:
    """Check whether the API health endpoint is reachable.

    Returns 0 on success, 1 on any connection or HTTP error.
    """
    logger.debug("Checking reachability: %s", base_url)
    try:
        session.get(base_url, timeout=10).raise_for_status()
        logger.debug("Reachability check passed.")
        return 0
    except requests.RequestException as exc:
        logger.warning("Reachability check failed: %s", exc)
        return 1


def execute_login(
    session: requests.Session, base_url: str, email: str, password: str
) -> dict[str, Any]:
    """Send a login POST request and return the status code and extracted token.

    Supports API responses that use any of the following token field names:
    ``access_token``, ``token``, or ``jwt``.

    Returns a dict with keys ``status_code`` (int) and ``token`` (str).
    """
    url = f"{base_url}/users/login"
    logger.debug("Posting login request to %s (email=%s)", url, email)
    response = session.post(
        url,
        json={"email": email, "password": password},
        timeout=10,
    )
    logger.debug("Response status: %d", response.status_code)

    try:
        body = response.json()
    except ValueError:
        logger.warning("Response body is not valid JSON; treating token as empty.")
        body = {}

    token = body.get("access_token") or body.get("token") or body.get("jwt") or ""
    return {"status_code": response.status_code, "token": token}


def main() -> int:
    """Entry point: parse args, run the requested mode, and emit output."""
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
