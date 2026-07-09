# ado-mcp-docker

[![Docker](https://github.com/dragon1404/ado-mcp-docker/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/dragon1404/ado-mcp-docker/actions/workflows/docker-publish.yml)

Docker image wrapping Microsoft's [Azure DevOps MCP Server](https://github.com/microsoft/azure-devops-mcp) (`@azure-devops/mcp`) and exposing it over HTTP (SSE + streamable) via [`mcp-proxy`](https://github.com/punkpeye/mcp-proxy), since the upstream server only speaks stdio. Runs as non-root.

## Get the image

Pull the prebuilt image from GitHub Container Registry (multi-arch: amd64 + arm64):

```bash
docker pull ghcr.io/dragon1404/ado-mcp-docker:latest
```

Or build it yourself:

```bash
docker build -t ado-mcp .
```

(Examples below use `ado-mcp` as the tag — swap in `ghcr.io/dragon1404/ado-mcp-docker:latest` if you pulled instead of built.)

## Run

Auth via Personal Access Token (PAT). `PERSONAL_ACCESS_TOKEN` must be base64 of `<email>:<pat>`.

### docker run

```bash
PAT_B64=$(printf '%s' "you@example.com:$ADO_PAT" | base64)

docker run -d --rm -p 8080:8080 \
  -e AZURE_DEVOPS_ORG=<your-org> \
  -e PERSONAL_ACCESS_TOKEN="$PAT_B64" \
  -e MCP_PROXY_API_KEY=<optional-shared-secret> \
  ado-mcp
```

### docker compose

```bash
cp .env.example .env   # fill in AZURE_DEVOPS_ORG + PERSONAL_ACCESS_TOKEN
docker compose up -d
```

To pull the prebuilt image instead of building locally, use `docker-compose.remote.yml`:

```bash
cp .env.example .env
docker compose -f docker-compose.remote.yml up -d
```

## Endpoint

Server listens on `PORT` (default `8080`), exposing:

- SSE: `http://<host>:8080/sse`
- Streamable HTTP: `http://<host>:8080/mcp`

If `MCP_PROXY_API_KEY` is set, clients must send it as `X-API-Key: <value>`.

### Connecting from another service (e.g. multica)

```json
{
  "servers": {
    "ado": {
      "type": "sse",
      "url": "http://<host>:8080/sse",
      "headers": { "X-API-Key": "<MCP_PROXY_API_KEY>" }
    }
  }
}
```

Use `"type": "http"` with the `/mcp` URL instead if the client speaks streamable HTTP rather than SSE.

## Other auth methods (to Azure DevOps)

Set `AUTH_METHOD` env var to `interactive` (default, browser login), `azcli` (uses host `az login` session — not usable in a container without mounting Azure CLI config), or `pat` (see above). See [upstream docs](https://github.com/microsoft/azure-devops-mcp/blob/main/docs/GETTINGSTARTED.md) for detail.
