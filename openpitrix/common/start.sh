#!/usr/bin/env bash

source /opt/openpitrix/log.sh

# get service name
if [[ -n "$1" ]];then
  SERVICE=$1
else
	log "The service name is empty!"
	log "usage: /opt/openpitrix/start.sh $SERVICE_NAME [$COMMAND]"
fi

# get command
if [ -n "$2" ]; then
	COMMAND=$2
else
	COMMAND=$SERVICE
fi

log "Start ${SERVICE} container..."

CONTAINER_NAME="openpitrix-${SERVICE}"
LOG_LEVEL=$(curl -s http://metadata/self/env/openpitrix_log_level)
GRPC_SHOW_ERROR_CASE=$(curl -s http://metadata/self/env/openpitrix_grpc_show_error_cause)
SERVICE_PORT=$(curl -s http://metadata/self/env/${SERVICE}-port)
DB=$(curl -s http://metadata/self/env/${SERVICE}-database)

log "LOG_LEVEL: ${LOG_LEVEL}, GRPC_SHOW_ERROR_CASE: ${GRPC_SHOW_ERROR_CASE}."

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/openpitrix/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/openpitrix/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
log "DB_IP:${DB_IP} DB_HOST:${DB_HOST}"
log "ETCD_IP:${DB_IP} ETCD_HOST:${DB_HOST}"

#Container PORTs, VOLUMEs, ENVs
PORTS="-p ${SERVICE_PORT}:${SERVICE_PORT}"
VOLUMES="-v /opt/openpitrix/updateContainer:/opt"
ENVS="-e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE} -e OPENPITRIX_MYSQL_DATABASE=${DB}"

if [[ ${SERVICE} == "app-manager" ||  ${SERVICE} == "repo-indexer" ]]; then
		ENVS="$ENVS -e OPENPITRIX_PROFILING_ENABLE=1"
elif [[ ${SERVICE} == "iam-service" ]]; then
		ID=$(curl -s http://metadata/self/env/iam_init_client_id)
		SECRET=$(curl -s http://metadata/self/env/iam_init_client_secret)
		EMAIL=$(curl -s http://metadata/self/env/iam_init_account_email)
		PASSWORD=$(curl -s http://metadata/self/env/iam_init_account_password)
		ENVS="$ENVS -e IAM_INIT_CLIENT_ID=${ID} IAM_INIT_CLIENT_SECRET=${SECRET} IAM_INIT_ACCOUNT_EMAIL=${EMAIL} IAM_INIT_ACCOUNT_PASSWORD=${PASSWORD}"
elif [[ ${SERVICE} == "pilot-service" ]]; then
		TLSLISTEN_PORT=$(curl -s http://metadata/self/env/pilot-TlsListen-port)
		PORTS="${PORTS} -p ${TLSLISTEN_PORT}:${TLSLISTEN_PORT}"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/pilot-service/pilot-config.json:/opt/openpitrix/conf/pilot-config.json"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/kubernetes/tls-config/openpitrix-ca.crt:/opt/openpitrix/conf/openpitrix-ca.crt"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/kubernetes/tls-config/pilot-server.crt:/opt/openpitrix/conf/pilot-server.crt"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/kubernetes/tls-config/pilot-server.key:/opt/openpitrix/conf/pilot-server.key"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/kubernetes/tls-config/pilot-client.crt:/opt/openpitrix/conf/pilot-client.crt"
		VOLUMES="${VOLUMES} -v /opt/openpitrix/kubernetes/tls-config/pilot-client.key:/opt/openpitrix/conf/pilot-client.key"
fi

#Start container
docker run -it -d \
   --add-host ${DB_HOST}:${DB_IP} \
   --add-host ${ETCD_HOST}:${ETCD_IP} \
   ${PORTS} \
   ${VOLUMES} \
   ${ENVS} \
   --restart=always \
   --name ${CONTAINER_NAME} \
   openpitrix:latest ${COMMAND}

log "The ${SERVICE} container is running..."

