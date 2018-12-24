#!/usr/bin/env bash

source /opt/openpitrix/cmd/log.sh
log "Start updating hosts..."

#update local hosts
LINK_HOSTS="/opt/openpitrix/cmd/updateContainer/link-hosts"
HOSTS_TMP="/tmp/hosts.tmp"

cp /etc/hosts ${HOSTS_TMP}

for line in $(cat ${LINK_HOSTS})
do
	if [[ -n "$line" ]]; then
		HOST=`echo ${line}|cut -d ":" -f 1`
		IP=`echo ${line}|cut -d ":" -f 2`
		sed -i "/${HOST}$/d" ${HOSTS_TMP}
		echo "${IP} ${HOST}" >> ${HOST_TMP}
	fi
done
cat ${HOSTS_TMP} > /etc/hosts

#update container hosts
CONTAINER_NUM=`docker ps|grep openpitrix|wc -l`
if [ ${CONTAINER_NUM} -gt 0 ]; then
	for CONTAINER_NAME in `docker ps|grep openpitrix|awk '{print $NF}'`
	do
		log "Run update ip of DB and etcd in $CONTAINER_NAME container..."
    	docker exec -it $CONTAINER_NAME /opt/updateContainerHosts.sh
    done
else
	log "There is no container, just update local link hosts..."
fi
