#!/bin/bash

if [ "$SERVICE_TAG" == "" ]; then
	SERVICE_TAG='latest';
fi

if [ "$DS_SERVICE_TAG" == "" ]; then
	DS_SERVICE_TAG='latest';
fi

echo "DS_SERVICE_TAG=${DS_SERVICE_TAG}" >> /app/.env;
echo "SERVICE_TAG=${SERVICE_TAG}" >> /app/.env;

download_connector () {

if [ "$CONNECTOR_URL" == "" ]; then
	CONNECTOR_VERSION=$(curl -s https://api.github.com/repos/ONLYOFFICE/onlyoffice-$INSTALLED_APP/releases | jq -r '.[] | select(.prerelease==false) | .name' | sort -n | tail -n1 );
	CONNECTOR_NAME=$(curl -s https://api.github.com/repos/ONLYOFFICE/onlyoffice-$INSTALLED_APP/releases | jq  -r '.[0] | .assets[] | .name ' );
	CONNECTOR_URL="https://github.com/ONLYOFFICE/onlyoffice-$INSTALLED_APP/releases/download/$CONNECTOR_VERSION/$CONNECTOR_NAME";
else
	CONNECTOR_VERSION=$(echo $CONNECTOR_URL | cut -d'/' -f8);
 	CONNECTOR_NAME=$(echo $CONNECTOR_URL | cut -d'/' -f9);
fi

wget -O /app/$INSTALLED_APP/connector/$CONNECTOR_NAME $CONNECTOR_URL

EXP_FILE_CONNECTOR=$( echo $CONNECTOR_NAME | awk -F. '{print $NF}' );

	case $EXP_FILE_CONNECTOR in

		zip )
			unzip -o /app/$INSTALLED_APP/connector/$CONNECTOR_NAME -d /app/$INSTALLED_APP/connector
            echo "unzip";
		;;

		zst )
			tar -I zstd -xvf /app/$INSTALLED_APP/connector/$CONNECTOR_NAME  -C /app/$INSTALLED_APP/connector
            echo "zstd";
		;;

	esac

rm /app/$INSTALLED_APP/connector/$CONNECTOR_NAME

}

download_connector