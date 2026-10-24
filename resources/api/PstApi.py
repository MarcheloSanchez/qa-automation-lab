"""Robot Framework keyword library for the Practice Software Testing API.

Replaces the one-subprocess-per-request helper: keeps a single HTTP session,
supports bearer tokens, and returns plain dicts Robot can assert on.
"""

from __future__ import annotations

import base64
import json as jsonlib
from typing import Any

import requests
from robot.api.deco import keyword, library

TOKEN_KEYS = ("access_token", "token", "jwt")


@library(scope="SUITE")
class PstApi:
    def __init__(self, base_url: str, timeout: float = 10) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout
        self.session = requests.Session()
        # The app runs locally in CI; never route it through a proxy.
        self.session.trust_env = False

    @keyword
    def api_is_reachable(self) -> bool:
        try:
            self.session.get(f"{self.base_url}/status", timeout=self.timeout).raise_for_status()
        except requests.RequestException:
            return False
        return True

    @keyword
    def api_request(
        self,
        method: str,
        path: str,
        token: str | None = None,
        json: Any = None,
    ) -> dict[str, Any]:
        headers = {"Accept": "application/json"}
        if token:
            headers["Authorization"] = f"Bearer {token}"
        response = self.session.request(
            method.upper(),
            f"{self.base_url}/{path.lstrip('/')}",
            headers=headers,
            json=json,
            timeout=self.timeout,
        )
        try:
            body = response.json()
        except ValueError:
            body = None
        return {
            "status_code": response.status_code,
            "json": body,
            "headers": dict(response.headers),
        }

    @keyword
    def login_request(self, email: str, password: str) -> dict[str, Any]:
        response = self.api_request(
            "POST", "/users/login", json={"email": email, "password": password}
        )
        body = response["json"] if isinstance(response["json"], dict) else {}
        token = next((body[key] for key in TOKEN_KEYS if body.get(key)), "")
        return {"status_code": response["status_code"], "token": token}

    @keyword
    def get_token(self, email: str, password: str) -> str:
        result = self.login_request(email, password)
        if result["status_code"] != 200 or not result["token"]:
            raise AssertionError(f"Login as {email} failed with HTTP {result['status_code']}.")
        return result["token"]

    @keyword
    def decode_jwt_claims(self, token: str) -> dict[str, Any]:
        """Return the JWT payload without verifying the signature (inspection only)."""
        try:
            payload = token.split(".")[1]
            payload += "=" * (-len(payload) % 4)
            return jsonlib.loads(base64.urlsafe_b64decode(payload))
        except (IndexError, ValueError) as error:
            raise AssertionError(f"Not a JWT: {token[:20]}...") from error
