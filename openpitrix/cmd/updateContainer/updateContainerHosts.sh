#!/bin/sh

#NOTE: the env above must to be #!/bin/sh

if [ $# -gt 0 ]; then
	for arg in $*
	do
		HOST=`echo $arg|cut -d "=" -f 1`
		IP=`echo $arg|cut -d "=" -f 2`
		sed -e "/${HOST}$/d" /etc/hosts > /tmp/hosts
		echo "${IP}    ${HOST}" >> /tmp/hosts
		cat /tmp/hosts > /etc/hosts
	done
fi