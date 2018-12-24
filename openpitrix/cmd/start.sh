#!/usr/bin/env bash

source /opt/openpitrix/cmd/log.sh

#####################################################
# get service name
if [[ -n "$1" ]];then
  SERVICE=$1
else
	log "ERROR: The service name is empty!"
	log 'usage: /opt/openpitrix/cmd/start.sh $SERVICE_NAME [$COMMAND]'
	exit
fi
#####################################################
# get command
if [ -n "$2" ]; then
	COMMAND=$2
else
	COMMAND=$SERVICE
fi

#####################################################
# consisting all kinds of params of container, and start container
log "Start ${SERVICE} container..."
UPDATE_CONTAINER_DIR="/opt/openpitrix/cmd/updateContainer"
LINK_HOSTS="${UPDATE_CONTAINER_DIR}/link-hosts"

CONTAINER_NAME="openpitrix-${SERVICE}"
LOG_LEVEL=$(curl -s http://metadata/self/env/openpitrix_log_level)
GRPC_SHOW_ERROR_CASE=$(curl -s http://metadata/self/env/openpitrix_grpc_show_error_cause)
SERVICE_PORT=$(curl -s http://metadata/self/env/${SERVICE}-port)
DB=$(curl -s http://metadata/self/env/${SERVICE}-database)

log "CONTAINER_NAME: ${CONTAINER_NAME}."
log "LOG_LEVEL: ${LOG_LEVEL}."
log "GRPC_SHOW_ERROR_CASE: ${GRPC_SHOW_ERROR_CASE}."
log "SERVICE_PORT: ${SERVICE_PORT}."
log "DB: ${DB}."

#Container ADD_HOSTS PORTs, VOLUMEs, ENVs, IMG
ADD_HOSTS=""
for line in $(cat ${LINK_HOSTS})
do
	if [[ -n "$line" ]]; then
		ADD_HOSTS="${ADD_HOSTS} --add-host ${line}"
	fi
done
PORTS="-p ${SERVICE_PORT}:${SERVICE_PORT}"
VOLUMES="-v ${UPDATE_CONTAINER_DIR}:/opt"
ENVS="-e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE} -e OPENPITRIX_MYSQL_DATABASE=${DB}"
IMG="openpitrix:latest"

#consisting all kinds of params of container
if [[ ${SERVICE} == "minio" ]]; then
	ACCESS_KEY=$(curl -s http://metadata/self/env/minio_access_key)
	SECRET_KEY=$(curl -s http://metadata/self/env/minio_secret_key)
	IMG="minio/minio:RELEASE.2018-09-25T21-34-43Z"
	VOLUMES="$VOLUMES -v /opt/data/minio:/data"
	ENVS="-e MINIO_ACCESS_KEY=${ACCESS_KEY} -e MINIO_SECRET_KEY=${SECRET_KEY}"
elif [[ ${SERVICE} == "app-manager" ||  ${SERVICE} == "repo-indexer" ]]; then
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
	ENVS="-e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE}"
elif [[ ${SERVICE} == "api-gateway" ]]; then
	ENVS="-e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL}"
elif [[ ${SERVICE} == "dashboard" ]]; then
	API_GATEWAY_PORT=$(curl -s http://metadata/self/env/api-gateway-port)
	API_VERSION=$(curl -s http://metadata/self/env/api-version)
	ID=$(curl -s http://metadata/self/env/iam_init_client_id)
	SECRET=$(curl -s http://metadata/self/env/iam_init_client_secret)
	ENVS="-e serverUrl=http://openpitrix-api-gateway:${API_GATEWAY_PORT}"
	ENVS="${ENVS} -e apiVersion=${API_VERSION}"
	ENVS="${ENVS} -e socketUrl=ws://openpitrix-api-gateway:${API_GATEWAY_PORT}/${API_VERSION}/io"
	ENVS="${ENVS} -e clientId=${ID} -e clientSecret=${SECRET}"
	IMG="openpitrix/dashboard:latest"
	COMMAND=""
fi

#Start container
log "docker run -it -d ${ADD_HOSTS} ${PORTS} ${VOLUMES} ${ENVS} --restart=always --name ${CONTAINER_NAME} ${IMG} ${COMMAND}"

docker run -it -d \
   ${ADD_HOSTS} \
   ${PORTS} \
   ${VOLUMES} \
   ${ENVS} \
   --restart=always \
   --name ${CONTAINER_NAME} \
   ${IMG} ${COMMAND}

log "The ${SERVICE} container is running..."

