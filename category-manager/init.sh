#!/usr/bin/env bash

LOG_FILE="/opt/category-manager/log"
echo "Start init..." >> ${LOG_FILE}

DB_ROLE="openpitrix-db"
MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/links/external_service_${DB_ROLE}/env/${DB_ROLE}/mysql_root_password)
echo "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}..." >> ${LOG_FILE}

# migrate app database
# befor migrating, copy app schema from openpitrix/pkg/schema/app to /opt/category-manager/schema
docker run -it -d -v /opt/category-manager/schema:/flyway/sql --net=host \
 		   dhoer/flyway:5.1.4-mysql-8.0.11-alpine -url=jdbc:mysql://openpitrix-db/app -user=root -password=${MYSQL_ROOT_PASSWORD} -validateOnMigrate=false migrate

echo "Finished init." >> ${LOG_FILE}