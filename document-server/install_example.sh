#!/bin/bash

if [ "$DS_SERVICE_TAG" == "" ]; then
	DS_SERVICE_TAG='latest';
fi

echo "DS_SERVICE_TAG=${DS_SERVICE_TAG}" >> /app/.env;

sed -i 's/\/app\/nginx\/nginx/\/app\/document-server\/nginx/g' /app/nginx/nginx.yml;

if [ "$HTTP_PROTO" == "http" ]; then

    cp -f /app/document-server/nginx_http.conf /app/document-server/nginx.conf
else
    cp -f /app/document-server/nginx_https.conf /app/document-server/nginx.conf
fi

docker-compose -f document-server/document-server.yml -f nginx/nginx.yml --env-file /app/.env up -d

source additions/check_container_healthy.sh
check_container_healthy onlyoffice-document-server

docker exec onlyoffice-document-server sudo supervisorctl start ds:example
docker exec onlyoffice-document-server sudo sed 's,autostart=false,autostart=true,' -i /etc/supervisor/conf.d/ds-example.conf

# Restoring the configuration
#	sed -i 's/nginx_http.conf/nginx_https.conf/g' /app/nginx/nginx.yml;
    sed -i 's/\/app\/document-server\/nginx/\/app\/nginx\/nginx/g' /app/nginx/nginx.yml;

