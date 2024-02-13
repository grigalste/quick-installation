#!/bin/bash

mkdir -p /app/$INSTALLED_APP/connector

source additions/dependencies.sh

if [ "$HTTP_PROTO" == "http" ]; then
	cp -f /app/nginx/nginx_http.conf /app/moodle/nginx.conf
else
	cp -f /app/nginx/nginx_https.conf /app/moodle/nginx.conf
fi

sed -i 's/\/app\/nginx\/nginx.conf/\/app\/moodle\/nginx.conf/g' /app/nginx/nginx.yml;

if [ "$EMAIL_NAME" == "" ]; then
	echo "EMAIL_NAME=example@example.com" >> /app/.env;
fi

docker-compose -f moodle/moodle_mariadb.yml -f document-server/document-server.yml -f nginx/nginx.yml --env-file /app/.env up -d

JWT_SECRET=$(awk -F= "/DOCUMENT_SERVER_JWT_SECRET/ {print \$2}" /app/.env | tr -d '\r');
JWT_HEADER=$(awk -F= "/DOCUMENT_SERVER_JWT_HEADER/ {print \$2}" /app/.env | tr -d '\r');

source additions/check_container_healthy.sh
check_container_healthy app-server

if [ "$DOMAIN_NAME" == "" ]; then
	readonly DOMAIN_NAME=$(wget -q -O - ifconfig.me/ip)
fi

docker exec -it app-server /bin/sh -c "cd /var/www/localhost/htdocs/protected && ./yii module/enable onlyoffice && ./yii settings/set onlyoffice serverUrl $HTTP_PROTO://$DOMAIN_NAME/ds-vpath/ && ./yii settings/set onlyoffice jwtSecret $JWT_SECRET && ./yii settings/set onlyoffice jwtHeader $JWT_HEADER "

echo -e "Then you can go to the humhub web interface at: ${HTTP_PROTO}://${DOMAIN_NAME} and check the connector operation."
echo -e "The script is finished"

# Restoring the configuration

#	sed -i 's/nginx_http.conf/nginx_https.conf/g' /app/nginx/nginx.yml;
	sed -i 's/\/app\/nginx\/nginx.conf/\/app\/moodle\/nginx.conf/g' /app/nginx/nginx.yml;

