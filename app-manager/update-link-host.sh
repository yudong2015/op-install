#!/usr/bin/env bash

cat /opt/app-manager/hosts/origin-hosts /opt/app-manager/hosts/link-hosts > /etc/hosts

CONTAINER_NAME="openpitrix-app-manager"
docker exec -it $CONTAINER_NAME cat /opt/hosts/containerHosts /opt/hosts/link-hosts > /etc/hosts 