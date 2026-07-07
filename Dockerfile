FROM node:20-alpine

RUN npm install -g @azure-devops/mcp

ENV AZURE_DEVOPS_ORG=""
ENV AUTH_METHOD="pat"

ENTRYPOINT ["sh", "-c", "exec mcp-server-azuredevops \"$AZURE_DEVOPS_ORG\" --authentication \"$AUTH_METHOD\""]
