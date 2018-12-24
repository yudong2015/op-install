#!/bin/sh

#NOTE: the env above must to be #!/bin/sh
####################################
LINK_HOSTS_TMP="/opt/link-hosts.tmp
for line in $(cat ${LINK_HOSTS_TMP})
do
	HOST=`echo $line|cut -d "=" -f 1`
	IP=`echo $line|cut -d "=" -f 2`
	sed -e "/${HOST}$/d" /etc/hosts > /tmp/hosts
	echo "${IP}    ${HOST}" >> /tmp/hosts
	cat /tmp/hosts > /etc/hosts
done