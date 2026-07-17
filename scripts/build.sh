#!/usr/bin/env bash
# Build (and optionally --push) the searxng-mcp image.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${SEARXNG_MCP_IMAGE:-xbeta/mcp-search:latest}"
PLATFORM="${PLATFORM:-linux/amd64}"

PUSH=0
ARGS=()
for a in "$@"; do
  if [[ "$a" == "--push" ]]; then
    PUSH=1
  else
    ARGS+=("$a")
  fi
done

cd "$ROOT"
echo "Building $IMAGE ($PLATFORM) push=$PUSH"

if docker buildx version >/dev/null 2>&1; then
  if [[ "$PUSH" -eq 1 ]]; then
    docker buildx build --platform "$PLATFORM" -t "$IMAGE" -f searxng-mcp/Dockerfile searxng-mcp --push "${ARGS[@]}"
  else
    docker buildx build --platform "$PLATFORM" -t "$IMAGE" -f searxng-mcp/Dockerfile searxng-mcp --load "${ARGS[@]}"
  fi
else
  # Native docker build (host arch). Prefer running on amd64 for gateway compatibility.
  docker build -t "$IMAGE" -f searxng-mcp/Dockerfile searxng-mcp "${ARGS[@]}"
  if [[ "$PUSH" -eq 1 ]]; then
    docker push "$IMAGE"
  fi
fi
echo "OK: $IMAGE"
