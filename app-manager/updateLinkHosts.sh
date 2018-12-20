#!/usr/bin/env bash

LOG_FILE="/opt/app-manager/log"
echo "Start updating link hosts..." >> ${LOG_FILE}

DB_HOST="openpitrix-db"
ETCD_HOST="openpitrix-etcd"
DB_IP=`cat /opt/app-manager/link-hosts|grep ${DB_HOST}|cut -d "=" -f 2`
ETCD_IP=`cat /opt/app-manager/link-hosts|grep ${ETCD_HOST}|cut -d "=" -f 2`
echo "DB_IP:${DB_IP} DB_HOST:${DB_HOST}" >> ${LOG_FILE}
echo "ETCD_IP:${DB_IP} ETCD_HOST:${DB_HOST}" >> ${LOG_FILE}

#update local hosts
ORIGIN_HOSTS="/opt/app-manager/origin-hosts"
LINK_HOSTS_TMP="/opt/app-manager/link-hosts.tmp"
echo "${DB_IP} ${DB_HOST}" > ${LINK_HOSTS_TMP}
echo "${ETCD_IP} ${ETCD_HOST}" >> ${LINK_HOSTS_TMP}

if [ ! -f "${ORIGIN_HOSTS}" ]; then
	cp /etc/hosts ${ORIGIN_HOSTS}
fi
cat ${ORIGIN_HOSTS} ${LINK_HOSTS_TMP} > /etc/hosts

#check if openpitrix-app-manager container exist
CONTAINER_NAME="openpitrix-app-manager"
n=`docker ps|grep ${CONTAINER_NAME}|wc -l`
if [ $n -gt 0 ]; then
	echo "Run update container ip..." >> ${LOG_FILE}
    docker exec -it $CONTAINER_NAME /opt/updateContainerHosts.sh $DB_HOST=$DB_IP $ETCD_HOST=$ETCD_IP
else
	echo "There is no container, just update local link hosts..." >> ${LOG_FILE}
fi