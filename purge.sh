#!/bin/bash

docker rm -f $(docker ps -qa)
docker volume rm $(docker volume ls -q)
#docker network rm $(docker network ls -q)
rm -rf /app && cd / 