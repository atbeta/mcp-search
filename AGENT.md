# mcp-search — Agent usage policy

Single entry for agents: **`mcp-search`** → `http://<host>:8812/mcp`

This distribution exposes raw backend tools (no routing facade). Prefer tools in this order unless the user asks otherwise.

## Default picks

| Intent | Prefer | Avoid |
|--------|--------|-------|
| General web facts / discovery | `searxng_search` | Paying APIs first |
| Higher-quality snippets / extract | `tavily_search` / `tavily_extract` | Same query on 3 engines |
| Hard scrape / multi-page | `firecrawl_search` or `firecrawl_scrape` first | Firecrawl monitor/agent tools unless needed |
| Brave-indexed web / news | `brave_web_search` (etc.) | Duplicating SearXNG+Brave same query |
| Library docs | Context7 (`resolve-library-id` → `query-docs`) | Blind web scrape of docs |
| Public GitHub architecture Q&A | DeepWiki tools | |
| Papers | ArXiv tools | |

## Rules

1. **≤2 search tool calls per turn** unless the user asked for deep research.
2. Do not chain SearXNG + Tavily + Brave + Firecrawl for the same query.
3. Firecrawl has many tools — start with search/scrape; skip monitor/agent long-tail by default.
4. On cloud hosts, assume the gateway is loopback-bound; reach it via SSH tunnel or a reverse proxy with auth — do not publish `:8812` to the open internet unauthenticated.

## Brave Answers

Brave sells **Search** and **Answers** as separate API products/keys.
The official `mcp/brave-search` image today exposes Search-family tools (`brave_web_search`, `brave_summarizer`, `brave_llm_context`, …).
A dedicated `brave_answers` tool is tracked upstream (PR #315) and is **not** something we implement ourselves yet — leave `BRAVE_ANSWERS_API_KEY` as a placeholder until the released image documents it.
