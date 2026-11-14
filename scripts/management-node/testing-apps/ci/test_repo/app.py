"""Small web server used to test CI pipelines, registries and deployments.

Endpoints:
  GET /health  -> {"status": "ok"}, shows that the server is running
  GET /status  -> {"status": "ok", "pod": "<name>"}, the health plus which pod
                  answered

The name is the hostname, which is the pod name in Kubernetes and the container id
in Docker.
"""
import json
import os
import socket
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PORT = int(os.environ.get("PORT", "8080"))


def pod_name() -> str:
    return socket.gethostname()


class Handler(BaseHTTPRequestHandler):
    def _send(self, code: int, body: dict) -> None:
        payload = json.dumps(body).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:
        if self.path == "/health":
            self._send(200, {"status": "ok"})
        elif self.path == "/status":
            self._send(200, {"status": "ok", "pod": pod_name()})
        else:
            self._send(404, {"error": "not found"})


if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Listening on port {PORT}", flush=True)
    server.serve_forever()
