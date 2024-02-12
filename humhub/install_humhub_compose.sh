#!/bin/bash

mkdir -p /app/$INSTALLED_APP/{uploads,config,connector}

source dependencies.sh

if [ "$HTTP_PROTO" == "http" ]; then
	cp -f /app/nginx/nginx_http.conf /app/humhub/nginx.conf
else
	cp -f /app/nginx/nginx_https.conf /app/humhub/nginx.conf
	sed -i 's/#      HUMHUB_PROTO/      HUMHUB_PROTO/g' /app/humhub/humhub-mariadb.yml;
fi

sed -i 's/\/app\/nginx\/nginx.conf/\/app\/humhub\/nginx.conf/g' /app/nginx/nginx.yml;

if [ "$DOMAIN_NAME" != "" ]; then
	sed -i 's/#      HUMHUB_HOST/      HUMHUB_HOST/g' /app/humhub/humhub-mariadb.yml;
fi

if [ "$EMAIL_NAME" == "" ]; then
	echo "EMAIL_NAME=example@example.com" >> /app/.env;
fi

docker-compose -f humhub/humhub-mariadb.yml -f document-server/document-server.yml -f nginx/nginx.yml --env-file /app/.env up -d

JWT_SECRET=$(awk -F= "/DOCUMENT_SERVER_JWT_SECRET/ {print \$2}" /app/.env | tr -d '\r');
JWT_HEADER=$(awk -F= "/DOCUMENT_SERVER_JWT_HEADER/ {print \$2}" /app/.env | tr -d '\r');

check_humhub_healthy () {
if [[ $(docker ps | grep app-server | cut -d'(' -f2 | cut -d')' -f1 ) == 'healthy' ]] ; then
	echo "The container HUMHUB is running";
else
	echo "Waiting for the container HUMHUB to start...";
	sleep 5;
	check_humhub_healthy
fi
}

check_humhub_healthy

if [ "$DOMAIN_NAME" == "" ]; then
	readonly DOMAIN_NAME=$(wget -q -O - ifconfig.me/ip)
fi

docker exec -it app-server /bin/sh -c "cd /var/www/localhost/htdocs/protected && ./yii module/enable onlyoffice && ./yii settings/set onlyoffice serverUrl $HTTP_PROTO://$DOMAIN_NAME/ds-vpath/ && ./yii settings/set onlyoffice jwtSecret $JWT_SECRET && ./yii settings/set onlyoffice jwtHeader $JWT_HEADER "
## && ./yii settings/set onlyoffice internalServerUrl http://onlyoffice-document-server && ./yii settings/set onlyoffice storageUrl http://app-server/"

echo -e "Then you can go to the humhub web interface at: ${HTTP_PROTO}://${DOMAIN_NAME} and check the connector operation."
echo -e "The script is finished"

# Restoring the configuration
	sed -i 's/^      HUMHUB_PROTO/#      HUMHUB_PROTO/g' /app/humhub/humhub-mariadb.yml;
	sed -i 's/^      HUMHUB_HOST/#      HUMHUB_HOST/g' /app/humhub/humhub-mariadb.yml;
#	sed -i 's/nginx_http.conf/nginx_https.conf/g' /app/nginx/nginx.yml;
	sed -i 's/\/app\/humhub\/nginx.conf/\/app\/nginx\/nginx.conf/g' /app/nginx/nginx.yml;

