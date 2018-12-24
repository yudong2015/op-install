#!/usr/bin/env bash

source /opt/repo-indexer/log.sh
log "Start repo-indexer container..."

CONTAINER_NAME="openpitrix-repo-indexer"
LOG_LEVEL=$(curl -s http://metadata/self/env/openpitrix_log_level)
GRPC_SHOW_ERROR_CASE=$(curl -s http://metadata/self/env/openpitrix_grpc_show_error_cause)
SERVICE_PORT=$(curl -s http://metadata/self/env/repo_indexer_port)

log "LOG_LEVEL: ${LOG_LEVEL}, GRPC_SHOW_ERROR_CASE: ${GRPC_SHOW_ERROR_CASE}."

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/repo-indexer/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/repo-indexer/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
log "DB_IP:${DB_IP} DB_HOST:${DB_HOST}"
log "ETCD_IP:${DB_IP} ETCD_HOST:${DB_HOST}"

#Start repo-indexer container
docker run -it -d -p ${SERVICE_PORT}:${SERVICE_PORT} \
		   -v /opt/repo-indexer/updateContainer:/opt \
		   --add-host ${DB_HOST}:${DB_IP} \
		   --add-host ${ETCD_HOST}:${ETCD_IP} \
 		   -e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} \
 		   -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE} \
 		   -e OPENPITRIX_MYSQL_DATABASE=repo \
 		   -e OPENPITRIX_PROFILING_ENABLE=1 \
 		   --restart=always \
 		   --name ${CONTAINER_NAME} \
 		   openpitrix:latest repo-indexer

log "Repo-indexer started."