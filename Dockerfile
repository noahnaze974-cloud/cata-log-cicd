FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="catal-log-static-site" \
      org.opencontainers.image.description="Site statique Nginx - Projet CICD EC06" \
      org.opencontainers.image.authors="TON_NOM"

COPY site/ /usr/share/nginx/html/

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:80/ || exit 1
