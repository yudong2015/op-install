#!/bin/sh

DB_IP=$1
DB_HOST=$2

sed -e "/${DB_HOST}$/d" /etc/hosts > /tmp/hosts
echo "${DB_IP}    ${DB_HOST}" >> /tmp/hosts
cat /tmp/hosts > /etc/hosts