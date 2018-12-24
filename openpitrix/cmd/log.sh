#!/usr/bin/env bash

LOG_FILE="$(cd `dirname $0`; pwd)/openpitrix.log"

function log()
{
    local curtime=`date "+%Y-%m-%d %H:%M:%S"`
    echo "[$curtime] $* ($0)">> ${LOG_FILE}
}
