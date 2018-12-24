#!/usr/bin/env bash

source /opt/openpitrix/cmd/log.sh
log "Start updating hosts..."

#update local hosts
ORIGIN_HOSTS="/opt/openpitrix/origin-hosts"
LINK_HOSTS="/opt/openpitrix/link-hosts"
LINK_HOSTS_TMP="/opt/openpitrix/updateContainer/link-hosts.tmp"
if [ ! -f "${ORIGIN_HOSTS}" ]; then
	cp /etc/hosts ${ORIGIN_HOSTS}
fi
#clear link-host temp
echo "" > ${LINK_HOSTS_TMP}

for line in $(cat ${LINK_HOSTS})
do
	if [[ -n "$line" ]]; then
		HOST=`echo ${line}|cut -d "=" -f 1`
		IP=`echo ${line}|cut -d "=" -f 2`
		echo "${IP} ${HOST}" >> ${LINK_HOSTS_TMP}
	fi
done
cat ${ORIGIN_HOSTS} ${LINK_HOSTS_TMP} > /etc/hosts

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
