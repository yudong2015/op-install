#!/usr/bin/env bash

CMD_DIR="/opt/openpitrix/cmd"
source ${CMD_DIR}/log.sh
log "Start updating hosts..."

#update hosts
log "Start updating local hosts..."
LINK_HOSTS="${CMD_DIR}/link-hosts"
${CMD_DIR}/updateHosts.sh $LINK_HOSTS
