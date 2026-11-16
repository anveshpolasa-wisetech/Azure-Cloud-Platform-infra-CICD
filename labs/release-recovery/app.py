import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/health":
            self.respond(200, "ok")
        elif path == "/ready":
            ready = os.environ.get("LAB_READY", "true") == "true"
            self.respond(200 if ready else 503, "ready" if ready else "unavailable")
        else:
            self.respond(404, "not found")

    def respond(self, code, status):
        body = json.dumps({"status": status}).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    host = os.environ.get("LAB_HOST", "0.0.0.0")
    port = int(os.environ.get("LAB_PORT", "8080"))
    with ThreadingHTTPServer((host, port), Handler) as server:
        server.serve_forever()
