#!/bin/bash

DOMAIN_NAME='';
EMAIL_NAME='';

while [ "$1" != "" ]; do
	case $1 in
		-domain | --domain )
			if [ "$2" != "" ]; then
				DOMAIN_NAME=$2
				shift
			fi
		;;
		
		-email | --email )
			if [ "$2" != "" ]; then
				EMAIL_NAME=$2
				shift
			fi
		;;
		
	esac
	shift
done

if [ "$EMAIL_NAME" == "" ]; then
	EMAIL_NAME='example@example.com';
fi

if [ "$DOMAIN_NAME" == "" ]; then
	echo -e "The domain name is not specified";
	exit 1;
else
	echo -e "Request for a domain name $DOMAIN_NAME ";

	docker run --rm --name certbot -p 80:80 -v "/etc/letsencrypt:/etc/letsencrypt" -v "/lib/letsencrypt:/var/lib/letsencrypt" certbot/certbot certonly --standalone -n -m "${EMAIL_NAME}" -d "${DOMAIN_NAME}" --agree-tos

	mkdir -p /app/nginx/ssl/
	cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem /app/nginx/ssl/
	cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem /app/nginx/ssl/
fi

if [ ! -f "/app/nginx/ssl/fullchain.pem" ]; then
    echo -e "Certificate was not received"
    exit 1
fi
