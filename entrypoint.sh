#!/bin/sh
set -e

ARGS="--port ${PORT:-8080} --host ${HOST:-0.0.0.0}"

if [ -n "$MCP_PROXY_API_KEY" ]; then
  ARGS="$ARGS --apiKey $MCP_PROXY_API_KEY"
fi

exec mcp-proxy $ARGS -- mcp-server-azuredevops "$AZURE_DEVOPS_ORG" --authentication "$AUTH_METHOD"
