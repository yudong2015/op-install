#!/usr/bin/env bash

MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/env/mysql_root_password)
CONTAINER_NAME="openpitrix-db"

#Start mysql container
#Befor starting, you need to copy ddl from openpitrix/pkg/db/ddl to server /opt/db/ddl.
docker run -it -d -p 3306:3306 \
		-v /opt/db/ddl:/docker-entrypoint-initdb.d \
		-v /opt/db/mysql:/var/lib/mysql \
		-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
		--restart=always \
		--name ${CONTAINER_NAME} \
		mysql:8.0.11

#Check mysql container status
until docker exec ${CONTAINER_NAME} bash -c "echo 'SELECT VERSION();' | mysql -uroot -p${MYSQL_ROOT_PASSWORD}"; do echo "waiting for mysql"; sleep 2; done;

#Init ddl
until docker exec ${CONTAINER_NAME} bash -c "cat /docker-entrypoint-initdb.d/*.sql | mysql -uroot -p${MYSQL_ROOT_PASSWORD}"; do echo "ddl waiting for mysql"; sleep 2; done;