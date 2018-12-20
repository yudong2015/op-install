#!/usr/bin/env bash

echo "Start updating link hosts..." >> /opt/app-manager/log

DB_IP=`cat /opt/app-manager/link-hosts|grep DB_IP|cut -d "=" -f 2`
DB_HOST=`cat /opt/app-manager/link-hosts|grep DB_HOST|cut -d "=" -f 2`

echo "${DB_IP} ${DB_HOST}" > /opt/app-manager/link-hosts.tmp
cat /opt/app-manager/hosts/origin-hosts /opt/app-manager/link-hosts.tmp > /etc/hosts

echo "DB_IP:${DB_IP} DB_HOST:${DB_HOST}" >> /opt/app-manager/log

#check if openpitrix-app-manager exist
CONTAINER_NAME="openpitrix-app-manager"
n=`docker ps|grep ${CONTAINER_NAME}|wc -l`
if [ $n > 0 ]; then
	echo "Run update container ip..." >> /opt/app-manager/log
    docker exec -it $CONTAINER_NAME updateContainerHosts.sh $DB_IP $DB_HOST
else
	echo "There is no container, just update local link hosts..." >> /opt/app-manager/log
fi