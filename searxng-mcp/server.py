"""SearXNG → MCP (streamable HTTP). Part of the mcp-search distribution."""

import os
from typing import Any, Optional

import requests
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("searxng-mcp")
SEARXNG_URL = os.getenv("SEARXNG_URL", "http://searxng:8080").rstrip("/")


def _search(params: dict[str, Any]) -> dict[str, Any]:
    resp = requests.get(f"{SEARXNG_URL}/search", params=params, timeout=12)
    resp.raise_for_status()
    return resp.json()


@mcp.tool()
def searxng_search(
    query: str,
    categories: Optional[str] = None,
    language: Optional[str] = None,
    page: int = 1,
    time_range: Optional[str] = None,
) -> dict[str, Any]:
    """Search with SearXNG and return top results.

    categories examples: "general", "news", "science"
    time_range examples: "day", "month", "year"
    """
    params: dict[str, Any] = {
        "q": query,
        "format": "json",
        "pageno": max(page, 1),
    }
    if categories:
        params["categories"] = categories
    if language:
        params["language"] = language
    if time_range:
        params["time_range"] = time_range

    data = _search(params)
    results = data.get("results", [])[:10]

    normalized = [
        {
            "title": item.get("title"),
            "url": item.get("url"),
            "content": item.get("content"),
            "engine": item.get("engine"),
            "publishedDate": item.get("publishedDate"),
            "score": item.get("score"),
        }
        for item in results
    ]

    return {
        "query": query,
        "count": len(normalized),
        "results": normalized,
        "suggestions": data.get("suggestions", []),
        "infoboxes": data.get("infoboxes", []),
    }


if __name__ == "__main__":
    mcp.settings.host = "0.0.0.0"
    mcp.settings.port = int(os.environ.get("MCP_PORT", "8001"))
    mcp.run(transport="streamable-http")
