#!/usr/bin/env bash

CONTAINER_NAME="openpitrix-app-manager"
LOG_LEVEL=$(curl -s http://metadata/self/env/app_manager_log_level)
GRPC_SHOW_ERROR_CASE=$(curl -s http://metadata/self/env/openpitrix_grpc_show_error_cause)

#Start app-manager container
docker run -it -d -p 9102:9102 --name ${CONTAINER_NAME} \
		   -v /opt/app-manager/hosts:/opt/hosts:rw \
 		   -e OPENPITRIX_LOG_LEVEL=${LOG_LEVEL} \
 		   -e OPENPITRIX_GRPC_SHOW_ERROR_CAUSE=${GRPC_SHOW_ERROR_CASE} \
 		   -e OPENPITRIX_MYSQL_DATABASE=app \
 		   -e OPENPITRIX_PROFILING_ENABLE=1 \
 		   openpitrix:latest cp /etc/hosts /opt/hosts/containerHosts && cat /opt/hosts/containerHosts /opt/hosts/link-hosts > /etc/hosts && app-manager
