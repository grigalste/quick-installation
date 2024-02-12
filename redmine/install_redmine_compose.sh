#!/bin/bash

#CONNECTOR_URL=$(curl -s https://api.github.com/repos/ONLYOFFICE/onlyoffice-redmine/releases | jq  -r '.[0] | .assets[] | .browser_download_url ');
#CONTEINER_IP=$(docker inspect app-server | jq  -r '.[] | .NetworkSettings.Networks.redmine_onlyoffice.IPAddress ' );

mkdir -p /app/$INSTALLED_APP/connector

source dependencies.sh

if [ "$HTTP_PROTO" == "http" ]; then
    cp -f /app/redmine/nginx_http.conf /app/redmine/nginx.conf
else
    cp -f /app/redmine/nginx_https.conf /app/redmine/nginx.conf
fi

sed -i 's/\/app\/nginx\/nginx/\/app\/redmine\/nginx/g' /app/nginx/nginx.yml;

docker-compose -f redmine/redmine-postgres.yml -f document-server/document-server.yml -f nginx/nginx.yml --env-file /app/.env up -d

if [ "$DOMAIN_NAME" == "" ]; then
	readonly DOMAIN_NAME=$(wget -q -O - ifconfig.me/ip)
fi

echo -e "\nThen you can go to the humhub web interface at: ${HTTP_PROTO}://${DOMAIN_NAME} and check the connector operation.\n"
echo -e "\nThe script is finished\n"

# Restoring the configuration
#	sed -i 's/\/app\/nginx\/nginx.conf/\/app\/nginx\/nginx_https.conf/g' /app/nginx/nginx.yml;
    sed -i 's/\/app\/redmine\/nginx/\/app\/nginx\/nginx/g' /app/nginx/nginx.yml;

