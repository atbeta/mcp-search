#!/usr/bin/env bash
# Smoke-check mcp-search gateway (tools/list + searxng_search).
set -euo pipefail
HOST="${MCP_SEARCH_HOST:-127.0.0.1}"
PORT="${MCP_SEARCH_PORT:-8812}"
export MCP_SEARCH_URL="${MCP_SEARCH_URL:-http://${HOST}:${PORT}/mcp}"

python3 <<'PY'
import json, os, sys, urllib.request

url = os.environ["MCP_SEARCH_URL"]

def post(payload, sid=None):
    h = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    }
    if sid:
        h["Mcp-Session-Id"] = sid
    req = urllib.request.Request(
        url, data=json.dumps(payload).encode(), headers=h, method="POST"
    )
    with urllib.request.urlopen(req, timeout=90) as r:
        return r.read().decode(), r.headers.get("Mcp-Session-Id")

raw, sid = post(
    {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2024-11-05",
            "capabilities": {},
            "clientInfo": {"name": "mcp-search-doctor", "version": "0"},
        },
    }
)
post({"jsonrpc": "2.0", "method": "notifications/initialized"}, sid)
raw, _ = post({"jsonrpc": "2.0", "id": 2, "method": "tools/list"}, sid)
names = []
for line in raw.splitlines():
    if line.startswith("data: "):
        try:
            names = [
                t["name"]
                for t in json.loads(line[6:]).get("result", {}).get("tools", [])
            ]
        except Exception:
            pass
print(f"url: {url}")
print(f"tools: {len(names)}")
for n in sorted(names)[:30]:
    print(" ", n)
if len(names) > 30:
    print(f"  ... +{len(names) - 30}")
if "searxng_search" not in names:
    print("FAIL: searxng_search missing", file=sys.stderr)
    sys.exit(1)
raw, _ = post(
    {
        "jsonrpc": "2.0",
        "id": 3,
        "method": "tools/call",
        "params": {
            "name": "searxng_search",
            "arguments": {"query": "open source", "page": 1},
        },
    },
    sid,
)
ok = False
for line in raw.splitlines():
    if line.startswith("data: "):
        j = json.loads(line[6:])
        if j.get("result"):
            ok = True
            print("searxng_search:", json.dumps(j["result"], ensure_ascii=False)[:240])
print("OK" if ok else "WARN: searxng call returned no result")
sys.exit(0 if ok else 2)
PY
