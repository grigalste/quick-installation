#!/bin/bash

echo "Domain name: ${HTTP_PROTO}://${HTTP_URL}";

echo "Configure Moodle config.php";
sed -i "s/>dbtype.*/>dbtype    = '${SQL_DB_TYPE}';/g" /var/www/html/appserver/config.php
sed -i "s/>dblibrary.*/>dblibrary = 'native';/g" /var/www/html/appserver/config.php 
sed -i "s/>dbhost.*/>dbhost = '${SQL_DB_HOST}';/g" /var/www/html/appserver/config.php 
sed -i "s/>dbname.*/>dbname = '${SQL_DB_NAME}';/g" /var/www/html/appserver/config.php 
sed -i "s/>dbuser.*/>dbuser = '${SQL_DB_USER}';/g" /var/www/html/appserver/config.php 
sed -i "s/>dbpass.*/>dbpass = '${SQL_DB_PASS}';/g" /var/www/html/appserver/config.php 
sed -i "s/>wwwroot.*/>wwwroot = '${HTTP_PROTO}:\/\/${HTTP_URL}';/g" /var/www/html/appserver/config.php 
sed -i "s/>dataroot.*/>dataroot = '\/var\/www\/html\/appserverdata';/g" /var/www/html/appserver/config.php 

if [ "$HTTP_PROTO" != "http" ]; then
	sed -i '/wwwroot/a$CFG->sslproxy = true;' /var/www/html/appserver/config.php ;
fi