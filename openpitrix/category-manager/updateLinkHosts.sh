#!/usr/bin/env bash

source /opt/category-manager/log.sh
log "Start updating link hosts..."

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/category-manager/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/category-manager/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
log "DB_IP:${DB_IP} DB_HOST:${DB_HOST}"
log "ETCD_IP:${ETCD_IP} ETCD_HOST:${ETCD_HOST}"

#update local hosts
ORIGIN_HOSTS="/opt/category-manager/origin-hosts"
LINK_HOSTS_TMP="/opt/category-manager/link-hosts.tmp"
echo "${DB_IP} ${DB_HOST}" > ${LINK_HOSTS_TMP}
echo "${ETCD_IP} ${ETCD_HOST}" >> ${LINK_HOSTS_TMP}

if [ ! -f "${ORIGIN_HOSTS}" ]; then
	cp /etc/hosts ${ORIGIN_HOSTS}
fi
cat ${ORIGIN_HOSTS} ${LINK_HOSTS_TMP} > /etc/hosts

#check if openpitrix-category-manager container exist
CONTAINER_NAME="openpitrix-category-manager"
n=`docker ps|grep ${CONTAINER_NAME}|wc -l`
if [ $n -gt 0 ]; then
	log "Run update container ip..."
    docker exec -it $CONTAINER_NAME /opt/updateContainerHosts.sh $DB_HOST=$DB_IP $ETCD_HOST=$ETCD_IP
else
	log "There is no container, just update local link hosts..."
fi