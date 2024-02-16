#!/bin/bash

echo "Waiting for the launch of ${INSTALLED_APP} "  
APP_SERVER_IP=$( docker inspect app-server | jq -r '.[]  | .NetworkSettings.Networks.redmine_onlyoffice.IPAddress ' );
  
for i in {1..60}; do
    echo "An attempt to obtain a status: ${i}"

    CURL_OUTPUT="$(curl -Is http://${APP_SERVER_IP}:${APP_SERVER_PORT}/ | head -1 | awk '{ print $2 }')"

    if [ "${CURL_OUTPUT}" == "200" ]; then
      echo "App-Server is ready to install the plugin"
 
      APP_SERVER_READY='yes'

      break
    else  
      sleep 5
    fi
done

if [[ "${APP_SERVER_READY}" != 'yes' ]]; then
    err " I didn't wait for the launch of ${INSTALLED_APP}. Check the container logs using the command: sudo docker logs -f app-server "
    exit 1
fi
