FROM node:20-alpine

RUN npm install -g @azure-devops/mcp mcp-proxy

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV AZURE_DEVOPS_ORG=""
ENV AUTH_METHOD="pat"
ENV PORT=8080
ENV HOST=0.0.0.0

EXPOSE 8080

USER node

ENTRYPOINT ["/entrypoint.sh"]
