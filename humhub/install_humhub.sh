#!/bin/bash

VERSION_HUMHUB="";
JWT_SECRET="My-Secret";

apt update -y
apt install jq wget unzip curl -y

VERSION_HUMHUB=$(curl -s https://api.github.com/repos/ONLYOFFICE/onlyoffice-humhub/releases | jq -r '.[] | select(.prerelease==false) | .name' | sort -n | tail -n1);

mkdir -p /app/humhub/{mysql,modules}

#docker network create onlynetwork
# --network onlynetwork

docker run -d --name humhub_db -v /app/humhub/mysql:/var/lib/mysql --restart=always \
-e MARIADB_ROOT_PASSWORD=my-secret-pw \
-e MARIADB_DATABASE=humhub_db \
-e MARIADB_USER=humhub \
-e MARIADB_PASSWORD=humhub \
mariadb:10.2

docker run -d --name humhub --restart=always -v /app/humhub/modules:/var/www/localhost/htdocs/protected/modules -p 80:80 -p 443:443 --link humhub_db:db \
-e HUMHUB_DB_USER=humhub \
-e HUMHUB_DB_PASSWORD=humhub \
-e HUMHUB_DB_NAME=humhub_db \
-e HUMHUB_DB_HOST=humhub_db \
-e HUMHUB_AUTO_INSTALL=true \
-e HUMHUB_ADMIN_LOGIN=admin \
-e HUMHUB_ADMIN_EMAIL=humhub@example.com \
-e HUMHUB_ADMIN_PASSWORD=MySuperAdminPassw0rd \
 mriedmann/humhub:stable

docker run -i -t -d --name onlyoffice-document-server -p 8080:80 --restart=always -e JWT_SECRET=$JWT_SECRET onlyoffice/documentserver-ee

wget -O /app/humhub/modules/onlyoffice.zip https://github.com/ONLYOFFICE/onlyoffice-humhub/releases/download/$VERSION_HUMHUB/onlyoffice.zip
unzip -o /app/humhub/modules/onlyoffice.zip -d /app/humhub/modules
rm /app/humhub/modules/onlyoffice.zip

echo "Status of the containers"
sleep 5
docker ps --format '{{.Names}}'"\t""Status:  "'{{.Status}}'
sleep 5

readonly EXT_IP=$(wget -q -O - ifconfig.me/ip)

docker exec -it humhub /bin/sh -c "cd /var/www/localhost/htdocs/protected && ./yii module/enable onlyoffice && ./yii settings/set onlyoffice serverUrl http://$EXT_IP:8080/ && ./yii settings/set onlyoffice jwtSecret $JWT_SECRET"

echo -e "\e[0;32m Then you can go to the humhub web interface at: http://${EXT_IP} and check the connector operation. \e[0m"

# docker exec -it humhub /bin/sh -c "cd /var/www/localhost/htdocs/protected && ./yii module/enable onlyoffice && ./yii settings/set onlyoffice serverUrl /ds-vpath/ && ./yii settings/set onlyoffice jwtSecret $JWT_SECRET && ./yii settings/set onlyoffice internalServerUrl http://onlyoffice-document-server && ./yii settings/set onlyoffice storageUrl http://app-server/"

echo -e "\e[0;32m The script is finished \e[0m"
