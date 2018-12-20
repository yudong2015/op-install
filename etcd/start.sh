#!/usr/bin/env bash

CONTAINER_NAME="openpitrix-etcd"
ADVERTISE_CLIENT_URLS="openpitrix-etcd"
HOST_IP=$(curl -s http://metadata/self/host/ip)
PORT=2379

#Start etcd container
docker run -it -d -p ${PORT}:${PORT} \
		--add-host ${ADVERTISE_CLIENT_URLS}:${HOST_IP} \
		-v /opt/etcd/data:/data \
		--restart=always \
		--name ${CONTAINER_NAME} \
		quay.io/coreos/etcd:v3.2.18 etcd --data-dir /data --listen-client-urls http://0.0.0.0:${PORT} --advertise-client-urls http://${ADVERTISE_CLIENT_URLS}:2379 --max-snapshots 5 --max-wals 5 --auto-compaction-retention=168