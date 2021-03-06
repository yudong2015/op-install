#!/usr/bin/env bash
###############################################
## NOTE: if run this script in container, 
## the env above must to be #!/bin/sh
###############################################

if [[ -n "$1" ]]; then
	LINK_HOSTS=$1
else
	exit 1
fi
HOSTS_TMP="/tmp/hosts.tmp"

cp /etc/hosts ${HOSTS_TMP}

for line in $(cat ${LINK_HOSTS})
do
	if [[ -n "$line" ]]; then
		HOST=`echo $line|cut -d ":" -f 1`
		IP=`echo $line|cut -d ":" -f 2`
		sed -i "/${HOST}$/d" ${HOSTS_TMP}
		echo "${IP} ${HOST}" >> ${HOSTS_TMP}
	fi
done

cat ${HOSTS_TMP} > /etc/hosts