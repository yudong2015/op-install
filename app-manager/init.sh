#!/usr/bin/env bash

touch /opt/app-manager/hosts/test1
touch /opt/app-manager/hosts/test2
touch /opt/app-manager/hosts/test3
touch /opt/app-manager/hosts/test4

cat /etc/hosts > /opt/app-manager/hosts/test1

cp /etc/hosts /opt/app-manager/hosts/origin-hosts

cat /opt/app-manager/hosts/origin-hosts > /opt/app-manager/hosts/test2
cat /opt/app-manager/hosts/link-hosts > /opt/app-manager/hosts/test3

cat /opt/app-manager/hosts/origin-hosts /opt/app-manager/hosts/link-hosts > /etc/hosts

cat /etc/hosts > /opt/app-manager/hosts/test4

MYSQL_ROOT_PASSWORD=$(curl -s http://metadata/self/links/external_service/env/openpitrix-db/mysql_root_password)

# migrate app database
# befor migrating, copy app schema from openpitrix/pkg/schema/app to /opt/app-manager/schema
docker run -it -d -v /opt/app-manager/schema:/flyway/sql --net=host \
 		   dhoer/flyway:5.1.4-mysql-8.0.11-alpine -url=jdbc:mysql://openpitrix-db/app -user=root -password=${MYSQL_ROOT_PASSWORD} -validateOnMigrate=false migrate
