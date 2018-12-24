#!/usr/bin/env bash

CMD_DIR="/opt/openpitrix/cmd"
source ${CMD_DIR}/log.sh
log "Start updating hosts..."

#update local hosts
LINK_HOSTS="${CMD_DIR}/hosts/link-hosts"
${CMD_DIR}/hosts/update.sh LINK_HOSTS

#update running container hosts
CONTAINER_NUM=`docker ps|grep openpitrix|wc -l`
if [ ${CONTAINER_NUM} -gt 0 ]; then
	for CONTAINER_NAME in `docker ps|grep openpitrix|awk '{print $NF}'`
	do
		log "Run update ip of DB and etcd in $CONTAINER_NAME container..."
    	docker exec -it $CONTAINER_NAME /opt/update.sh
    done
else
	log "There is no container, just update local link hosts..."
fi
