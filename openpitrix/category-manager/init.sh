#!/usr/bin/env bash

source /opt/category-manager/log.sh
log "Start init..."

DB_ROLE="openpitrix-db"
MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/links/external_service_${DB_ROLE}/env/${DB_ROLE}/mysql_root_password)
log "MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}..."

# migrate app database
# befor migrating, copy app schema from openpitrix/pkg/schema/app to /opt/category-manager/schema
docker run -it -d -v /opt/category-manager/schema:/flyway/sql --net=host \
 		   dhoer/flyway:5.1.4-mysql-8.0.11-alpine -url=jdbc:mysql://openpitrix-db/app -user=root -password=${MYSQL_ROOT_PASSWORD} -validateOnMigrate=false migrate

log "Finished init."