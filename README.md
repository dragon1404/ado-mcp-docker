# ado-mcp-docker

Docker image wrapping Microsoft's [Azure DevOps MCP Server](https://github.com/microsoft/azure-devops-mcp) (`@azure-devops/mcp`) for stdio-based MCP clients.

## Build

```bash
docker build -t ado-mcp .
```

## Run

Auth via Personal Access Token (PAT). `PERSONAL_ACCESS_TOKEN` must be base64 of `<email>:<pat>`:

```bash
PAT_B64=$(printf '%s' "you@example.com:$ADO_PAT" | base64)

docker run -i --rm \
  -e AZURE_DEVOPS_ORG=<your-org> \
  -e PERSONAL_ACCESS_TOKEN="$PAT_B64" \
  ado-mcp
```

## MCP client config example

```json
{
  "servers": {
    "ado": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "AZURE_DEVOPS_ORG=<your-org>",
        "-e", "PERSONAL_ACCESS_TOKEN=<base64 email:pat>",
        "ado-mcp"
      ]
    }
  }
}
```

## Other auth methods

Set `AUTH_METHOD` env var to `interactive` (default, browser login), `azcli` (uses host `az login` session — not usable in a container without mounting Azure CLI config), or `pat` (see above). See [upstream docs](https://github.com/microsoft/azure-devops-mcp/blob/main/docs/GETTINGSTARTED.md) for detail.
