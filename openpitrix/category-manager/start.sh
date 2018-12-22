#!/usr/bin/env bash

source /opt/category-manager/log.sh
log "Start category-manager container..."

CONTAINER_NAME="openpitrix-category-manager"
LOG_LEVEL=$(curl -s http://metadata/self/env/openpitrix_log_level)
GRPC_SHOW_ERROR_CASE=$(curl -s http://metadata/self/env/openpitrix_grpc_show_error_cause)

log "LOG_LEVEL: ${LOG_LEVEL}, GRPC_SHOW_ERROR_CASE: ${GRPC_SHOW_ERROR_CASE}."

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/category-manager/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/category-manager/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
log "DB_IP:${DB_IP} DB_HOST:${DB_HOST}"
log "ETCD_IP:${DB_IP} ETCD_HOST:${DB_HOST}"

#Start category-manager container
docker run -it -d -p 9102:9102 \
		   -v /opt/category-manager/updateContainer:/opt \
		   --add-host ${DB_HOST}:${DB_IP} \
		   --add-host ${ETCD_HOST}:${ETCD_IP} \
 		   -e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} \
 		   -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE} \
 		   -e OPENPITRIX_MYSQL_DATABASE=app \
 		   -e OPENPITRIX_PROFILING_ENABLE=1 \
 		   --restart=always \
 		   --name ${CONTAINER_NAME} \
 		   openpitrix:latest category-manager

log "Category-manager started."