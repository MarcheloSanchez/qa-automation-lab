from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class LoginApiHandler(BaseHTTPRequestHandler):
    def _send_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802
        if self.path == "/health":
            self._send_json(200, {"status": "ok"})
            return
        self._send_json(404, {"error": "not found"})

    def do_POST(self) -> None:  # noqa: N802
        if self.path != "/users/login":
            self._send_json(404, {"error": "not found"})
            return

        content_length = int(self.headers.get("Content-Length", "0"))
        request_body = self.rfile.read(content_length).decode("utf-8")
        try:
            payload = json.loads(request_body or "{}")
        except json.JSONDecodeError:
            self._send_json(400, {"error": "invalid JSON"})
            return

        email = payload.get("email")
        password = payload.get("password")

        if not email or not password:
            self._send_json(422, {"error": "email and password are required"})
            return

        if email == "customer@practicesoftwaretesting.com" and password == "welcome01":
            self._send_json(200, {"access_token": "access-token-value"})
            return
        if email == "token@test.com" and password == "welcome01":
            self._send_json(200, {"token": "token-value"})
            return
        if email == "jwt@test.com" and password == "welcome01":
            self._send_json(200, {"jwt": "jwt-value"})
            return

        self._send_json(401, {"error": "invalid credentials"})

    def log_message(self, format: str, *args) -> None:  # noqa: A003
        return


def main() -> None:
    server = ThreadingHTTPServer(("127.0.0.1", 8899), LoginApiHandler)
    server.serve_forever()


if __name__ == "__main__":
    main()
