#!/bin/bash

check_container_healthy () {
if [[ $(docker ps | grep ${1} | cut -d'(' -f2 | cut -d')' -f1 ) == 'healthy' ]] ; then
	echo "The container ${INSTALLED_APP} is running";
else
	echo "Waiting for the container ${INSTALLED_APP} to start...";
	sleep 5;
	check_container_healthy ${1}
fi
}
