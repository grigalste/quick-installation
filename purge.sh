#!/bin/bash

#docker rm -f $(docker ps -qa)
#docker volume rm $(docker volume ls -q)
#docker network rm $(docker network ls -q)
docker system prune -af
cd /
rm -rf /app
