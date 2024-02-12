#!/bin/bash

set -e

PARAMETERS="$PARAMETERS";
PARAMETERS="$PARAMETERS ${@}";

DOMAIN_NAME='';
EMAIL_NAME='';
INSTALLED_APP='';
HTTP_PROTO="https";

cp -f /app/.env_template /app/.env

while [ "$1" != "" ]; do
	case $1 in
		-app | --app )
			if [ "$2" != "" ]; then
				INSTALLED_APP=$2 ;
				INSTALLED_APP=$(echo $INSTALLED_APP | tr [:upper:] [:lower:] );
				shift
			fi
		;;

		-version | --version | -ver )
			if [ "$2" != "" ]; then
				SERVICE_TAG=$2 ;
				SERVICE_TAG=$(echo $SERVICE_TAG | tr [:upper:] [:lower:] );
				shift
			fi
		;;

		-ds_version | --ds_version | -dsv )
			if [ "$2" != "" ]; then
				DS_SERVICE_TAG=$2 ;
				DS_SERVICE_TAG=$(echo $DS_SERVICE_TAG | tr [:upper:] [:lower:] );
				shift
			fi
		;;

		-url_connect | --url_connect | -uc )
			if [ "$2" != "" ]; then
				CONNECTOR_URL=$2 ;
				shift
			fi
		;;

		-domain | --domain | -d )
			if [ "$2" != "" ]; then
				DOMAIN_NAME=$2
				echo "DOMAIN_NAME=${DOMAIN_NAME}" >> /app/.env
				shift
			fi
		;;

		-email | --email | -e )
			if [ "$2" != "" ]; then
				EMAIL_NAME=$2
				echo "EMAIL_NAME=${EMAIL_NAME}" >> /app/.env
				shift
			fi
		;;

		-http | --http )
			if [ "$2" != "" ]; then
				HTTP_PROTO="http";
				shift
			fi
		;;
	
	esac
	shift
done

command_exists () {
    type "$1" &> /dev/null;
}

apt update -y;
apt install jq unzip zstd curl wget ca-certificates net-tools -y;

if command_exists docker; then
	echo "Docker is already installed";
else
	source docker/install_docker.sh;
fi

docker version | head -n2;
docker-compose version | head -n1;

if [ ! -f "/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem" ] && [ "$HTTP_PROTO" != "http" ]; then
    echo -e "\nCertificate was not received\n"

	bash nginx/nginx_le_cert_gen.sh ${PARAMETERS}

else
	echo -e "\nCertificates already exist\n";
	
	mkdir -p /app/nginx/ssl/
	cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem /app/nginx/ssl/
	cp -f /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem /app/nginx/ssl/
fi

	case $INSTALLED_APP in
		humhub )
			source humhub/install_humhub_compose.sh 
		;;
		
		example )
			source document-server/install_example.sh
		;;

		redmine )
			source redmine/install_redmine_compose.sh
		;;

		nextcloud )
			echo "Files are missing";
		;;
		
	esac