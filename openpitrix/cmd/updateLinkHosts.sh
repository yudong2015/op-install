#!/usr/bin/env bash

source /opt/openpitrix/cmd/log.sh
log "Start updating link hosts..."

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/openpitrix/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/openpitrix/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
log "DB_IP:${DB_IP} DB_HOST:${DB_HOST}"
log "ETCD_IP:${ETCD_IP} ETCD_HOST:${ETCD_HOST}"

#update local hosts
ORIGIN_HOSTS="/opt/openpitrix/origin-hosts"
LINK_HOSTS_TMP="/opt/openpitrix/link-hosts.tmp"
echo "${DB_IP} ${DB_HOST}" > ${LINK_HOSTS_TMP}
echo "${ETCD_IP} ${ETCD_HOST}" >> ${LINK_HOSTS_TMP}

if [ ! -f "${ORIGIN_HOSTS}" ]; then
	cp /etc/hosts ${ORIGIN_HOSTS}
fi
cat ${ORIGIN_HOSTS} ${LINK_HOSTS_TMP} > /etc/hosts

#check if container exist
CONTAINER_NUM=`docker ps|grep openpitrix|wc -l`
if [ ${CONTAINER_NUM} -gt 0 ]; then
	for CONTAINER_NAME in `docker ps|grep openpitrix|awk '{print $NF}'`
	do
		log "Run update ip of DB and etcd in $CONTAINER_NAME container..."
    	docker exec -it $CONTAINER_NAME /opt/updateContainerHosts.sh $DB_HOST=$DB_IP $ETCD_HOST=$ETCD_IP
    done
else
	log "There is no container, just update local link hosts..."
fi