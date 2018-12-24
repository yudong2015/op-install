#!/usr/bin/env bash

source /opt/openpitrix/log.sh

if [ -n "$1" ] ;then
  SERVICE=$1
else
	log "The service name is empty!"
	log "eg: /opt/openpitrix/init.sh $SERVICE"
fi

log "Start init db of ${SERVICE} ..."

DB_ROLE="openpitrix-db"
MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/links/external_service_${DB_ROLE}/env/${DB_ROLE}/mysql_root_password)
log "mysql_root_password: ${MYSQL_ROOT_PASSWORD}."

DB=$(curl -s http://metadata/self/env/${SERVICE}-database)

# migrate database
# befor migrating, copy app schema from openpitrix/pkg/schema/ to /opt/openpitrix/schema
docker run -it -d -v /opt/openpitrix/schema/${DB}:/flyway/sql --net=host \
 		   dhoer/flyway:5.1.4-mysql-8.0.11-alpine -url=jdbc:mysql://openpitrix-db/${DB} -user=root -password=${MYSQL_ROOT_PASSWORD} -validateOnMigrate=false migrate

log "Finished init database ${DB} of ${SERVICE}."