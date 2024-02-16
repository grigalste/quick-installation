#!/bin/bash

mkdir -p /app/$INSTALLED_APP/connector

SERVICE_TAG=${SERVICE_TAG:-MOODLE_403_STABLE};
git clone -b ${SERVICE_TAG} git://git.moodle.org/moodle.git /app/$INSTALLED_APP/moodle_git ;
rm -rf /app/$INSTALLED_APP/moodle_git/.* /app/$INSTALLED_APP/moodle_git/*.txt ;
cp -f /app/$INSTALLED_APP/moodle_git/config-dist.php /app/$INSTALLED_APP/moodle_git/config.php

source additions/dependencies.sh

if [ "$HTTP_PROTO" == "http" ]; then
	cp -f /app/moodle/nginx_http.conf /app/moodle/nginx.conf
else
	cp -f /app/moodle/nginx_https.conf /app/moodle/nginx.conf
fi

sed -i 's/\/app\/nginx\/nginx.conf/\/app\/moodle\/nginx.conf/g' /app/nginx/nginx.yml;

if [ "$EMAIL_NAME" == "" ]; then
	echo "EMAIL_NAME=example@example.com" >> /app/.env;
fi

docker-compose -f moodle/moodle_mariadb.yml -f document-server/document-server.yml -f nginx/nginx.yml --env-file /app/.env up -d

JWT_SECRET=$(awk -F= "/DOCUMENT_SERVER_JWT_SECRET/ {print \$2}" /app/.env | tr -d '\r');
JWT_HEADER=$(awk -F= "/DOCUMENT_SERVER_JWT_HEADER/ {print \$2}" /app/.env | tr -d '\r');

APP_SERVER_PORT="8080";
source additions/check_connection.sh

if [ "$DOMAIN_NAME" == "" ]; then
	readonly DOMAIN_NAME=$(wget -q -O - ifconfig.me/ip)
fi

echo -e "Then you can go to the Moodle web interface at: ${HTTP_PROTO}://${DOMAIN_NAME} and check the connector operation."
echo -e "The script is finished"

# Restoring the configuration

#	sed -i 's/nginx_http.conf/nginx_https.conf/g' /app/nginx/nginx.yml;
	sed -i 's/\/app\/moodle\/nginx.conf/\/app\/nginx\/nginx.conf/g' /app/nginx/nginx.yml;

