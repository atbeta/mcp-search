# mcp-search

**Portable Docker MCP Gateway distribution for agent search/research.**

One entry for any agent (Cursor, OpenClaw, Codex, cloud VPS):

```text
mcp-search → http://<host>:8812/mcp
```

No routing facade — backends are exposed as their native MCP tools. Usage policy lives in [`AGENT.md`](./AGENT.md).

## What you get

| Layer | Role |
|-------|------|
| `docker/mcp-gateway` | Single streamable-HTTP entry on `:8812` |
| SearXNG + `xbeta/mcp-search` | **Always on**, no API key |
| Optional Hub MCP images | Tavily / Firecrawl **cloud** / Brave / ArXiv |
| Optional remotes | Context7, DeepWiki |

Firecrawl is **cloud API only** (`mcp/firecrawl` + `FIRECRAWL_API_KEY`). This stack does **not** self-host Firecrawl.

## Quick start

```bash
git clone git@github.com:atbeta/mcp-search.git
cd mcp-search
cp .env.example .env
# edit SEARXNG_SECRET at minimum

docker compose up -d --build
./scripts/doctor.sh
```

Point the agent client at the gateway:

```json
{
  "mcpServers": {
    "mcp-search": {
      "type": "http",
      "url": "http://127.0.0.1:8812/mcp"
    }
  }
}
```

Default bind is **`127.0.0.1:8812`** (cloud-safe). For LAN lab only, set `MCP_SEARCH_BIND=0.0.0.0` in `.env`.

## Profiles via `MCP_SEARCH_SERVERS`

```bash
# Core (default) — SearXNG only
MCP_SEARCH_SERVERS=searxng-mcp-local

# Full — add keys to .env first
MCP_SEARCH_SERVERS=searxng-mcp-local,tavily,firecrawl,brave,context7-docs,deepwiki,arxiv-mcp-server
```

Then `docker compose up -d` (recreate `mcp-search` if already running).

| Catalog name | Needs |
|--------------|--------|
| `searxng-mcp-local` | nothing |
| `tavily` | `TAVILY_API_KEY` (+ `tavily.api_key=` same value) |
| `firecrawl` | `FIRECRAWL_API_KEY` (+ `firecrawl.api_key=`) |
| `brave` | `BRAVE_API_KEY` (+ `brave.api_key=`) |
| `context7-docs` | `CONTEXT7_API_KEY` |
| `deepwiki` | none |
| `arxiv-mcp-server` | docker volume `arxiv-papers` (compose defines it) |

Gateway secrets file is the same `.env` (dotted aliases included for Docker MCP Toolkit).

## Build / push image (Docker Hub)

Develop on your laptop (OrbStack/Docker Desktop). **Do not build on the server** — push Hub, then pull on VPS/lab hosts.

The only custom image is the thin SearXNG MCP adapter (`linux/amd64`):

```bash
# on Mac (docker login as xbeta)
./scripts/push.sh           # buildx --platform linux/amd64 --push

# on 101 / cloud
docker pull xbeta/mcp-search:latest
docker compose up -d --no-build
```

CI: see `.github/workflows/image.yml`.

## Layout

```text
catalog.yaml          Gateway additional catalog
docker-compose.yml    valkey + searxng + searxng-mcp + mcp-search
searxng/              SearXNG settings (JSON enabled)
searxng-mcp/          FastMCP HTTP adapter (Dockerfile)
AGENT.md              Tool-selection policy for agents
scripts/doctor.sh     Smoke tools/list + searxng_search
```

## Security notes

- `--allow-unauthenticated` is on for easy agent wiring. **Do not** expose `:8812` to the public internet without a reverse proxy + auth (or SSH tunnel).
- Prefer loopback bind on VPS; tunnel from your laptop / agent host.

## License

MIT
