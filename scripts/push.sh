#!/usr/bin/env bash
# Build + push searxng-mcp image to Docker Hub.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${SEARXNG_MCP_IMAGE:-xbeta/mcp-search-searxng:latest}"
PLATFORM="${PLATFORM:-linux/amd64}"

cd "$ROOT"
"$ROOT/scripts/build.sh" --push
echo "Pushed $IMAGE"
