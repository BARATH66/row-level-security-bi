"""Local demo helper for the embedded Superset page.

Serves index.html and mints Superset *guest tokens*. It exists because the guest-token API needs a service
login, and that password must never sit in a web page. The row-level-security clause is decided HERE from the
mapping file, so the browser cannot ask for more access than the selected user has.

    SUPERSET_URL=http://localhost:8088 SVC_USER=... SVC_PASSWORD=... python serve.py
    (or:  python serve.py --env-file path/to/service.env)

Open http://localhost:4173  (the port must be an origin your Superset allows to frame dashboards).
"""
import csv, json, os, sys, threading, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse, parse_qs
import requests

HERE = os.path.dirname(os.path.abspath(__file__))
PORT = int(os.environ.get("PORT", "4173"))
if "--env-file" in sys.argv:
    for line in open(sys.argv[sys.argv.index("--env-file") + 1], encoding="utf-8"):
        if "=" in line and not line.startswith("#"):
            k, v = line.strip().split("=", 1)
            os.environ.setdefault(k, v)
SUPERSET = os.environ.get("SUPERSET_URL", "http://localhost:8088").rstrip("/")
SVC_USER, SVC_PASSWORD = os.environ.get("SVC_USER"), os.environ.get("SVC_PASSWORD")
MAPPING = os.environ.get("MAPPING_CSV", os.path.join(HERE, "..", "..", "data", "security_user_access.csv"))

DASHBOARDS = json.load(open(os.path.join(HERE, "dashboards.json"), encoding="utf-8"))
BY_SLUG = {d["slug"]: d for d in DASHBOARDS}


def load_users():
    """email -> {name, domains}; the same mapping table the Power BI and Superset roles use."""
    users = {}
    for r in csv.DictReader(open(MAPPING, encoding="utf-8")):
        u = users.setdefault(r["UserEmail"].lower(), {"email": r["UserEmail"], "name": r["DisplayName"], "domains": []})
        u["domains"].append(r["DomainCode"])
    return users


def rls_for(domains):
    if "ALL" in domains:
        return []                                   # manager: no filter
    if not domains:
        return [{"clause": "1 = 0"}]                # unknown user: deny by default
    quoted = ", ".join("'" + d.replace("'", "''") + "'" for d in domains)
    return [{"clause": f"domain_code IN ({quoted})"}]   # applies to every dataset in the dashboard


_lock = threading.Lock()


def guest_token(email, slug):
    users = load_users()
    info = users.get(email.lower(), {"email": email, "name": "Unknown user", "domains": []})
    s = requests.Session()
    r = s.post(f"{SUPERSET}/api/v1/security/login", json={"username": SVC_USER, "password": SVC_PASSWORD, "provider": "db", "refresh": False}, timeout=30)
    r.raise_for_status()
    s.headers["Authorization"] = "Bearer " + r.json()["access_token"]
    s.headers["X-CSRFToken"] = s.get(f"{SUPERSET}/api/v1/security/csrf_token/", timeout=30).json()["result"]
    s.headers["Referer"] = SUPERSET
    body = {"user": {"username": info["email"], "first_name": info["name"], "last_name": ""},
            "resources": [{"type": "dashboard", "id": BY_SLUG[slug]["uuid"]}],
            "rls": rls_for(info["domains"])}
    g = s.post(f"{SUPERSET}/api/v1/security/guest_token/", json=body, timeout=30)
    g.raise_for_status()
    # Superset stamps the token's iat with fractional seconds; PyJWT rejects it if it is checked within the same
    # second. Handing it over a moment later avoids the 'token is not yet valid (iat)' error.
    time.sleep(1.2)
    return g.json()["token"], body["rls"]


class H(BaseHTTPRequestHandler):
    def _send(self, code, payload, ctype="application/json"):
        data = payload if isinstance(payload, bytes) else json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        u = urlparse(self.path)
        q = parse_qs(u.query)
        try:
            if u.path in ("/", "/index.html"):
                return self._send(200, open(os.path.join(HERE, "index.html"), "rb").read(), "text/html; charset=utf-8")
            if u.path == "/api/config":
                users = [{"email": v["email"], "name": v["name"], "domains": v["domains"]} for v in load_users().values()]
                users.append({"email": "unknown.user@example.com", "name": "Unknown user (not in the table)", "domains": []})
                return self._send(200, {"supersetUrl": SUPERSET, "dashboards": DASHBOARDS, "users": users})
            if u.path == "/api/token":
                email, slug = q.get("user", [""])[0], q.get("dashboard", [""])[0]
                if slug not in BY_SLUG or not email:
                    return self._send(400, {"error": "unknown dashboard or missing user"})
                token, rls = guest_token(email, slug)
                return self._send(200, {"token": token, "rls": rls})
            return self._send(404, {"error": "not found"})
        except Exception as e:  # keep the demo readable
            return self._send(500, {"error": str(e)[:300]})

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    if not (SVC_USER and SVC_PASSWORD):
        sys.exit("Set SVC_USER and SVC_PASSWORD (or pass --env-file).")
    print(f"Serving on http://localhost:{PORT}  ->  Superset at {SUPERSET}")
    ThreadingHTTPServer(("127.0.0.1", PORT), H).serve_forever()
