#!/bin/sh

#NOTE: the env above must to be #!/bin/sh
####################################
LINK_HOSTS="/opt/link-hosts
HOSTS_TMP="/tmp/hosts.tmp"

cp /etc/hosts ${HOSTS_TMP}

for line in $(cat ${LINK_HOSTS})
do
	if [[ -n "$line" ]]; then
		HOST=`echo $line|cut -d ":" -f 1`
		IP=`echo $line|cut -d ":" -f 2`
		sed -i "/${HOST}$/d" ${HOSTS_TMP}
		echo "${IP} ${HOST}" >> ${HOST_TMP}
	fi
done

cat ${HOST_TMP} > /etc/hosts