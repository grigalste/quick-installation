#!/bin/bash

echo "Installing dependencies";
apt-get update && apt-get install -y apt-transport-https curl wget ca-certificates software-properties-common gnupg2 ntp net-tools

echo "Installing Docker";
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update -y
apt install -y docker-ce docker-ce-cli jq
systemctl enable --now docker

echo "Installing Docker Compose";
VERSION_DOCKER_COMPOSE=$(curl -s https://api.github.com/repos/docker/compose/releases | jq -r '.[] | select(.prerelease==false) | .name' | sort -n | tail -n1);
curl -L "https://github.com/docker/compose/releases/download/$VERSION_DOCKER_COMPOSE/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
