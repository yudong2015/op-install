#!/usr/bin/env bash

echo "Start init..." >> /opt/app-manager/log

MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/links/external_service/env/openpitrix-db/mysql_root_password)
echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}..." >> /opt/app-manager/log

# migrate app database
# befor migrating, copy app schema from openpitrix/pkg/schema/app to /opt/app-manager/schema
docker run -it -d -v /opt/app-manager/schema:/flyway/sql --net=host \
 		   dhoer/flyway:5.1.4-mysql-8.0.11-alpine -url=jdbc:mysql://openpitrix-db/app -user=root -password=${MYSQL_ROOT_PASSWORD} -validateOnMigrate=false migrate

echo "Finished init." >> /opt/app-manager/log