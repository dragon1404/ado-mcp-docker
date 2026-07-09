# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Docker image that packages Microsoft's Azure DevOps MCP server (`@azure-devops/mcp`, npm) and fronts it with `mcp-proxy` (npm, MIT) so network clients can reach it over HTTP/SSE. There is no application code here — the repo is entirely a Docker packaging/config layer around two upstream npm CLIs.

## Why mcp-proxy exists

`@azure-devops/mcp` only implements `StdioServerTransport` (hardcoded in its `index.js`, not configurable via flags) — it cannot listen on a network port by itself. `entrypoint.sh` runs `mcp-proxy -- mcp-server-azuredevops <org> ...`, which spawns the stdio server as a child process and re-exposes it as SSE (`/sse`) and streamable HTTP (`/mcp`). Any change to how the server is invoked must go through `entrypoint.sh`, not by trying to pass HTTP flags to `mcp-server-azuredevops` directly — they don't exist.

## Commands

```bash
docker build -t ado-mcp .                    # build image
docker compose -f docker-compose.build.yml up -d   # build+run via compose (needs .env, copy from .env.example)
docker run -d --rm -p 8080:8080 \
  -e AZURE_DEVOPS_ORG=<org> \
  -e PERSONAL_ACCESS_TOKEN=<base64 email:pat> \
  -e MCP_PROXY_API_KEY=<optional> \
  ado-mcp                                    # run standalone
docker logs -f <container>                   # startup logs come from both the ADO server (JSON lines) and mcp-proxy
```

No build/lint/test tooling in this repo (no source code to compile). Validate changes by building the image and curling the endpoint, e.g.:

```bash
curl -N -H "X-API-Key: <key>" http://localhost:8080/sse   # expect an `event: endpoint` line
```

## Config surface (env vars, all wired through entrypoint.sh)

- `AZURE_DEVOPS_ORG` — required, ADO org name (becomes `https://dev.azure.com/<org>`)
- `AUTH_METHOD` — auth mode passed to `mcp-server-azuredevops --authentication`; default `pat`. Other values (`interactive`, `azcli`, `envvar`) exist upstream but are not practical inside a container — `interactive` needs a browser, `azcli` needs a mounted `az login` session.
- `PERSONAL_ACCESS_TOKEN` — required when `AUTH_METHOD=pat`; must be base64 of `<any-non-empty-string>:<raw-PAT>` (upstream decodes and discards the left side)
- `PORT` / `HOST` — what mcp-proxy binds to inside the container (default `8080` / `0.0.0.0`); in compose, `PORT` also controls the host-side published port
- `MCP_PROXY_API_KEY` — if set, mcp-proxy requires clients to send `X-API-Key: <value>`; if unset, the endpoint is unauthenticated

## Gotchas

- `entrypoint.sh` builds the mcp-proxy arg string unquoted (`$ARGS`) so it word-splits into separate argv entries — do not put spaces inside `MCP_PROXY_API_KEY` or the port/host values.
- The Azure DevOps server logs its own JSON-formatted lines on startup (org, enabled domains, etc.) before mcp-proxy's plaintext "starting server on port" line — both go to the same stdout stream.
- `docker build` prints a `SecretsUsedInArgOrEnv` warning for the `AUTH_METHOD` ENV — this is a false positive (it's not secret), left as-is.
- `docker-publish.yml` builds multi-arch (`linux/amd64,linux/arm64`) via QEMU + buildx so the ghcr.io image pulls natively on Apple Silicon; local `docker build`/`docker compose build` still only produce a single-arch image for your host.
