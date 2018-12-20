#!/usr/bin/env bash

echo "Start updating link hosts..." >> /opt/app-manager/log

DB_IP=`cat /opt/app-manager/link-hosts|grep DB_IP|cut -d "=" -f 2`
DB_HOST=`cat /opt/app-manager/link-hosts|grep DB_HOST|cut -d "=" -f 2`
ETCD_IP=`cat /opt/app-manager/link-hosts|grep ETCD_IP|cut -d "=" -f 2`
ETCD_HOST=`cat /opt/app-manager/link-hosts|grep ETCD_HOST|cut -d "=" -f 2`
echo "DB_IP:${DB_IP} DB_HOST:${DB_HOST}" >> /opt/app-manager/log
echo "ETCD_IP:${DB_IP} ETCD_HOST:${DB_HOST}" >> /opt/app-manager/log

#update local hosts
echo "${DB_IP} ${DB_HOST}" > /opt/app-manager/link-hosts.tmp
echo "${ETCD_IP} ${ETCD_HOST}" >> /opt/app-manager/link-hosts.tmp
cat /opt/app-manager/hosts/origin-hosts /opt/app-manager/link-hosts.tmp > /etc/hosts


#check if openpitrix-app-manager container exist
CONTAINER_NAME="openpitrix-app-manager"
n=`docker ps|grep ${CONTAINER_NAME}|wc -l`
if [ $n > 0 ]; then
	echo "Run update container ip..." >> /opt/app-manager/log
    docker exec -it $CONTAINER_NAME /opt/updateContainerHosts.sh $DB_HOST=$DB_IP $ETCD_HOST=$ETCD_IP
else
	echo "There is no container, just update local link hosts..." >> /opt/app-manager/log
fi