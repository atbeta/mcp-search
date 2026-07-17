# mcp-search — Agent usage policy

Single entry for agents: **`mcp-search`** → `http://<host>:8812/mcp`

This distribution exposes raw backend tools (no routing facade). Prefer tools in this order unless the user asks otherwise.

## Default picks

| Intent | Prefer | Avoid |
|--------|--------|-------|
| General web facts / discovery | `brave_web_search` → `brave_llm_context`，或 `tavily_search` / `web_search_exa` | 一上来就 SearXNG |
| Higher-quality snippets / extract | `tavily_search` / `tavily_extract` / `web_fetch_exa` | Same query on 3 engines |
| Hard scrape / multi-page | `firecrawl_search` or `firecrawl_scrape` first | Firecrawl monitor/agent long-tail |
| Quota exhausted / offline fallback | `searxng_search` | 把 SearXNG 当默认首选 |
| Library docs | Context7 (`resolve-library-id` → `query-docs`) | Blind web scrape of docs |
| Public GitHub architecture Q&A | DeepWiki tools | |
| Papers | ArXiv tools | |
| npm 包 / 读公开 URL | `npm_search_packages` / `fetch_url_markdown` | |

## Rules

1. **≤2 search tool calls per turn** unless the user asked for deep research.
2. Prefer Brave/Tavily/Exa; use `searxng_search` only as **fallback** when paid/API backends are unavailable or exhausted (upstream blocks are common on self-hosted meta-search).
3. Do not chain SearXNG + Tavily + Brave + Exa + Firecrawl for the same query.
4. Firecrawl has many tools — start with search/scrape; skip monitor/agent long-tail by default.
5. On cloud hosts, assume the gateway is loopback-bound; reach it via SSH tunnel or a reverse proxy with auth — do not publish `:8812` to the open internet unauthenticated.

## Brave Answers

Brave sells **Search** and **Answers** as separate API products/keys.
The official `mcp/brave-search` image today exposes Search-family tools (`brave_web_search`, `brave_summarizer`, `brave_llm_context`, …).
A dedicated `brave_answers` tool is tracked upstream (PR #315) and is **not** something we implement ourselves yet — leave `BRAVE_ANSWERS_API_KEY` as a placeholder until the released image documents it.
